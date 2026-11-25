import assert from 'node:assert/strict';
import { test } from 'node:test';
import { ScriptedModel, assistantMessage, functionCall } from '@openai/agents/testing';

import { runResearchPlan } from '../src/agent.js';

test('the real SDK Runner executes a function tool and parses a structured plan without an API key', async () => {
  const expected = {
    summary: '研究固定型号显卡在指定市场的价格变化。',
    requiredData: ['同型号同规格商品的带日期价格记录及来源'],
    steps: ['确认规格与价格口径', '接入历史价格数据源后再分析'],
  };
  const model = new ScriptedModel([
    [functionCall('get_research_capabilities', {}, { callId: 'capabilities-test' })],
    [assistantMessage(JSON.stringify(expected))],
  ]);
  const result = await runResearchPlan({
    productName: '测试显卡型号', market: '中国大陆', currency: 'CNY',
    historyMonths: 12, forecastMonths: 3,
  }, model, AbortSignal.timeout(5_000));

  assert.deepEqual(result, expected);
  assert.equal(model.calls.length, 2);
  assert.equal(model.firstCall?.request.tracing, false);
  assert.match(JSON.stringify(model.lastCall?.request.input), /historicalPriceSourceConfigured/);
  model.assertComplete();
});
