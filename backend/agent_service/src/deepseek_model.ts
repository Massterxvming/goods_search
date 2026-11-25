import { OpenAIChatCompletionsModel } from '@openai/agents';
import type { ModelRequest } from '@openai/agents';

function prepareRequest(request: ModelRequest): ModelRequest {
  const outputType = request.outputType;
  const structuredOutput = outputType !== 'text';
  return {
    ...request,
    // DeepSeek supports json_object, while the SDK's schema output uses
    // json_schema. Keep the Agent's Zod validation in the Runner unchanged.
    outputType: 'text',
    systemInstructions: structuredOutput
      ? `${request.systemInstructions ?? ''}\n工具调用照常执行。最终答案必须是符合以下 JSON Schema 的 JSON 对象，不包含 Markdown：\n${JSON.stringify(outputType.schema)}`
      : request.systemInstructions,
    modelSettings: {
      ...request.modelSettings,
      providerData: {
        ...request.modelSettings.providerData,
        // The current planning task uses non-thinking mode so the tool loop
        // does not depend on provider-specific reasoning_content replay.
        thinking: { type: 'disabled' },
        ...(structuredOutput ? { response_format: { type: 'json_object' } } : {}),
      },
    },
  };
}

export class DeepSeekChatCompletionsModel extends OpenAIChatCompletionsModel {
  override getResponse(request: ModelRequest) {
    return super.getResponse(prepareRequest(request));
  }

  override getStreamedResponse(request: ModelRequest) {
    return super.getStreamedResponse(prepareRequest(request));
  }
}
