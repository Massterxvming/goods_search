import assert from 'node:assert/strict';
import { test } from 'node:test';

import { buildMarketPriceReport, runMarketPriceResearch } from '../src/market_price.js';
import type { PriceExtraction } from '../src/market_price_contracts.js';
import { isBlockedProductPage, isConsumerRetailSource, isPublicSourceUrl, PriceSearchError, searchPriceSources } from '../src/price_sources.js';
import type { PriceSource } from '../src/price_sources.js';
import { loadConfig } from '../src/config.js';
import { getPlatformProduct, platformSearchQueries } from '../src/shopping_platforms.js';

const now = new Date('2026-11-16T12:00:00Z');
const query = { productName: '测试鼠标 全新单只', market: '中国大陆', currency: 'CNY' } as const;
function source(id: number, price: number): PriceSource {
  return { id: `s${id}`, title: '测试鼠标商品详情', url: `https://item.jd.com/${1000 + id}.html`,
    platform: '京东', productId: `${1000 + id}`, fetchedAt: now.toISOString(),
    publishedAt: '2026-11-15T00:00:00Z', fetched: true, text: `测试鼠标 测试商家${id} 京东价 ￥${price.toFixed(2)}` };
}
function quote(id: number, price: number): PriceExtraction['quotes'][number] {
  return { sourceId: `s${id}`, seller: `测试商家${id}`, price, priceText: `京东价 ￥${price.toFixed(2)}`,
    matchesProduct: true, isNewRetail: true, priceBasis: 'current_sale' };
}
const extraction = (quotes: PriceExtraction['quotes']): PriceExtraction => ({ clarification: null, quotes, limitations: [] });

test('computes the sample mean and bounds in cents from three evidenced quotations', () => {
  const report = buildMarketPriceReport(query, [source(1, 10.01), source(2, 20.02), source(3, 30.03)],
    extraction([quote(1, 10.01), quote(2, 20.02), quote(3, 30.03)]), now);
  assert.equal(report.status, 'completed');
  assert.equal(report.averagePrice, 20.02);
  assert.equal(report.lowestPrice, 10.01);
  assert.equal(report.highestPrice, 30.03);
  assert.equal(report.sampleCount, 3);
});

test('rejects invented prices, absent evidence, stale pages, conditional prices and unknown sources', () => {
  const sources = Array.from({ length: 8 }, (_, index) => source(index + 1, 10));
  sources[4]!.fetchedAt = '2025-11-15T00:00:00Z';
  sources[5]!.fetched = false;
  const bad = [
    quote(3, 20),
    { ...quote(4, 10), priceText: '编造的价格为10元' },
    quote(5, 10), quote(6, 10),
    { ...quote(7, 10), priceBasis: 'conditional' as const },
    { ...quote(8, 10), matchesProduct: false },
    quote(99, 10),
  ];
  const report = buildMarketPriceReport(query, sources, extraction([quote(1, 10), quote(2, 10), ...bad]), now);
  assert.equal(report.sampleCount, 2);
  assert.equal(report.status, 'insufficient_data');
  assert.equal(report.averagePrice, null);
});

test('deduplicates source URLs and repeated offers before computing a mean', () => {
  const sources = [source(1, 10), source(2, 20), source(3, 30), source(4, 10), source(5, 20)];
  sources[3]!.url = 'https://item.m.jd.com/product/1001.html?utm_source=duplicate';
  sources[4]!.text = sources[4]!.text.replace('测试商家5', '测试商家2');
  const report = buildMarketPriceReport(query, sources, extraction([
    quote(1, 10), quote(2, 20), quote(3, 30), quote(4, 10), { ...quote(5, 20), seller: '测试商家2' },
  ]), now);
  assert.equal(report.sampleCount, 3);
  assert.equal(report.averagePrice, 20);
});

test('ambiguous products return a clarification and no numeric average', () => {
  const report = buildMarketPriceReport(query, [source(1, 10)], { ...extraction([]), clarification: '请补充品牌型号。' }, now);
  assert.equal(report.status, 'needs_clarification');
  assert.equal(report.averagePrice, null);
});

