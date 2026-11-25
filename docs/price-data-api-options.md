# 商品价格数据 API 调研

调研日期：2026-11-19。

本次核实公开的官方文档和文档元数据，没有使用购物网站页面脚本采集价格，也没有获取或导出购物账号的登录凭据。项目尚未配置下列平台的开发者凭据，因此本次结果不代表已完成带签名的商品价格请求。文档示例价格不是实测报价。

## 建议

- 国内当前商品价格：优先评估淘宝联盟和京东联盟的商品接口，先确认目标商品、SKU 和应用场景的权限及覆盖范围。
- 国内过去两年的价格：另行获取有授权的历史数据，或从接入日起定时存储快照。本次核实的联盟现价接口不能直接当作两年历史序列使用。
- 如果接受 Amazon 市场：Keepa 已明确提供商品历史价格 API，可以作为历史图表的数据源，但它是第三方数据服务，需要单独订阅，不代表中国电商价格。
- 大模型负责识别商品、解释统计结果和生成分析，价格数值应来自结构化数据源。缺失历史数据保持缺失。

## 1. 京东：京东联盟商品 API

已在京东官方开放平台的公开文档元数据中核实：

- 接口：`jd.union.open.goods.jingfen.query`，京粉精选商品查询。
- 覆盖：精选商品池；不能据此假定可以查询京东任意商品。
- 价格字段包括 `priceInfo.price`（商品价格）、`lowestPrice`（促销相关价格）、`lowestCouponPrice`（券后价格）。还存在拼购、预售、会员等价格信息，必须分别保存口径。
- `historyPriceDay` 描述当前券后价在多少天内属于最低价；它不是逐日历史价格列表，不能用来还原一条历史曲线。

接入需要开发者/联盟应用凭据以及相应 API 权限，接口覆盖、额度和商业使用条件需要在应用控制台确认。普通购物账号登录不能代替应用凭据。

后续还可以在官方控制台核实 `jd.union.open.goods.query`（关键词搜索路线）和 `jd.union.open.goods.promotiongoodsinfo.query`（指定商品信息路线）。本次未成功完成这两项的当前官方完整 schema 核验，不能将它们标成已联调通过。

