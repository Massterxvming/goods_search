import assert from 'node:assert/strict';
import { once } from 'node:events';
import { createServer } from 'node:http';
import type { AddressInfo } from 'node:net';
import { test } from 'node:test';

import { createConfiguredModel, runResearchPlan } from '../src/agent.js';
import { loadConfig } from '../src/config.js';
import type { ModelApi } from '../src/config.js';

const plan = {
  summary: '本地协议测试返回的研究计划。',
  requiredData: ['真实历史价格记录'],
  steps: ['确认价格口径后接入数据源'],
};

for (const api of ['chat_completions', 'responses'] satisfies ModelApi[]) {
  test(`${api} adapter uses the configured model, URL and key against a local provider fixture`, async (t) => {
    let observedPath: string | undefined;
    let observedModel: unknown;
    let observedAuthorization: string | undefined;
    const provider = createServer(async (request, response) => {
      const chunks: Buffer[] = [];
      for await (const chunk of request) chunks.push(Buffer.from(chunk));
      const body = JSON.parse(Buffer.concat(chunks).toString('utf8'));
      observedPath = request.url;
      observedModel = body.model;
      observedAuthorization = request.headers.authorization;

      response.writeHead(200, { 'Content-Type': 'application/json' });
      response.end(JSON.stringify(api === 'chat_completions' ? {
        id: 'fixture-completion', object: 'chat.completion', created: 1,
        model: 'fixture-model',
        choices: [{ index: 0, finish_reason: 'stop', message: {
          role: 'assistant', content: JSON.stringify(plan),
        } }],
        usage: { prompt_tokens: 10, completion_tokens: 10, total_tokens: 20 },
      } : {
        id: 'fixture-response', object: 'response', created_at: 1,
        status: 'completed', model: 'fixture-model',
        output: [{ id: 'fixture-message', type: 'message', role: 'assistant',
          status: 'completed', content: [{ type: 'output_text', text: JSON.stringify(plan), annotations: [] }],
        }],
        usage: { input_tokens: 10, output_tokens: 10, total_tokens: 20,
          input_tokens_details: { cached_tokens: 0 }, output_tokens_details: { reasoning_tokens: 0 },
        },
      }));
    });
    provider.listen(0, '127.0.0.1');
    await once(provider, 'listening');
    t.after(() => new Promise<void>((resolve, reject) => {
      provider.close((error) => error ? reject(error) : resolve());
      provider.closeAllConnections();
    }));

    const config = loadConfig({
      AGENT_MODEL_API: api,
      AGENT_MODEL_BASE_URL: `http://127.0.0.1:${(provider.address() as AddressInfo).port}/v1`,
      AGENT_MODEL_NAME: 'fixture-model',
      AGENT_MODEL_API_KEY: 'local-test-fixture-key',
    });
    const result = await runResearchPlan({
      productName: '测试显卡型号', market: '中国大陆', currency: 'CNY',
      historyMonths: 12, forecastMonths: 3,
    }, createConfiguredModel(config), AbortSignal.timeout(5_000));

    assert.deepEqual(result, plan);
    assert.equal(observedPath, api === 'responses' ? '/v1/responses' : '/v1/chat/completions');
    assert.equal(observedModel, 'fixture-model');
    assert.equal(observedAuthorization, 'Bearer local-test-fixture-key');
  });
}
