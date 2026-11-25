# goods_search

使用 FVM 管理 Flutter SDK 的 iOS / Android 应用，后端使用 Serverpod。
当前演示名称为“价迹”：底部首页 / 我的两个 Tab，首页四张分类卡片，点击进入
Demo 页面，个人页包含收藏、记录、设置等演示入口。

## 项目配置

| 配置 | 值 |
| --- | --- |
| Flutter | 3.35.7 stable，通过 `.fvmrc` 固定 |
| Dart | 3.9.2，随上述 Flutter SDK 提供 |
| Serverpod | 3.4.13，兼容当前 Flutter / Dart |
| Android 原生语言 | Kotlin |
| iOS 原生语言 | Swift |
| Android applicationId | `com.example.goods_search` |
| iOS bundle identifier | `com.example.goodsSearch` |
| 应用入口 | `lib/main.dart` |

发布前将示例应用标识改成自己的组织标识，并配置正式签名。

## 开始开发

在项目根目录运行：

```sh
fvm install
fvm use 3.35.7
fvm flutter pub get
fvm flutter devices
fvm flutter run -d <设备ID>
```

后续 Flutter / Dart 命令统一使用 `fvm flutter` / `fvm dart`。
提交 `.fvmrc` 和 `pubspec.lock`，`.fvm/` 中的本机 SDK 链接已被忽略。

VS Code 已配置 `.fvm/flutter_sdk`。Android Studio / IntelliJ IDEA 中，也将
Flutter SDK 路径指向项目内的 `.fvm/flutter_sdk`。

## 界面 Demo 与浏览器预览

项目增加了 Web 预览入口，与手机端共用同一套 Flutter UI。在根目录构建：

```sh
fvm flutter build web --no-web-resources-cdn --pwa-strategy=none
```

然后按下方步骤启动 PostgreSQL 和 Serverpod，打开 [界面预览](http://localhost:8082/)。
`8082` 是界面，`8080` 是后端 API。Serverpod 通过 FlutterRoute 提供 `build/web/`
中的文件，修改界面后重新构建并刷新浏览器即可。

首页的连接状态和个人页的重新连接按钮会真实调用 Serverpod 的 `greeting.hello`。
服务暂时不可用时，界面显示“离线演示”，仍可浏览和跳转。

手机端默认地址：iOS 模拟器使用 `localhost:8080`，Android 标准模拟器使用
`10.0.2.2:8080`。真机或其他环境可在 `fvm flutter run` 后附加
`--dart-define=SERVERPOD_URL=http://你的电脑IP:8080/`。Android 本地 HTTP 访问仅在
Debug manifest 中开启。

界面验证（2026-11-05）：静态分析、4 项组件测试和 Web 构建通过；已在浏览器中验证
分类进入 / 返回、Tab 切换、个人页 Demo 跳转及真实后端连接。组件测试覆盖小屏、
竖屏、横屏、宽屏，以及离线重试。

预览截图：[首页](docs/screenshots/home-mobile.png)、[个人页](docs/screenshots/profile-mobile.png)。

商品调研页支持近3个月、6个月、1年、2年和自定义起止月份，展示可切换的折线/柱状趋势、
月度明细、平台来源及有足够数据时的未来3个月简单预测。后端持久化核验价格快照，
历史缺口不会用模型猜测填充；尚未接入平台授权历史数据。详见[价格趋势说明](docs/current-price-research.md)。

## 检查与构建

```sh
fvm flutter doctor -v
fvm flutter analyze
fvm flutter test
fvm flutter build apk --debug
fvm flutter build ios --simulator --debug
```

初始化验证（2026-10-23）：静态分析、默认组件测试、Android Debug APK 和
iOS 模拟器 Debug 构建均已通过。

Android 构建需要 Android SDK 与 JDK；iOS 构建需要 Xcode 和对应的模拟器运行时。
此 Flutter 模板使用 NDK `27.0.12077973` 和 CMake `3.22.1`，缺失时可通过
Android Studio 的 SDK Manager 安装。
若 doctor 提示 Android licenses 未接受，请运行
`fvm flutter doctor --android-licenses`，阅读并处理提示。

若依赖下载报本地代理 `Connection refused`，请检查终端代理环境变量和系统代理设置。

## Serverpod 后端

服务端位于 `backend/goods_search_server/`，生成的 Dart 客户端位于
`backend/goods_search_client/`。它们与根 Flutter 工程组成 Dart workspace，运行
`fvm flutter pub get` 会统一安装依赖。

首次初始化本地数据库凭据：

```sh
fvm dart backend/tool/setup.dart
```

在 `backend/` 启动 PostgreSQL，再启动服务端：

```sh
docker compose up -d --wait
cd goods_search_server
fvm dart bin/main.dart --apply-migrations
```

开发 API 地址为 `http://localhost:8080/`。完整的 CLI 安装、协议生成、迁移和测试
命令见 [后端开发说明](backend/README.md)；产品分层与查询流程见
[架构设计](docs/architecture.md)。

Serverpod 初始化验证（2026-11-05）：依赖安装、协议生成、初始迁移、全项目静态
分析、Flutter 组件测试、后端集成测试及生成客户端的真实接口调用均已通过。

## Agents SDK

已接入官方 `@openai/agents` 0.21.0，由 `backend/agent_service/` 中的 TypeScript
服务运行，Serverpod 通过本地 HTTP 调用。模型 API 地址、型号及密钥先留空；当前
提供 SDK 状态查询和研究计划接口，没有配置模型时不会发起真实模型调用。

SDK 配置文件为 `backend/agent_service/.env`（已忽略，不提交）。启动命令、
可选模型协议以及生成客户端示例见 [Agents SDK 接入说明](backend/agent_service/README.md)。

## 项目内 Flutter / Dart skills

以下 skills 由 Flutter 或 Dart 团队维护，已安装到项目内的 `.agents/skills/`。

| Skill | 适合的工作 |
| --- | --- |
| [flutter-apply-architecture-best-practices](https://github.com/flutter/agent-plugins/blob/main/skills/flutter-apply-architecture-best-practices/SKILL.md) | 划分 UI、业务逻辑和数据层，组织新项目 |
| [flutter-build-responsive-layout](https://github.com/flutter/agent-plugins/blob/main/skills/flutter-build-responsive-layout/SKILL.md) | 适配手机、平板和不同屏幕尺寸 |
| [flutter-setup-declarative-routing](https://github.com/flutter/agent-plugins/blob/main/skills/flutter-setup-declarative-routing/SKILL.md) | 配置 go_router、页面路由和深链接 |
| [flutter-add-widget-test](https://github.com/flutter/agent-plugins/blob/main/skills/flutter-add-widget-test/SKILL.md) | 测试组件渲染、点击、输入和滚动 |
| [flutter-add-integration-test](https://github.com/flutter/agent-plugins/blob/main/skills/flutter-add-integration-test/SKILL.md) | 测试搜索、详情等完整用户流程 |
| [dart-resolve-package-conflicts](https://github.com/dart-lang/skills/blob/main/skills/dart-resolve-package-conflicts/SKILL.md) | 排查 pub get 的依赖版本冲突 |

完整目录：[Flutter 官方 skills](https://github.com/flutter/agent-plugins)、
[Dart 官方 skills](https://github.com/dart-lang/skills)。
