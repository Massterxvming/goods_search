import assert from 'node:assert/strict';
import { once } from 'node:events';
import { createServer } from 'node:http';
import type { AddressInfo } from 'node:net';
import { test } from 'node:test';
import OpenAI from 'openai';

import { runResearchPlan } from '../src/agent.js';
import { DeepSeekChatCompletionsModel } from '../src/deepseek_model.js';

const plan = {
  summary: '研究固定型号显卡的价格变化。',
  requiredData: ['带日期及来源的历史价格记录'],
  steps: ['确认规格与价格口径', '接入价格数据源'],
};

for (const validOutput of [true, false]) {
  test(`DeepSeek JSON mode executes a tool loop and ${validOutput ? 'accepts a valid plan' : 'rejects a plan with invalid fields'}`, async (t) => {
    const requests: Record<string, any>[] = [];
    const provider = createServer(async (request, response) => {
      const chunks: Buffer[] = [];
      for await (const chunk of request) chunks.push(Buffer.from(chunk));
      const body = JSON.parse(Buffer.concat(chunks).toString('utf8'));
      requests.push(body);
      if (body.response_format?.type !== 'json_object') {
        response.writeHead(400, { 'Content-Type': 'application/json' });
        response.end(JSON.stringify({ error: { message: 'This response_format type is unavailable now' } }));
        return;
      }
      const callTool = requests.length === 1;
      response.writeHead(200, { 'Content-Type': 'application/json' });
      response.end(JSON.stringify({
        id: `deepseek-fixture-${requests.length}`, object: 'chat.completion', created: 1,
        model: 'deepseek-flash',
        choices: [{ index: 0, finish_reason: callTool ? 'tool_calls' : 'stop', message: {
          role: 'assistant',
          content: callTool ? null : JSON.stringify(validOutput ? plan : { ...plan, requiredData: 123 }),
          ...(callTool ? { tool_calls: [{
            id: 'capabilities-call', type: 'function',
            function: { name: 'get_research_capabilities', arguments: '{}' },
          }] } : {}),
        } }],
        usage: { prompt_tokens: 10, completion_tokens: 10, total_tokens: 20 },
      }));
    });
    provider.listen(0, '127.0.0.1');
    await once(provider, 'listening');
    t.after(() => new Promise<void>((resolve, reject) => {
      provider.close((error) => error ? reject(error) : resolve());
      provider.closeAllConnections();
    }));
    const client = new OpenAI({
      baseURL: `http://127.0.0.1:${(provider.address() as AddressInfo).port}`,
      apiKey: 'local-fixture-key', maxRetries: 0,
    });
    const run = runResearchPlan({
      productName: '测试显卡型号', market: '中国大陆', currency: 'CNY',
      historyMonths: 12, forecastMonths: 3,
    }, new DeepSeekChatCompletionsModel(client, 'deepseek-flash'), AbortSignal.timeout(5_000));
    if (validOutput) {
      assert.deepEqual(await run, plan);
    } else {
      await assert.rejects(run);
    }
    assert.equal(requests.length, 2);
    for (const request of requests) {
      assert.deepEqual(request.response_format, { type: 'json_object' });
      assert.deepEqual(request.thinking, { type: 'disabled' });
      assert.match(request.messages[0].content, /JSON Schema/);
      assert.match(request.messages[0].content, /"requiredData"/);
    }
    const toolResult = requests[1]!.messages.find((message: { role: string }) => message.role === 'tool');
    assert.equal(toolResult.tool_call_id, 'capabilities-call');
    assert.equal(JSON.parse(toolResult.content).historicalPriceSourceConfigured, false);
  });
}