test('excludes institutional purchasing found in page text and flags extreme asking prices', () => {
  const sources = [source(1, 73.8), source(2, 129), source(3, 75), source(4, 309), source(5, 109)];
  sources[4]!.text += ' 企业级团单版本，适合批量采购';
  const report = buildMarketPriceReport(query, sources, extraction([
    quote(1, 73.8), quote(2, 129), quote(3, 75), quote(4, 309), quote(5, 109),
  ]), now);
  assert.equal(report.sampleCount, 3);
  assert.equal(report.averagePrice, 92.6);
  assert.equal(report.highestPrice, 129);
  assert.ok(report.limitations.some(item => item.includes('2.5倍')));
  assert.equal(report.sources.length, 5);
  assert.equal(isConsumerRetailSource({ title: '鼠标+桌垫套装', text: '页面价74元', url: 'https://shop.example/product' }), false);
  const sparse = buildMarketPriceReport(query, [source(1, 73.8), source(2, 74), source(3, 309)], extraction([quote(1, 73.8), quote(2, 74), quote(3, 309)]), now);
  assert.equal(sparse.sampleCount, 2);
  assert.equal(sparse.averagePrice, null);
});

test('source links exclude credentials, private hosts and non-web schemes', () => {
  assert.equal(isPublicSourceUrl('https://shop.example/product'), true);
  for (const url of ['file:///etc/passwd', 'http://127.0.0.1/x', 'http://[::1]/', 'http://localhost/x', 'http://a.internal/x', 'https://key@shop.example/x']) {
    assert.equal(isPublicSourceUrl(url), false);
  }
});

test('DeepSeek search uses server credentials and refuses provider failures without exposing them', async () => {
  const config = loadConfig({ AGENT_MODEL_BASE_URL: 'https://api.deepseek.com', AGENT_MODEL_NAME: 'deepseek-flash', AGENT_MODEL_API_KEY: 'fixture-secret' });
  const fetcher: typeof fetch = async (input, init) => {
    assert.equal(input, 'https://api.deepseek.com/v1/tools/search');
    assert.equal((init!.headers as Record<string, string>).Authorization, 'Bearer fixture-secret');
    assert.equal(init!.redirect, 'error');
    const body = JSON.parse(init!.body as string);
    assert.equal(body.need_content, false);
    return Response.json({ error: { message: 'fixture-secret' } }, { status: 401 });
  };
  await assert.rejects(searchPriceSources(query, config, AbortSignal.timeout(5000), fetcher), error =>
    error instanceof PriceSearchError && !error.message.includes('fixture-secret'));
});

test('only recognized shopping platform product routes qualify, including mobile SKU aliases', () => {
  const jd = getPlatformProduct('https://item.m.jd.com/product/1001.html?utm_source=test');
  assert.equal(jd?.canonicalUrl, 'https://item.jd.com/1001.html');
  assert.equal(getPlatformProduct('https://item.taobao.com/item.htm?id=1002')?.platform, '淘宝');
  assert.equal(getPlatformProduct('https://detail.tmall.com/item.htm?id=1003')?.platform, '天猫');
  assert.equal(getPlatformProduct('https://mobile.yangkeduo.com/goods2.html?goods_id=1004')?.platform, '拼多多');
  for (const url of [
    'https://jd.zol.com.cn/1272/12726403.html', 'https://m.smzdm.com/p/123/',
    'https://finance.sina.com.cn/a.html', 'https://item.jd.com.evil.example/1001.html',
    'https://item.jd.com@evil.example/1001.html', 'https://news.jd.com/1001.html',
    'https://item.jd.com/list.html', 'https://detail.tmall.com/item.htm?id=1&id=2',
    'https://uland.taobao.com/coupon/edetail?itemId=1001',
  ]) assert.equal(getPlatformProduct(url), null);
  const queries = platformSearchQueries('超长商品名称'.repeat(40));
  assert.equal(queries.length, 4);
  assert.ok(queries.every(query => Array.from(query).length <= 128));
  for (const domain of ['jd.com', 'taobao.com', 'tmall.com', 'yangkeduo.com']) assert.ok(queries.some(query => query.endsWith(`site:${domain}`)));
});

