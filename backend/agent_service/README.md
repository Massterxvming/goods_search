# Agents SDK 接入

项目已接入官方 `@openai/agents` **0.21.0**。Serverpod 继续作为业务后端，
一个独立 TypeScript 进程运行官方 SDK：

```text
Flutter 生成客户端
  → Serverpod AgentEndpoint（8080）
  → 本地 TypeScript Agents SDK 服务（127.0.0.1:8093）
  → DeepSeek API（deepseek-flash）
```

SDK 不放进 Flutter App，也不直接从客户端访问模型供应商。
当前接入的是 SDK、配置状态查询、工具调用和研究计划生成，以及独立的当前商品
购物平台在售价调研接口。后者已对接 DeepSeek Search/Fetch，仅接收京东、淘宝、
天猫、拼多多商品详情页，强制实时读取，资讯/比价转载和搜索摘要均不作为价格证据。
通过模型整理证据，后端计算
样本均价。Serverpod 另提供24个月内的月度采样查询、持久化和简单线性预测；
尚未接入平台授权历史数据，缺失月份不补造。研究计划接口自身不会返回价格曲线。

## 当前状态

- 本地 `.env` 已配置 DeepSeek，使用 `deepseek-flash`；真实密钥只保存在被 Git 忽略的本地文件中，文件权限为 `600`。
- `.env.example` 提供无密钥的 DeepSeek 配置，新环境仍需自行填写 API Key。
- SDK 服务在没有密钥时也能启动并响应状态查询。
- 模型配置不完整时，研究请求返回 `not_configured`，不会执行模型调用。
- 没有默认模型，也不会读取 `OPENAI_API_KEY` 自动选择 OpenAI 模型。
- 默认关闭 SDK tracing；不会隐式向 OpenAI 上传运行记录。
- 已通过真实 DeepSeek 工具调用及结构化研究计划验证；自动化测试仍使用本地 HTTP 替身和 SDK 官方 ScriptedModel，不消耗模型额度。

## 安装与启动

需要 Node **22.19+**，项目用 `.nvmrc` 固定开发版本 `22.19.0`。
项目脚本优先使用本机已安装的该版本，再查找兼容的 Node，不修改全局 Node 配置。
也可以通过 `AGENT_NODE_BIN` 指定 Node 可执行文件。

在项目根目录运行：

```sh
# 按 package-lock.json 安装依赖
bash backend/tool/agent.sh ci

# 编译 TypeScript
bash backend/tool/agent.sh run build

# 启动 SDK 服务；本地地址为 http://127.0.0.1:8093/
bash backend/tool/agent.sh start
```

脚本在 `.env` 不存在时从 `.env.example` 创建一份空模型配置，保留已有文件。
按 `Ctrl+C` 停止这个进程。Serverpod 在另一个终端按 [后端说明](../README.md) 启动。
SDK 服务未启动时，Serverpod 仍可运行 UI Demo，并将 Agent 状态报告为不可用。

## 模型配置

本目录中已被 Git 忽略的 `.env` 使用以下配置；实际密钥只在本地填写：

```dotenv
AGENT_MODEL_BASE_URL=https://api.deepseek.com
AGENT_MODEL_NAME=deepseek-flash
AGENT_MODEL_API_KEY=<仅在本地填写>
AGENT_MODEL_API=chat_completions
AGENT_PORT=8093
```

`AGENT_MODEL_BASE_URL` 使用供应商的 API 根路径，DeepSeek 使用 `https://api.deepseek.com`。
`AGENT_MODEL_API` 支持：

| 值 | SDK 适配方式 |
| --- | --- |
| `chat_completions` | OpenAI Chat Completions 兼容接口，适配第三方模型的预留路径 |
| `responses` | OpenAI Responses 或已验证兼容的接口 |

配置完成后重新启动 Agent 服务。状态中的 `modelConfigured=true` 仅代表配置字段
已填写且格式有效，不代表已成功连接供应商。实际使用前还需要验证目标型号的
工具调用和结构化输出兼容性。

DeepSeek Chat Completions 使用 `src/deepseek_model.ts` 做协议适配：将 SDK 默认的
`json_schema` 输出格式转换为供应商支持的 `json_object`，同时把输出 Schema 加入
任务指令，最终结果仍由 SDK Runner 和 Zod 校验。当前研究规划任务显式关闭
DeepSeek thinking，避免工具循环依赖额外的 `reasoning_content` 回传。
该适配仅针对 `api.deepseek.com` 的 Chat Completions，不改变其他供应商的适配器。

模型配置只保存在服务端，不要使用 Flutter 的 `--dart-define` 传递模型密钥。
如果要修改 Serverpod 连接 Agent 服务的地址，设置 Serverpod 进程的
`AGENT_SERVICE_URL`，默认 `http://127.0.0.1:8093/`。

## Serverpod 调用

已生成对应的 Dart 类型和客户端方法：

```dart
import 'package:goods_search_client/goods_search_client.dart';

final client = Client('http://localhost:8080/');
final status = await client.agent.status();

final result = await client.agent.planResearch(PriceResearchRequest(
  productName: '要查询的具体显卡型号',
  market: '中国大陆',
  currency: 'CNY',
  historyMonths: 12,
  forecastMonths: 3,
));
client.close();
```

