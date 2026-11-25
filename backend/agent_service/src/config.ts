export type ModelApi = 'chat_completions' | 'responses';

export interface AgentConfig {
  baseUrl: string;
  modelName: string;
  apiKey: string;
  api: ModelApi;
  port: number;
  missingConfiguration: string[];
}

export function loadConfig(env: NodeJS.ProcessEnv = process.env): AgentConfig {
  const baseUrl = env.AGENT_MODEL_BASE_URL?.trim() ?? '';
  const modelName = env.AGENT_MODEL_NAME?.trim() ?? '';
  const apiKey = env.AGENT_MODEL_API_KEY?.trim() ?? '';
  const api = env.AGENT_MODEL_API?.trim() || 'chat_completions';
  const missingConfiguration: string[] = [];
  for (const [name, value] of [
    ['AGENT_MODEL_BASE_URL', baseUrl],
    ['AGENT_MODEL_NAME', modelName],
    ['AGENT_MODEL_API_KEY', apiKey],
  ]) {
    if (!value) missingConfiguration.push(name!);
  }
  if (baseUrl) {
    try {
      const url = new URL(baseUrl);
      if (!['http:', 'https:'].includes(url.protocol) || url.username || url.password || url.search || url.hash) {
        missingConfiguration.push('AGENT_MODEL_BASE_URL');
      }
    } catch {
      missingConfiguration.push('AGENT_MODEL_BASE_URL');
    }
  }
  if (api !== 'chat_completions' && api !== 'responses') {
    missingConfiguration.push('AGENT_MODEL_API');
  }
  const port = Number(env.AGENT_PORT?.trim() || 8093);
  if (!Number.isInteger(port) || port < 1 || port > 65535) {
    throw new Error('AGENT_PORT must be an integer between 1 and 65535.');
  }
  return {
    baseUrl, modelName, apiKey,
    api: api === 'responses' ? 'responses' : 'chat_completions',
    port,
    missingConfiguration: [...new Set(missingConfiguration)],
  };
}

export function getStatus(config: AgentConfig) {
  return {
    serviceAvailable: true,
    sdkReady: true,
    modelConfigured: config.missingConfiguration.length === 0,
    missingConfiguration: config.missingConfiguration,
    message: config.missingConfiguration.length === 0
      ? 'Agents SDK 已就绪，模型配置已填写；此状态接口不检测供应商连接。'
      : 'Agents SDK 已就绪，模型尚未配置。',
  };
}