test('third-party articles cannot become quotations even when the model claims they are JD prices', () => {
  const sources = [source(1, 73.8), source(2, 129), source(3, 75)];
  sources[0]!.url = 'https://diy.zol.com.cn/1273/12730376.html';
  sources[1]!.url = 'https://m.smzdm.com/p/186180328/';
  sources[2]!.url = 'https://m.smzdm.com/p/186147974/';
  const report = buildMarketPriceReport(query, sources, extraction([quote(1, 73.8), quote(2, 129), quote(3, 75)]), now);
  assert.equal(report.averagePrice, null);
  assert.equal(report.sampleCount, 0);
  assert.equal(report.sourceCount, 0);
  assert.deepEqual(report.sources, []);
});

test('reference labels, login pages and unfetched search snippets never qualify as current sale prices', () => {
  for (const label of ['参考价格', '原价', '划线价', '会员专享价格', '新人补贴价格', '分期月供']) {
    const candidate = source(1, 99);
    candidate.text = `测试鼠标 ${label} ￥99.00`;
    const report = buildMarketPriceReport(query, [candidate], extraction([{ ...quote(1, 99), priceText: '￥99.00' }]), now);
    assert.equal(report.sampleCount, 0, label);
  }
  const login = source(1, 99);
  login.title = '京东-欢迎登录';
  assert.equal(isBlockedProductPage(login.title, login.text), true);
  assert.equal(buildMarketPriceReport(query, [login], extraction([quote(1, 99)]), now).sampleCount, 0);
  const unfetched = source(1, 99);
  unfetched.fetched = false;
  assert.equal(buildMarketPriceReport(query, [unfetched], extraction([quote(1, 99)]), now).sampleCount, 0);
  for (const text of ['京东价 ￥99.00起', '当前售价 ￥99.00-199', '售价 ￥99.00（新人专享）']) {
    const candidate = source(1, 99);
    candidate.text = `测试鼠标 ${text}`;
    assert.equal(buildMarketPriceReport(query, [candidate], extraction([{ ...quote(1, 99), priceText: text }]), now).sampleCount, 0, text);
  }
  assert.equal(isBlockedProductPage('测试鼠标', '该商品已下架'), true);
});

test('search is discovery-only: fetches platform pages, ignores cached amounts, skips third-party links and login results', async () => {
  const config = loadConfig({ AGENT_MODEL_BASE_URL: 'https://api.deepseek.com', AGENT_MODEL_NAME: 'deepseek-flash', AGENT_MODEL_API_KEY: 'fixture-secret' });
  const fetched: string[] = [];
  const fetcher: typeof fetch = async (input, init) => {
    const body = JSON.parse(init!.body as string);
    if (String(input).endsWith('/search')) {
      return Response.json({ results: [
        { title: '京东报道', url: 'https://jd.zol.com.cn/price.html', content: '价格 ￥1.00' },
        { title: '测试鼠标', url: 'https://item.jd.com/1001.html', content: '历史价格 ￥1.00', date: '2026-11-15T00:00:00Z' },
        { title: '移动页', url: 'https://item.m.jd.com/product/1001.html', snippet: '价格 ￥2.00' },
        { title: '测试鼠标', url: 'https://item.taobao.com/item.htm?id=1002', snippet: '价格 ￥3.00' },
      ] });
    }
    fetched.push(body.url);
    return Response.json(body.url.includes('taobao.com')
      ? { title: '用户登录', content: '扫码登录后可见价格' }
      : { title: '测试鼠标', content: '测试鼠标 京东价 ￥79.00' });
  };
  const { sources, searches } = await searchPriceSources(query, config, AbortSignal.timeout(5000), fetcher);
  assert.equal(fetched.length, 2);
  assert.ok(fetched.every(url => getPlatformProduct(url)));
  assert.equal(sources.length, 2);
  assert.equal(sources[0]!.text, '测试鼠标 京东价 ￥79.00');
  assert.equal(sources[0]!.fetched, true);
  assert.ok(sources[0]!.fetchedAt);
  assert.equal(sources[1]!.fetched, false);
  assert.equal(sources[1]!.text, '');
  assert.equal(sources[1]!.accessStatus, 'login_required');
  assert.ok(sources[1]!.accessMessage?.includes('登录'));
  assert.equal(searches.length, 4);
  assert.equal(searches[0]!.resultCount, 4);
  assert.equal(searches[0]!.productPageCount, 2);
});