当前报价调研使用 `client.agent.currentPrice(MarketPriceRequest(
productName: '罗技 G102 二代 有线鼠标', market: '中国大陆', currency: 'CNY'))`。
SDK 本地接口为 `POST /v1/market-price`，请求字段与上面的三个字段一致。
它依次调用 DeepSeek Search/Fetch、Agents SDK 证据抽取、后端校验与均价计算；
不使用模型记忆中的价格。四个平台分别检索、实时读取最多6个详情页，
不可读取或需登录/验证时不采价。当前数据是平台页面在售价，并非授权订单成交价。
该接口超时60秒，共享2个并发名额；成功结果缓存10分钟，
样本不足或需澄清的结果缓存2分钟。缓存仅在进程内保存，重启后清空。
完整口径、返回字段和限制见 [当前报价调研](../../docs/current-price-research.md)。

`status()` 返回 SDK 服务是否可用、SDK 是否就绪、模型配置是否填写及缺少的配置项，
不返回密钥。调用该方法不会请求模型。

`planResearch()` 在缺少模型配置时返回：

```json
{
  "status": "not_configured",
  "message": "模型 API 尚未配置，当前不会发起模型调用。",
  "summary": null,
  "requiredData": [],
  "steps": []
}
```

其他业务状态包括：`service_unavailable`、`invalid_request`、`busy`、`failed`、
`planned`。`planned` 表示研究计划生成成功，不表示已完成查价或预测。

## Agent 的职责

`src/agent.ts` 定义 Agent、中文任务规则、结构化输出、模型选择及 SDK Runner。
`src/deepseek_model.ts` 定义 DeepSeek 的 JSON 输出和非 thinking 模式适配。
规划接口的工具 `get_research_capabilities` 表示该规划 Agent 可直接使用的能力，
它没有历史价格、联网检索或预测工具。当前报价调研通过独立接口运行检索流程。
规划 Agent 只能整理数据需求和执行计划，不得声称自己已检索或编造价格。

配置模型后的单次计划请求最多 4 轮模型交互，每轮最多 1500 输出 Token，
超时 30 秒，最多同时处理 2 个请求，供应商客户端不自动重试。
这些是运行边界，实际费用仍取决于选定供应商和模型。

## 检查与测试

```sh
bash backend/tool/agent.sh test

# 本地状态检查，不需要模型密钥
curl http://127.0.0.1:8093/v1/status
```

验证（2026-11-16）：TypeScript 编译和 21 项 SDK / HTTP 测试通过，覆盖真实 Runner
的工具调用循环、结构化输出、空配置阻断、输入校验、错误处理，以及两种 API 适配
路径到本地供应商替身的请求。新增 DeepSeek JSON 模式下的完整工具循环、合法计划
接收和字段类型错误拒绝测试。
当前报价功能另覆盖金额计算、证据一致性、过期报价、去重、团购与套装排除、
异常报价筛选、查询缓存、输入校验和搜索失败时的密钥保护。

真实供应商验证（2026-11-16）：通过生成的 Dart 客户端完成
`Serverpod → 本地 SDK 服务 → DeepSeek` 调用链。查询条件为
`NVIDIA GeForce RTX 4060 8GB 显卡 / 中国大陆 / CNY / 历史12个月 / 展望3个月`，
返回 `planned`，包含中文摘要、数据需求和6个研究步骤，完整请求耗时约6.5秒。
供应商日志确认第1轮调用 `get_research_capabilities`，第2轮返回通过校验的 JSON；
两轮共输入1251 Token、输出681 Token，合计1932 Token。
本次验证仅证明模型接入、工具循环和研究计划生成成功，未检索价格或执行预测。

原有第三方报道示例的92.60元已不符合当前采价规则，不再作为有效报告。
新版真实联调查询罗技 G102：找到5个京东商品详情页，但未取得可核验的在售价，
正确返回 `insufficient_data`、空报价和空均价，保留平台商品链接；没有用资讯价格补齐。
Serverpod 8项桥接单元测试、Flutter 9项测试、全项目静态分析及 Web 构建通过。
验证截图及完整口径见 [当前报价说明](../../docs/current-price-research.md)。

此前验证（2026-11-10）：Serverpod 5项桥接单元测试和既有集成测试、Flutter
4项组件测试、全项目静态分析均通过；空配置时返回 `not_configured` 的链路亦已验证。

## 官方资料

- [Agents SDK 快速入门](https://developers.openai.com/api/docs/guides/agents/quickstart)
- [模型和供应商配置](https://developers.openai.com/api/docs/guides/agents/models)
- [DeepSeek API 接入](https://api-docs.deepseek.com/)
- [DeepSeek JSON 输出](https://api-docs.deepseek.com/guides/json_mode/)
- [DeepSeek 工具调用](https://api-docs.deepseek.com/guides/tool_calls/)
- [DeepSeek Search / Fetch](https://api-docs.deepseek.com/guides/search/)
