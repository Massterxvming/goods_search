import assert from 'node:assert/strict';
import { once } from 'node:events';
import type { AddressInfo } from 'node:net';
import { test } from 'node:test';
import type { TestContext } from 'node:test';

import { loadConfig, getStatus } from '../src/config.js';
import type { AgentConfig } from '../src/config.js';
import type { ResearchResult } from '../src/contracts.js';
import { createAgentServer } from '../src/http_server.js';

const query = {
  productName: '测试显卡型号', market: '中国大陆', currency: 'CNY',
  historyMonths: 12, forecastMonths: 3,
};

async function listen(t: TestContext, config: AgentConfig, runner?: Parameters<typeof createAgentServer>[1]) {
  const server = createAgentServer(config, runner);
  server.listen(0, '127.0.0.1');
  await once(server, 'listening');
  t.after(() => new Promise<void>((resolve, reject) => {
    server.close((error) => error ? reject(error) : resolve());
    server.closeAllConnections();
  }));
  return `http://127.0.0.1:${(server.address() as AddressInfo).port}`;
}

test('blank model configuration keeps the SDK healthy and prevents all model runs', async (t) => {
  let calls = 0;
  const url = await listen(t, loadConfig({}), async () => {
    calls++;
    throw new Error('This runner must never be called.');
  });
  const status = await (await fetch(`${url}/v1/status`)).json() as ReturnType<typeof getStatus>;
  assert.equal(status.sdkReady, true);
  assert.equal(status.modelConfigured, false);
  assert.equal(status.missingConfiguration.length, 3);

  const response = await fetch(`${url}/v1/research-plan`, {
    method: 'POST', headers: { 'Content-Type': 'application/json' }, body: JSON.stringify(query),
  });
  assert.equal(response.status, 503);
  const result = await response.json() as ResearchResult;
  assert.equal(result.status, 'not_configured');
  assert.equal(result.summary, null);
  assert.deepEqual(result.steps, []);
  assert.equal(calls, 0);
});

test('invalid research requests are rejected before any model call', async (t) => {
  const url = await listen(t, loadConfig({}));
  const response = await fetch(`${url}/v1/research-plan`, {
    method: 'POST', body: JSON.stringify({ ...query, historyMonths: 0 }),
  });
  assert.equal(response.status, 400);
  assert.equal(((await response.json()) as ResearchResult).status, 'invalid_request');
});

test('provider secrets are not included in status or upstream error responses', async (t) => {
  const secret = 'test-fixture-not-a-real-key';
  const config = loadConfig({
    AGENT_MODEL_BASE_URL: 'http://127.0.0.1:1/v1',
    AGENT_MODEL_NAME: 'test-only-model',
    AGENT_MODEL_API_KEY: secret,
  });
  const url = await listen(t, config, async () => { throw new Error(secret); });
  const status = await (await fetch(`${url}/v1/status`)).json() as ReturnType<typeof getStatus>;
  assert.equal(status.modelConfigured, true);
  const statusText = await (await fetch(`${url}/v1/status`)).text();
  assert.ok(!statusText.includes(secret));
  const response = await fetch(`${url}/v1/research-plan`, {
    method: 'POST', body: JSON.stringify(query),
  });
  assert.equal(response.status, 502);
  const resultText = await response.text();
  assert.ok(!resultText.includes(secret));
  assert.equal(JSON.parse(resultText).status, 'failed');
});

test('successful structured plans use the bridge contract', async (t) => {
  const config = loadConfig({
    AGENT_MODEL_BASE_URL: 'http://127.0.0.1:1/v1',
    AGENT_MODEL_NAME: 'test-only-model',
    AGENT_MODEL_API_KEY: 'test-only-key',
  });
  const url = await listen(t, config, async (received) => {
    assert.deepEqual(received, query);
    return { summary: '仅生成计划。', requiredData: ['历史价格来源'], steps: ['获取数据'] };
  });
  const response = await fetch(`${url}/v1/research-plan`, {
    method: 'POST', body: JSON.stringify(query),
  });
  assert.equal(response.status, 200);
  assert.equal(((await response.json()) as ResearchResult).status, 'planned');
});
