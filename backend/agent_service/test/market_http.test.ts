import assert from 'node:assert/strict';
import { once } from 'node:events';
import type { AddressInfo } from 'node:net';
import { test } from 'node:test';

import { loadConfig } from '../src/config.js';
import { createAgentServer } from '../src/http_server.js';
import { emptyMarketReport } from '../src/market_price_contracts.js';
import type { MarketPriceReport } from '../src/market_price_contracts.js';

test('reuses identical market research, validates inputs, and blocks missing configuration', async t => {
  let calls = 0;
  const config = loadConfig({ AGENT_MODEL_BASE_URL: 'http://127.0.0.1:1', AGENT_MODEL_NAME: 'fixture', AGENT_MODEL_API_KEY: 'fixture' });
  const server = createAgentServer(config, undefined, async query => {
    calls++;
    return emptyMarketReport(query, 'insufficient_data', '没有足够报价。');
  });
  server.listen(0, '127.0.0.1');
  await once(server, 'listening');
  t.after(() => new Promise<void>((resolve, reject) => {
    server.close(error => error ? reject(error) : resolve());
    server.closeAllConnections();
  }));
  const url = `http://127.0.0.1:${(server.address() as AddressInfo).port}/v1/market-price`;
  const query = { productName: '测试鼠标', market: '中国大陆', currency: 'CNY' };
  const post = (body: unknown) => fetch(url, { method: 'POST', body: JSON.stringify(body) });
  const first = await (await post(query)).json() as MarketPriceReport;
  const second = await (await post(query)).json() as MarketPriceReport;
  assert.equal(first.status, 'insufficient_data');
  assert.equal(first.cached, false);
  assert.equal(second.cached, true);
  assert.equal(second.researchedAt, first.researchedAt);
  assert.equal(calls, 1);
  assert.equal((await post({ ...query, currency: 'USD' })).status, 400);
  assert.equal(calls, 1);
  config.missingConfiguration.push('AGENT_MODEL_API_KEY');
  assert.equal((await post(query)).status, 503);
  assert.equal(calls, 1);
});
