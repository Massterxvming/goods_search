import { createServer } from 'node:http';
import type { IncomingMessage, ServerResponse } from 'node:http';

import { createConfiguredModel, runResearchPlan } from './agent.js';
import { getStatus } from './config.js';
import type { AgentConfig } from './config.js';
import { emptyResult, researchRequestSchema } from './contracts.js';
import type { ResearchPlan, ResearchRequest } from './contracts.js';
import { emptyMarketReport, marketPricePolicyVersion, marketPriceRequestSchema } from './market_price_contracts.js';
import type { MarketPriceReport, MarketPriceRequest, MarketPriceStatus } from './market_price_contracts.js';
import { runMarketPriceResearch } from './market_price.js';
import { PriceSearchError } from './price_sources.js';

type PlanRunner = (query: ResearchRequest, signal: AbortSignal) => Promise<ResearchPlan>;
type MarketRunner = (query: MarketPriceRequest, signal: AbortSignal) => Promise<MarketPriceReport>;

function sendJson(response: ServerResponse, code: number, data: unknown) {
  response.writeHead(code, {
    'Content-Type': 'application/json; charset=utf-8',
    'Cache-Control': 'no-store',
    'X-Content-Type-Options': 'nosniff',
  });
  response.end(JSON.stringify(data));
}

function readBody(request: IncomingMessage): Promise<unknown> {
  return new Promise((resolve, reject) => {
    const chunks: Buffer[] = [];
    let length = 0;
    let rejected = false;
    request.on('data', (chunk: Buffer) => {
      length += chunk.length;
      if (length > 16_384) {
        rejected = true;
        reject(new Error('Invalid request body.'));
      }
      if (!rejected) chunks.push(chunk);
    });
    request.on('error', reject);
    request.on('end', () => {
      if (rejected) return;
      try {
        resolve(JSON.parse(Buffer.concat(chunks).toString('utf8')));
      } catch {
        reject(new Error('Invalid JSON.'));
      }
    });
  });
}

export function createAgentServer(config: AgentConfig, planRunner?: PlanRunner, marketRunner?: MarketRunner) {
  let activeRuns = 0;
  const executePlan = planRunner ?? ((query, signal) =>
    runResearchPlan(query, createConfiguredModel(config), signal));
  const executeMarket = marketRunner ?? ((query, signal) => runMarketPriceResearch(query, config, signal));
  const marketCache = new Map<string, { expires: number; report: MarketPriceReport }>();

  return createServer((request, response) => {
    const handle = async () => {
      if (request.method === 'GET' && request.url === '/health') {
        sendJson(response, 200, { sdkReady: true, modelConfigured: getStatus(config).modelConfigured });
        return;
      }
      if (request.method === 'GET' && request.url === '/v1/status') {
        sendJson(response, 200, getStatus(config));
        return;
      }
      if (request.method === 'POST' && request.url === '/v1/market-price') {
        let query: MarketPriceRequest = { productName: '', market: '中国大陆', currency: 'CNY' };
        const fail = (code: number, status: MarketPriceStatus, message: string) =>
          sendJson(response, code, emptyMarketReport(query, status, message));
        try {
          const parsed = marketPriceRequestSchema.safeParse(await readBody(request));
          if (!parsed.success) {
            fail(400, 'invalid_request', '请填写具体商品（2–120字），市场不能为空，目前支持人民币报价。');
            return;
          }
          query = parsed.data;
        } catch {
          fail(400, 'invalid_request', '查询参数不是有效的 JSON，或请求过大。');
          return;
        }
        if (config.missingConfiguration.length) {
          fail(503, 'not_configured', '模型 API 尚未配置，请先配置后端模型服务。');
          return;
        }
        const key = JSON.stringify([marketPricePolicyVersion, query.productName.toLowerCase().replace(/\s+/g, ' '), query.market, query.currency]);
        const cached = marketCache.get(key);
        if (cached && cached.expires > Date.now()) {
          sendJson(response, 200, { ...cached.report, cached: true });
          return;
        }
        if (activeRuns >= 2) {
          fail(429, 'busy', '研究服务正在处理其他请求，请稍后重试。');
          return;
        }
        activeRuns++;
        const controller = new AbortController();
        const timer = setTimeout(() => controller.abort(), 60_000);
        timer.unref();
        const onClose = () => { if (!response.writableEnded) controller.abort(); };
        response.on('close', onClose);
        try {
          const report = await executeMarket(query, controller.signal);
          if (!response.destroyed) {
            if (['completed', 'insufficient_data', 'needs_clarification'].includes(report.status)) {
              if (marketCache.size >= 50) marketCache.delete(marketCache.keys().next().value!);
              marketCache.set(key, { expires: Date.now() + (report.status === 'completed' ? 600_000 : 120_000), report });
            }
            sendJson(response, 200, report);
          }
        } catch (error) {
          if (!response.destroyed) {
            fail(controller.signal.aborted ? 504 : 502, 'failed', controller.signal.aborted
              ? '调研超时，请稍后重试。'
              : error instanceof PriceSearchError ? error.message : '调研暂未完成，请检查模型服务或稍后重试。');
          }
        } finally {
          clearTimeout(timer);
          response.off('close', onClose);
          activeRuns--;
        }
        return;
      }
      if (request.method !== 'POST' || request.url !== '/v1/research-plan') {
        sendJson(response, 404, { message: 'Not found.' });
        return;
      }

      let body: unknown;
      try {
        body = await readBody(request);
      } catch {
        sendJson(response, 400, emptyResult('invalid_request', '查询参数不是有效的 JSON，或请求过大。'));
        return;
      }
      const query = researchRequestSchema.safeParse(body);
      if (!query.success) {
        sendJson(response, 400, emptyResult('invalid_request', '请检查商品、市场、币种和查询月份。'));
        return;
      }
      if (config.missingConfiguration.length > 0) {
        sendJson(response, 503, emptyResult('not_configured', '模型 API 尚未配置，当前不会发起模型调用。'));
        return;
      }
      if (activeRuns >= 2) {
        sendJson(response, 429, emptyResult('busy', '研究服务正在处理其他请求，请稍后重试。'));
        return;
      }

      activeRuns++;
      const controller = new AbortController();
      const timer = setTimeout(() => controller.abort(), 30_000);
      timer.unref();
      const onClose = () => { if (!response.writableEnded) controller.abort(); };
      response.on('close', onClose);
      try {
        const plan = await executePlan(query.data, controller.signal);
        if (!response.destroyed) {
          sendJson(response, 200, {
            status: 'planned',
            message: '研究计划已生成；历史价格数据与预测服务尚未接入。',
            ...plan,
          });
        }
      } catch {
        if (!response.destroyed) {
          sendJson(response, controller.signal.aborted ? 504 : 502,
            emptyResult('failed', controller.signal.aborted
              ? '模型请求超时，请稍后重试。'
              : '模型请求失败，请检查供应商配置和兼容性。'));
        }
      } finally {
        clearTimeout(timer);
        response.off('close', onClose);
        activeRuns--;
      }
    };
    void handle().catch(() => {
      if (!response.headersSent && !response.destroyed) {
        sendJson(response, 500, emptyResult('failed', 'Agent 服务暂时无法处理请求。'));
      }
    });
  });
}