来源：[京东联盟官方接口文档](https://union.jd.com/openplatform/api/v2?apiName=jd.union.open.goods.jingfen.query)。

## 2. 淘宝/天猫：淘宝联盟搜索与详情升级版

已核实官方文档：

| 用途 | 接口 | 与本项目相关的内容 |
| --- | --- | --- |
| 搜索 | `taobao.tbk.dg.material.optional.upgrade` | `q` 查询词、类目和价格筛选，获得商品候选 |
| 详细信息 | `taobao.tbk.item.details.upgrade.get` | 商品及 SKU 信息、销售价、预估到手价和优惠条件 |

详情响应注明只包含淘宝客商品，字段取决于 API 赋权等级。SKU 的 `sku_zk_final_price` 是销售价格；`sku_final_promotion_price` 是预估到手价，不能标成已经支付的订单成交价。

开发者仍需要 `app_key`、应用密钥与签名，以及对应接口权限。文档的“免费”“不需要授权”标签不表示可以匿名请求：它不免除应用身份和接口赋权要求。搜索还涉及推广位信息。消费者比价场景使用 `biz_scene_id=2`，部分搜索结果、商品 ID 和链接的输出受该场景权限影响。

这条路线适合项目的“关键词 → 选择具体商品/SKU → 当前价格”流程。已核实的接口没有给出逐月两年历史价格序列。

来源：[搜索升级版](https://developer.alibaba.com/docs/api.htm?apiId=64759)、[详情升级版](https://developer.alibaba.com/docs/api.htm?apiId=64757)。

## 3. 拼多多：多多进宝开放接口，当前详细权限待核实

拼多多官方历史说明文档明确列出：

- `pdd.ddk.goods.search`：商品搜索。
- `pdd.ddk.goods.detail`：商品详情。
- 搜索、详情等流程使用 `goods_sign`，不能假定只有普通商品 ID 就足够。

这是值得继续申请和验证的官方 API 路线。需要注意：本次能够核实其存在的说明文件位于官方 2021 年资料路径；当前开放平台文档为动态页面，本次未完整取得这两个接口的最新字段和赋权要求。因此，不能承诺当前应用可以直接调用，也不能在未核验最新 schema 前固定价格字段、SKU 精度、额度、收费或全站覆盖范围。

接入前在多多进宝/开放平台控制台核实开发者应用凭据、接口权限、推广位及场景备案要求。商品最低 SKU 价格如被返回，也不能自动视为用户选中的具体规格价格。

来源：[官方搜索文档入口](https://open.pinduoduo.com/application/document/api?id=pdd.ddk.goods.search)、[官方详情文档入口](https://open.pinduoduo.com/application/document/api?id=pdd.ddk.goods.detail)、[官方 goods_sign 说明 PDF（2021 年路径）](https://commoncdn.yangkeduo.com/pdd_oms/2021-01-12/2e22638bda0b0f77479f89dab1de2988.pdf)。

## 4. Keepa：明确可接入的 Amazon 历史价格 API

Keepa 是独立的数据提供商，覆盖 Amazon 市场，不是京东、淘宝、拼多多的官方接口。

- 基地址：`https://api.keepa.com/`。
- 关键词搜索：`GET /search?type=product`。
- 商品与历史：`GET /product`，传入 API Key、Amazon 站点 `domain` 和商品 `asin`。
- `history=1` 返回历史字段；`days=730` 可将返回历史限制到最近 730 天。
- 两年范围不等于每个商品都有两年完整记录，必须检查跟踪起点、更新时间和缺失段。
- 需要付费 API 订阅，按请求的 token 用量和套餐速率计量；与大模型的 token 费用分开。

请求结构示意，不含真实凭据，也没有在本次调研中执行：

```text
GET https://api.keepa.com/product?key=YOUR_KEEPA_KEY&domain=1&asin=TARGET_ASIN&history=1&days=730
```

来源：[API 概览](https://keepa.com/api-docs/)、[商品历史参数](https://keepa.com/api-docs/product.html)、[订阅和 token 计量](https://keepa.com/api-docs/plans-tokens.html)。

## 5. eBay：官方商品搜索及现价 API

- 接口：`GET https://api.ebay.com/buy/browse/v1/item_summary/search`。
- 支持关键词、类目等搜索，可以返回在售商品及价格，再通过商品详情接口取得更多信息。
- 接入需要开发者应用和 OAuth token；生产环境权限、额度及使用要求需要单独确认。
- 适合海外市场当前价格查询，不应将海外币种、二手商品、运费等直接混入国内新品价格统计。
- 本次核实的 Browse 搜索/详情接口不是两年成交价历史接口。

来源：[官方搜索接口](https://developer.ebay.com/develop/api/buy/browse_api/item/search)、[官方商品发现与刷新指南](https://developer.ebay.com/develop/guides/buy/inventory-discovery-and-refresh-guide)。

## 6. 国内历史数据商候选：慢慢买

慢慢买公开的历史价格查询服务明确支持京东、淘宝、天猫、拼多多等商品链接，说明其有可供评估的国内历史价格覆盖。其说明也明确价格综合了优惠券、满减、活动与用户爆料，因此不是统一口径的纯平台销售价或已支付订单价。

本次没有核实到可立即注册调用的现行公开 API 文档、套餐和密钥申请流程。应将其列为商业合作候选，不能将消费者网页查询接口当成已获授权的开发者 API。

洽谈时需要确认：是否提供服务端 API、目标 SKU 的历史跨度与采样频率、价格和优惠口径、记录来源与可追溯性、缓存及二次展示授权、更新延迟、费用和服务稳定性。

来源：[慢慢买官方历史价格查询及说明](https://tool.manmanbuy.com/historylowest.aspx)。

## 对现有项目的接入设计

```text
Flutter 选择商品/SKU及时间范围
  → Serverpod 价格数据接口
  → 对应平台 PriceProvider
  → 规格匹配、价格口径校验、去重、存储快照
  → 样本统计和历史聚合
  → Agent 解释结果与生成预测说明
```

推荐先实现一个有真实权限的平台，验证目标商品覆盖，再扩展其他来源。平台密钥放在服务端配置，不放入 Flutter 安装包；现有 DeepSeek 凭据与电商平台凭据分别配置。

每条报价至少记录来源、商品 ID、SKU/规格、商家、币种、价格类型、优惠条件、采集时间、源更新时间和商品链接。相同型号但容量、成色、套装不同的报价不应直接平均；平台最低 SKU 价格也不能代替目标 SKU 价格。

界面将统计结果标为“样本均价/中位价”，展示样本量、范围和更新时间。这些商品报价不能直接标为“全平台实际成交均价”。如果业务必须统计实际成交价，需要另行评估有授权的订单数据及其代表性。

没有历史记录的月份显示缺失；预测与观测数据分开。平台给出的“近 N 天最低价”等标签不能用于补齐逐月曲线。模型也不能补造报价或历史点。

本次仅增加调研文档，没有修改应用数据源、购买服务或完成带凭据的价格 API 联调。
