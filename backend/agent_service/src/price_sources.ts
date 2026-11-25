import { isIP } from 'node:net';
import { z } from 'zod';

import type { AgentConfig } from './config.js';
import type { MarketPriceRequest, MarketPriceSource, PageAccessStatus, PlatformSearchDiagnostic } from './market_price_contracts.js';
import { getPlatformProduct, platformSearchQueries } from './shopping_platforms.js';

export interface PriceSource extends MarketPriceSource {
  text: string;
  fetched: boolean;
}

export class PriceSearchError extends Error {
  constructor() { super('购物平台商品检索暂不可用，请稍后重试。'); }
}

class PriceToolError extends Error {
  constructor(readonly status: PageAccessStatus, message: string) { super(message); }
}

export interface PriceSourceSearchResult {
  sources: PriceSource[];
  searches: PlatformSearchDiagnostic[];
}

export const accessMessages: Record<PageAccessStatus, string> = {
  readable: '已读取商品页正文，报价是否采用见核验明细。',
  login_required: '平台要求登录后查看商品或价格，未取得公开在售价。',
  verification_required: '平台返回安全验证或访问限制，未取得价格。',
  not_available: '商品已下架、售罄或不可用，不采用对应报价。',
  no_price: '已读取商品页正文，但没有可用的人民币价格文本。',
  empty_content: '网页读取服务返回空正文，未取得价格。',
  fetch_timeout: '读取商品页超时，未取得价格。',
  fetch_failed: '网页读取服务请求失败，未取得价格。',
  invalid_response: '网页读取服务返回格式异常，未取得有效正文。',
};

export function blockedPageStatus(title: string, text: string): PageAccessStatus | null {
  const head = text.slice(0, 1600);
  if (/^\s*(?:京东[-— ]*)?(?:欢迎登录|用户登录|登录)/.test(title)
    || /请登录后(?:查看|获取)(?:商品)?价格|登录后可见|登录(?:后)?查看价格|登录(?:后)?获取价格/.test(head)
    || (text.length < 900 && /扫码登录|账户登录|密码登录|短信登录/.test(text) && !/[¥￥]\s*\d|\d\s*元/.test(text))) return 'login_required';
  if (/^\s*(?:京东[-— ]*)?(?:安全验证|访问受限|验证码|验证中心)/.test(title)
    || /请完成(?:安全)?验证|访问过于频繁|滑动滑块完成验证|captcha/i.test(head)) return 'verification_required';
  if (/商品已下架|商品不存在|商品已删除|商品已售罄/.test(head)) return 'not_available';
  return null;
}

export function isBlockedProductPage(title: string, text: string): boolean {
  return blockedPageStatus(title, text) !== null;
}

export function isConsumerRetailSource(source: Pick<PriceSource, 'title' | 'text' | 'url'>): boolean {
  return !/企业级|团单|校采|政府采购|批量采购|批发/.test(`${source.title}\n${source.text.slice(0, 1400)}`)
    && !/套装|捆绑|组合装|[+＋]/.test(source.title)
    && !/\.(gov|edu)\.cn$/.test(new URL(source.url).hostname);
}

export function isPublicSourceUrl(value: string): boolean {
  try {
    const url = new URL(value);
    const host = url.hostname.toLowerCase();
    return ['http:', 'https:'].includes(url.protocol) && !url.username && !url.password
      && !isIP(host.replace(/^\[|\]$/g, '')) && host.includes('.')
      && !/(^|\.)(localhost|local|internal)$/.test(host)
      && (!url.port || ['80', '443'].includes(url.port));
  } catch { return false; }
}

const searchResponseSchema = z.object({ results: z.array(z.object({
  title: z.string(), url: z.string(), content: z.string().default(''),
  summary: z.string().default(''), snippet: z.string().default(''),
  date: z.string().nullable().optional(),
})) });

