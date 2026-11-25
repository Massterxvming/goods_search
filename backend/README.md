# Serverpod 后端

现有 Flutter 应用仍在仓库根目录。后端按 Serverpod 3.4.13 官方模板初始化，使用
项目 FVM 固定的 Flutter 3.35.7 / Dart 3.9.2。

Serverpod CLI、服务端、生成客户端和 Flutter 集成包统一固定为 `3.4.13`。
Serverpod 4.x 需要更新的 Flutter / Dart，当前项目先使用兼容现有 SDK 的版本。

## 目录

```text
goods_search/
  lib/                                  # 现有 Flutter 应用
  pubspec.yaml                          # Flutter 依赖及 Dart workspace
  pubspec.lock                          # 整个 workspace 的依赖锁文件
  backend/
    goods_search_server/
      bin/main.dart                     # 后端入口
      lib/server.dart                   # Serverpod 启动
      lib/src/greetings/                # 官方示例接口及序列化模型
      lib/src/generated/                # 生成的服务端协议与接口分发
      config/                           # 开发、测试及部署环境模板
      migrations/                       # 数据库迁移
      test/integration/                 # 示例接口集成测试
    goods_search_client/
      lib/                              # 生成的 Dart 客户端
    agent_service/                      # TypeScript Agents SDK 服务
    tool/agent.sh                       # 使用兼容 Node 启动、编译和测试 SDK
    tool/setup.dart                     # 初始化本地数据库凭据
    tool/serverpod.sh                   # 使用项目 SDK 执行 Serverpod CLI
    docker-compose.yaml                 # 开发 / 测试 PostgreSQL
```

当前包含可调用的 `greeting.hello` 示例接口、Agent 研究计划接口和商品平台在售价
样本均价调研接口，以及最近24个月的历史采样查询、持久化和简单预测。
商品目录、授权平台历史数据和完整报告持久化仍待实现；
具体设计见 [架构草案](../docs/architecture.md)。
Flutter 双 Tab Demo 已调用该接口展示连接状态，并提供手动重试。

## Agents SDK

官方 Agents SDK 已通过独立 TypeScript 服务接入。Serverpod 提供
`client.agent.status()` 和 `client.agent.planResearch(...)`，对应 Dart 类型已生成。
另提供 `client.agent.currentPrice(MarketPriceRequest(...))`：通过 DeepSeek 检索
京东、淘宝、天猫、拼多多商品详情页的当前在售价，再由后端计算样本均价。
资讯/比价转载、搜索摘要和不可读取商品页不作为价格证据；未取得足够样本则不返回均价。
结果包含平台、商品ID、读取时间、原文和口径。当前尚未接入授权订单成交数据。
Flutter 首页四个分类均可进入调研表单，完整说明见
[当前报价调研](../docs/current-price-research.md)。
本地已配置 DeepSeek `deepseek-flash`，并通过生成的 Dart 客户端验证真实研究计划请求。
真实密钥只保存在被忽略的 `agent_service/.env`；仓库示例不包含密钥。
缺少配置的新环境仍返回 `not_configured`。

`client.agent.priceHistory(PriceHistoryRequest(...))` 接收明确的起止月份，返回
`MarketPriceReport.history`：逐月采样均价、原文来源、区间涨跌及简单预测。
包含本月时刷新当前报价并去重存入 PostgreSQL；仅查询过去月份时不调用今日采价。
每月不足3个商品ID则保持空值，至少3个连续有效月份截至本月时才线性外推未来3个月。
历史库由真实查询采样开始积累，不能从今日商品页还原过去两年的价格。
新增迁移 `20261117145332670` 只创建价格快照表与索引，不修改既有数据。

在项目根目录启动 SDK 服务：

```sh
bash backend/tool/agent.sh ci
bash backend/tool/agent.sh run build
bash backend/tool/agent.sh start
```

再在另一个终端按下文启动 Serverpod。完整配置、接口约定和测试说明见
[Agents SDK 接入说明](agent_service/README.md)。

## 初始化

在项目根目录运行：

```sh
fvm install
fvm dart pub global activate serverpod_cli 3.4.13
fvm flutter pub get
fvm dart backend/tool/setup.dart
```