test('hidden mobile prices cannot turn fees or masked amounts into product quotations', () => {
  const candidate = source(1, 20);
  candidate.text = '商品评价 ¥2?? 登录查看价格 选择门店后可确认该商品价格 省心定期购 免运费 ￥0.00';
  assert.equal(isBlockedProductPage(candidate.title, candidate.text), true);
  assert.equal(buildMarketPriceReport(query, [candidate], extraction([quote(1, 20)]), now).sampleCount, 0);
});

test('preserves fetch errors separately from login pages and distinguishes empty search results', async () => {
  const config = loadConfig({ AGENT_MODEL_BASE_URL: 'https://api.deepseek.com', AGENT_MODEL_NAME: 'deepseek-flash', AGENT_MODEL_API_KEY: 'fixture-secret' });
  const fetcher: typeof fetch = async (input, init) => {
    const body = JSON.parse(init!.body as string);
    if (String(input).endsWith('/search')) return Response.json({ results: body.query.endsWith('site:jd.com') ?
      [1001, 1002, 1003, 1004, 1005].map(id => ({title:'商品', url:`https://item.jd.com/${id}.html`})) : [] });
    if (body.url.includes('1001')) throw new DOMException('fixture-secret', 'TimeoutError');
    if (body.url.includes('1002')) return Response.json({error:{message:'fixture-secret'}}, {status:403});
    if (body.url.includes('1003')) return Response.json({title:'商品', content:''});
    if (body.url.includes('1004')) return Response.json({title:'安全验证', content:'请完成安全验证'});
    return Response.json({unexpected:'fixture-secret'});
  };
  const {sources, searches} = await searchPriceSources(query, config, AbortSignal.timeout(5000), fetcher);
  assert.deepEqual(sources.map(s => s.accessStatus), ['fetch_timeout','fetch_failed','empty_content','verification_required','invalid_response']);
  assert.ok(!JSON.stringify(sources).includes('fixture-secret'));
  assert.equal(searches[1]!.status, 'completed');
  assert.equal(searches[1]!.resultCount, 0);
  assert.ok(searches[1]!.message.includes('未返回结果'));
});

test('reports the login bottleneck and skips the model when every fetched page is a login screen', async t => {
  const config = loadConfig({ AGENT_MODEL_BASE_URL: 'https://api.deepseek.com', AGENT_MODEL_NAME: 'deepseek-flash', AGENT_MODEL_API_KEY: 'fixture-secret' });
  t.mock.method(globalThis, 'fetch', async (input: string, init: RequestInit) => {
    assert.ok(input.includes('/v1/tools/'), 'no model inference request should be made');
    const body = JSON.parse(init.body as string);
    if (input.endsWith('/search')) return Response.json({results: body.query.endsWith('site:jd.com') ? [
      {title:'测试鼠标', url:'https://item.jd.com/1001.html'},
      {title:'测试鼠标', url:'https://item.jd.com/1002.html'},
    ] : []});
    return Response.json({title:'京东-欢迎登录', content:'个人用户登录 密码登录 短信登录'});
  });
  const report = await runMarketPriceResearch(query, config, AbortSignal.timeout(5000));
  assert.equal(report.status, 'insufficient_data');
  assert.equal(report.averagePrice, null);
  assert.match(report.message, /2个需要登录/);
  assert.equal(report.diagnostics?.loginRequiredPages, 2);
  assert.equal(report.diagnostics?.readablePages, 0);
  assert.equal(report.diagnostics?.modelInvoked, false);
  assert.equal(report.sources[0]?.accessStatus, 'login_required');
});