export async function searchPriceSources(
  query: MarketPriceRequest,
  config: AgentConfig,
  signal: AbortSignal,
  fetcher: typeof fetch = fetch,
): Promise<PriceSourceSearchResult> {
  if (new URL(config.baseUrl).hostname !== 'api.deepseek.com') throw new PriceSearchError();
  const post = async (path: string, body: unknown): Promise<unknown> => {
    try {
      const response = await fetcher(`https://api.deepseek.com/v1/tools/${path}`, {
        method: 'POST', redirect: 'error',
        headers: { Authorization: `Bearer ${config.apiKey}`, 'Content-Type': 'application/json' },
        body: JSON.stringify(body), signal: AbortSignal.any([signal, AbortSignal.timeout(15_000)]),
      });
      if (!response.ok) throw new PriceToolError('fetch_failed', `网页读取服务返回 HTTP ${response.status}，未取得有效内容。`);
      try { return await response.json(); }
      catch { throw new PriceToolError('invalid_response', accessMessages.invalid_response); }
    } catch (error) {
      if (error instanceof PriceToolError) throw error;
      const status = error instanceof Error && ['TimeoutError', 'AbortError'].includes(error.name) ? 'fetch_timeout' : 'fetch_failed';
      throw new PriceToolError(status, accessMessages[status]);
    }
  };
  const searches = await Promise.allSettled(platformSearchQueries(query.productName).map(async searchQuery =>
    searchResponseSchema.parse(await post('search', { query: searchQuery, count: 5, need_content: false }))));
  const batches = searches.filter(result => result.status === 'fulfilled').map(result => result.value.results);
  if (!batches.length) throw new PriceSearchError();
  const diagnostics: PlatformSearchDiagnostic[] = searches.map((result, index) => {
    const platform = ['京东', '淘宝', '天猫', '拼多多'][index]!;
    if (result.status === 'rejected') return { platform, status: 'failed', resultCount: 0, productPageCount: 0, message: '此平台的搜索请求失败。' };
    const results = result.value.results;
    const products = new Set(results.map(item => getPlatformProduct(item.url)?.canonicalUrl).filter(Boolean));
    return { platform, status: 'completed', resultCount: results.length, productPageCount: products.size,
      message: results.length === 0 ? '搜索未返回结果。' : products.size === 0 ? '搜索结果不含受支持的中国大陆商品详情链接，列表、海外及第三方页面均未采用。' : `找到${products.size}个受支持的平台商品详情链接。` };
  });
  // Alternate the platform result lists so one platform cannot fill every slot.
  const results = Array.from({ length: Math.max(...batches.map(batch => batch.length)) }, (_, index) =>
    batches.flatMap(batch => batch[index] ? [batch[index]!] : [])).flat();
  const unique = new Set<string>();
  const sources: PriceSource[] = [];
  for (const item of results) {
    const product = getPlatformProduct(item.url);
    if (!product || unique.has(product.canonicalUrl)) continue;
    unique.add(product.canonicalUrl);
    const date = item.date ? new Date(item.date) : null;
    sources.push({
      id: `source-${sources.length + 1}`,
      title: `${product.platform}商品 ${product.productId}`,
      url: product.canonicalUrl, platform: product.platform, productId: product.productId,
      publishedAt: date && Number.isFinite(date.getTime()) ? date.toISOString() : null,
      // Search snippets and indexed copies are discovery-only, never evidence.
      text: '', fetched: false, fetchedAt: null,
    });
    if (sources.length === 6) break;
  }
  // Every platform product page must be read now, regardless of search dates.
  await Promise.all(sources.map(async source => {
    try {
      const page = z.object({ title: z.string().optional(), content: z.string() }).parse(await post('fetch', { url: source.url }));
      const title = page.title?.trim() || source.title;
      const blocked = blockedPageStatus(title, page.content);
      source.accessStatus = blocked ?? (!page.content.trim() ? 'empty_content'
        : !/[¥￥]\s*\d|\d\s*元/.test(page.content) ? 'no_price' : 'readable');
      source.accessMessage = accessMessages[source.accessStatus];
      if (['readable', 'no_price'].includes(source.accessStatus)) {
        source.title = title.slice(0, 200);
        source.text = page.content.slice(0, 6000);
        source.fetched = true;
        source.fetchedAt = new Date().toISOString();
      }
    } catch (error) {
      source.accessStatus = error instanceof PriceToolError ? error.status : 'invalid_response';
      source.accessMessage = error instanceof PriceToolError ? error.message : accessMessages.invalid_response;
      // Keep the failure reason, but never use indexed snippets as price evidence.
    }
  }));
  return { sources, searches: diagnostics };
}