根目录是 Dart workspace；一次 `pub get` 会下载 Flutter、后端和客户端的依赖。
CLI 单独安装，以避免它的代码生成工具依赖与 Flutter SDK 固定的依赖相互影响。

`setup.dart` 生成匹配的 `backend/.env` 和
`backend/goods_search_server/config/passwords.yaml`，已存在时保留原值。
两个文件均被 Git 忽略；应成对保存与恢复。PostgreSQL 数据卷初始化后会保留数据库
密码，不能仅重新生成文件来修改已有数据库的密码。

## 启动开发服务

先启动 Docker Desktop，然后在 `backend/` 目录运行：

```sh
docker compose up -d --wait
cd goods_search_server
fvm dart bin/main.dart --apply-migrations
```

启动命令默认使用 `development` 配置，应用已有迁移后启动服务。

| 服务 | 本地地址 |
| --- | --- |
| Serverpod API | `http://localhost:8080/` |
| Serverpod Insights | `http://localhost:8081/` |
| Flutter 界面预览 | `http://localhost:8082/` |
| 本地 Agents SDK 服务 | `http://127.0.0.1:8093/`，由 Serverpod 调用 |
| 开发 PostgreSQL | `127.0.0.1:8090`，数据库 `goods_search`，用户 `postgres` |
| 测试 PostgreSQL | `127.0.0.1:9090`，数据库 `goods_search_test`，用户 `postgres` |

Web server 使用 FlutterRoute 提供项目根目录 `build/web/` 的构建文件。
启动前在项目根目录执行 `fvm flutter build web --no-web-resources-cdn --pwa-strategy=none`，
然后访问 `http://localhost:8082/`。修改 UI 后重新构建并刷新浏览器。
development 模式的 Flutter 静态资源使用 `no-store`，避免预览继续读取旧版本脚本。
部署时可以通过 `GOODS_SEARCH_WEB_DIR` 环境变量指定构建目录。

Redis 按官方配置保持关闭，当前无需安装或启动。
`staging.yaml` 和 `production.yaml` 是官方部署占位配置，正式部署时再填写真实地址和凭据。

按 `Ctrl+C` 停止后端；在 `backend/` 执行 `docker compose --profile test stop` 可停止
本项目的数据库并保留数据卷。

## 生成接口与创建迁移

在项目根目录运行：

```sh
# 修改 Endpoint 或 .spy.yaml 模型后重新生成协议、客户端和测试工具
bash backend/tool/serverpod.sh generate

# 修改数据库模型后创建新的迁移，再重启后端应用迁移
bash backend/tool/serverpod.sh create-migration
```

生成文件不要手工修改。根 Flutter 工程已经通过 path 依赖引用
`goods_search_client`，同时声明了 `serverpod_flutter`，后续可以直接调用生成的客户端。
Flutter 页面已通过 Service / Repository / ViewModel 分层调用示例接口，
首页和个人页共享真实连接状态。

## 检查与测试

在项目根目录运行静态分析和现有 Flutter 测试：

```sh
fvm flutter analyze
fvm flutter test --no-pub
```

后端集成测试使用独立的测试数据库，在 `backend/` 运行：

```sh
docker compose --profile test up -d --wait
cd goods_search_server
fvm dart test
```

初始化验证（2026-11-05）已通过：workspace 依赖安装、协议及客户端代码生成、
开发 / 测试数据库初始迁移、全项目静态分析、Flutter 默认组件测试、后端示例接口
集成测试，以及使用生成客户端进行的真实 HTTP RPC 调用。

## Flutter 访问本地后端

- iOS 模拟器：`http://localhost:8080/`。
- Android 标准模拟器：`http://10.0.2.2:8080/`。
- 真机：使用开发电脑在同一局域网中的 IP 地址。

可以通过 Flutter 的 `--dart-define=SERVERPOD_URL=...` 覆盖默认地址。
Android Debug 已允许本地 HTTP；iOS 已配置本地网络访问。正式环境使用 HTTPS。

## 官方资料

- [Serverpod 3.4.13](https://pub.dev/packages/serverpod/versions/3.4.13)
- [Serverpod CLI 版本与 SDK 要求](https://pub.dev/packages/serverpod_cli/versions)
- [Serverpod 文档](https://docs.serverpod.dev/)
