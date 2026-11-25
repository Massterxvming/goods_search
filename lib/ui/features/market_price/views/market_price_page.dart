import 'dart:async';

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../data/repositories/market_price_repository.dart';
import '../../../../domain/models/current_price_report.dart';
import '../view_models/market_price_view_model.dart';
import '../../platform_login/views/platform_login_page.dart';
import 'price_range_selector.dart';
import 'price_trend_section.dart';

const _ink = Color(0xFF203D34);
const _muted = Color(0xFF7C8980);

class MarketPricePage extends StatefulWidget {
  const MarketPricePage({
    super.key,
    required this.category,
    required this.repository,
  });
  final String category;
  final MarketPriceRepository repository;

  @override
  State<MarketPricePage> createState() => _MarketPricePageState();
}

class _MarketPricePageState extends State<MarketPricePage> {
  final _formKey = GlobalKey<FormState>();
  final _resultKey = GlobalKey();
  late final MarketPriceViewModel _viewModel;
  late final TextEditingController _product;

  List<String> get _examples => switch (widget.category) {
    '食品生鲜' => ['农夫山泉 550ml 24瓶', '金龙鱼 玉米油 5L', '伊利 金典纯牛奶 250ml 12盒'],
    '日用百货' => ['维达 超韧抽纸 3层 120抽 24包', '蓝月亮 洗衣液 3kg', '舒肤佳 纯白清香香皂 100g'],
    '出行能源' => ['米其林 浩悦4 205/55 R16 轮胎', '公牛 充电枪 3.5kW 10米', '小米 充气宝2'],
    _ => ['罗技 G102 二代 有线鼠标', 'Apple AirPods 4 标准版', '小米手环 10 标准版'],
  };

  @override
  void initState() {
    super.initState();
    _viewModel = MarketPriceViewModel(widget.repository);
    _product = TextEditingController(text: _examples.first);
  }

  @override
  void dispose() {
    _viewModel.dispose();
    _product.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState?.validate() ?? false) {
      FocusScope.of(context).unfocus();
      unawaited(_research());
    }
  }

  void _openPlatformLogin() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) =>
            PlatformLoginPage(sources: _viewModel.report?.sources ?? const []),
      ),
    );
  }

  Future<void> _research() async {
    await _viewModel.research(_product.text);
    if (!mounted) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final target = _resultKey.currentContext;
      if (target != null) {
        unawaited(
          Scrollable.ensureVisible(
            target,
            duration: const Duration(milliseconds: 300),
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    key: ValueKey('market-price-page-${widget.category}'),
    appBar: AppBar(
      leading: IconButton(
        tooltip: '返回',
        onPressed: () => Navigator.of(context).pop(),
        icon: const Icon(Icons.arrow_back_rounded),
      ),
      title: Text(
        widget.category,
        style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 12),
          child: TextButton.icon(
            key: const Key('research-platform-login'),
            onPressed: _openPlatformLogin,
            icon: const Icon(Icons.login_rounded, size: 17),
            label: const Text('平台登录', style: TextStyle(fontSize: 12)),
          ),
        ),
      ],
    ),
    body: SafeArea(
      top: false,
      child: ListenableBuilder(
        listenable: _viewModel,
        builder: (context, _) => LayoutBuilder(
          builder: (context, constraints) {
            final wide = constraints.maxWidth >= 880;
            final form = _buildForm();
            final Widget result;
            if (_viewModel.isLoading) {
              result = const _StatusPanel(
                loading: true,
                title: '正在寻找价格的依据',
                description: '核对购物平台同款在售价，读取所选月份的历史采样。缺失月份不补值，有足够依据后再生成趋势预测。',
              );
            } else if (_viewModel.error != null) {
              result = _StatusPanel(
                title: '这次调研没有完成',
                description: _viewModel.error!,
                error: true,
                action: TextButton.icon(
                  onPressed: _submit,
                  icon: const Icon(Icons.refresh_rounded),
                  label: const Text('再试一次'),
                ),
              );
            } else if (_viewModel.report != null) {
              result = _ReportView(
                report: _viewModel.report!,
                onOpenPlatformLogin: _openPlatformLogin,
              );
            } else {
              result = const _StatusPanel(
                title: '价格有依据，比较有方向。',
                description:
                    '输入具体商品、选择时间区间，查看月度价格趋势、明细和未来3个月的简单预测。\n\n同型号同规格 · 仅购物平台核验价格 · 缺失月份如实留空',
              );
            }
            return SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(
                wide ? 32 : 20,
                18,
                wide ? 32 : 20,
                40,
              ),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1080),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'PRICE JOURNEY / 价格轨迹',
                        style: TextStyle(
                          fontSize: 10,
                          letterSpacing: 1.6,
                          color: _muted,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        '价格的变化，看得见。',
                        style: TextStyle(
                          fontSize: wide ? 32 : 27,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.8,
                        ),
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        '选一段时间，了解同款价格的过去与可能的走向。',
                        style: TextStyle(fontSize: 13, color: _muted),
                      ),
                      const SizedBox(height: 28),
                      if (wide)
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(width: 340, child: form),
                            const SizedBox(width: 24),
                            Expanded(
                              child: KeyedSubtree(
                                key: _resultKey,
                                child: result,
                              ),
                            ),
                          ],
                        )
                      else ...[
                        form,
                        const SizedBox(height: 20),
                        KeyedSubtree(key: _resultKey, child: result),
                      ],
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    ),
  );

  Widget _buildForm() => _Panel(
    child: Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '想了解哪一件？',
            style: TextStyle(fontSize: 19, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          const Text(
            '写清品牌、型号和规格，比较更准确。',
            style: TextStyle(fontSize: 12, color: _muted, height: 1.7),
          ),
          const SizedBox(height: 22),
          TextFormField(
            key: const Key('price-product-input'),
            controller: _product,
            enabled: !_viewModel.isLoading,
            maxLength: 120,
            minLines: 1,
            maxLines: 3,
            textInputAction: TextInputAction.search,
            onFieldSubmitted: (_) => _submit(),
            decoration: InputDecoration(
              labelText: '商品名称 / 型号 / 规格',
              alignLabelWithHint: true,
              filled: true,
              fillColor: const Color(0xFFF7F9F6),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: const BorderSide(color: Color(0xFFE3EAE1)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: const BorderSide(color: Color(0xFFE3EAE1)),
              ),
              contentPadding: const EdgeInsets.all(16),
            ),
            validator: (value) {
              final text = value?.trim() ?? '';
              return text.length < 2 ? '请填写至少2个字的具体商品名称' : null;
            },
          ),
          const SizedBox(height: 8),
          const Text('也可以试试', style: TextStyle(fontSize: 11, color: _muted)),
          const SizedBox(height: 10),
          Wrap(
            spacing: 7,
            runSpacing: 8,
            children: _examples
                .map(
                  (example) => ActionChip(
                    label: Text(example, style: const TextStyle(fontSize: 11)),
                    backgroundColor: const Color(0xFFF4F7F2),
                    side: BorderSide.none,
                    onPressed: _viewModel.isLoading
                        ? null
                        : () {
                            _product.text = example;
                          },
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 23),
          PriceRangeSelector(
            range: _viewModel.range,
            custom: _viewModel.isCustomRange,
            enabled: !_viewModel.isLoading,
            onChanged: (range, custom) =>
                _viewModel.selectRange(range, custom: custom),
          ),
          const SizedBox(height: 23),
          const Row(
            children: [
              Icon(Icons.location_on_outlined, size: 16, color: _muted),
              SizedBox(width: 6),
              Expanded(
                child: Text(
                  '中国大陆 · 人民币（CNY）',
                  style: TextStyle(fontSize: 12, color: _muted),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          const Text(
            '京东 · 淘宝 · 天猫 · 拼多多',
            style: TextStyle(fontSize: 11, color: _muted),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: FilledButton.icon(
              key: const Key('start-price-research'),
              onPressed: _viewModel.isLoading ? null : _submit,
              icon: _viewModel.isLoading
                  ? const SizedBox(
                      width: 17,
                      height: 17,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.travel_explore_rounded, size: 20),
              label: Text(_viewModel.isLoading ? '调研进行中…' : '开始调研'),
              style: FilledButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ),
          const SizedBox(height: 13),
          const Text(
            '在售价不等于订单成交价。历史价格依赖已核验采样；不会用今日价格或模型推测填充过去月份。',
            style: TextStyle(fontSize: 10, color: _muted, height: 1.7),
          ),
        ],
      ),
    ),
  );
}

class _ReportView extends StatelessWidget {
  const _ReportView({required this.report, required this.onOpenPlatformLogin});
  final CurrentPriceReport report;
  final VoidCallback onOpenPlatformLogin;

  @override
  Widget build(BuildContext context) {
    final completed =
        report.status == 'completed' && report.averagePrice != null;
    final diagnostics = report.diagnostics;
    final allRequireLogin =
        diagnostics != null &&
        diagnostics.attemptedPages > 0 &&
        diagnostics.loginRequiredPages == diagnostics.attemptedPages;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (completed)
          _Panel(
            color: const Color(0xFFE9F1E4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Expanded(
                      child: Text(
                        '平台在售价样本均价',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    if (report.cached)
                      const _Pill(label: '缓存结果', icon: Icons.history_rounded),
                  ],
                ),
                const SizedBox(height: 18),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    _money(report.averagePrice!),
                    key: const Key('average-price'),
                    style: const TextStyle(
                      fontSize: 50,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -2,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  report.productName,
                  style: const TextStyle(fontSize: 13, height: 1.6),
                ),
                const SizedBox(height: 23),
                Wrap(
                  spacing: 28,
                  runSpacing: 16,
                  children: [
                    _Metric(label: '最低报价', value: _money(report.lowestPrice!)),
                    _Metric(label: '最高报价', value: _money(report.highestPrice!)),
                    _Metric(label: '有效样本', value: '${report.quotes.length} 条'),
                  ],
                ),
                const SizedBox(height: 22),
                Text(
                  '检索 ${report.sourceCount} 个平台商品页 · 核验于 ${_time(report.researchedAt)}',
                  style: const TextStyle(fontSize: 10, color: _muted),
                ),
                const SizedBox(height: 8),
                const Text(
                  '平台在售价不代表实际订单成交均价。',
                  style: TextStyle(fontSize: 11, color: _muted),
                ),
              ],
            ),
          )
        else
          _StatusPanel(
            title: report.status == 'needs_clarification'
                ? '把商品说得再具体一点'
                : allRequireLogin
                ? '平台需要登录，暂未取得价格'
                : ['completed', 'insufficient_data'].contains(report.status)
                ? '可比报价还不够'
                : '当前报价暂不可用',
            description:
                '${report.message}\n\n已核验 ${report.quotes.length} 条在售价，找到 ${report.sourceCount} 个平台商品页。'
                '${allRequireLogin ? '\n当前自动调研只能读取公开页面。可在平台登录后直接查看商品；浏览器登录状态尚未接入自动调研。' : ''}'
                '\n${report.cached ? '缓存结果 · 上次调研' : '调研时间'} ${_time(report.researchedAt)}',
            action: allRequireLogin
                ? TextButton.icon(
                    onPressed: onOpenPlatformLogin,
                    icon: const Icon(Icons.login_rounded, size: 17),
                    label: const Text('登录平台并查看商品'),
                  )
                : null,
          ),
        if (diagnostics != null) ...[
          const SizedBox(height: 16),
          _DiagnosticsPanel(
            diagnostics: diagnostics,
            quoteCount: report.quotes.length,
          ),
        ],
        if (report.history != null) ...[
          const SizedBox(height: 24),
          PriceTrendSection(history: report.history!),
        ],
        if (report.quotes.isNotEmpty) ...[
          const SizedBox(height: 25),
          const Text(
            '报价明细',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 5),
          const Text(
            '保留平台商品页原文，点击链接核对具体规格和在售价。',
            style: TextStyle(fontSize: 11, color: _muted),
          ),
          const SizedBox(height: 14),
          for (final quote in report.quotes)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _QuoteCard(quote: quote),
            ),
        ],
        if (report.sources.isNotEmpty) ...[
          const SizedBox(height: 12),
          _Panel(
            padding: EdgeInsets.zero,
            child: ExpansionTile(
              shape: const Border(),
              collapsedShape: const Border(),
              title: Text(
                '查看平台商品页（${report.sources.length}）',
                style: const TextStyle(fontSize: 13),
              ),
              children: report.sources
                  .map(
                    (source) => ListTile(
                      title: Text(
                        source.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 12),
                      ),
                      subtitle: Text(
                        '${source.platform} · 商品 ${source.productId}\n${source.accessMessage.isNotEmpty
                            ? source.accessMessage
                            : source.fetchedAt == null
                            ? '未取得可核验价格'
                            : '商品页已读取，报价是否采用见明细'}',
                        style: const TextStyle(fontSize: 10),
                      ),
                      trailing: const Icon(Icons.open_in_new_rounded, size: 16),
                      onTap: () => _openSource(context, source.url),
                    ),
                  )
                  .toList(),
            ),
          ),
        ],
        const SizedBox(height: 16),
        _Panel(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(Icons.calculate_outlined, size: 18),
                  SizedBox(width: 8),
                  Text(
                    '这份均价怎么算？',
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                report.methodology,
                style: const TextStyle(
                  fontSize: 11,
                  color: _muted,
                  height: 1.9,
                ),
              ),
              for (final limitation in report.limitations)
                Padding(
                  padding: const EdgeInsets.only(top: 9),
                  child: Text(
                    '· $limitation',
                    style: const TextStyle(
                      fontSize: 11,
                      color: _muted,
                      height: 1.8,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _DiagnosticsPanel extends StatelessWidget {
  const _DiagnosticsPanel({
    required this.diagnostics,
    required this.quoteCount,
  });
  final PriceRetrievalDiagnostics diagnostics;
  final int quoteCount;

  @override
  Widget build(BuildContext context) => _Panel(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Icon(Icons.fact_check_outlined, size: 19),
            SizedBox(width: 8),
            Text(
              '本次调研过程',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
            ),
          ],
        ),
        const SizedBox(height: 18),
        Text(
          '找到商品页 ${diagnostics.attemptedPages} 个 → 可读正文 ${diagnostics.readablePages} 个 → 核验报价 $quoteCount 条',
          style: const TextStyle(fontSize: 12, height: 1.8),
        ),
        if (diagnostics.loginRequiredPages > 0 ||
            diagnostics.verificationRequiredPages > 0) ...[
          const SizedBox(height: 8),
          Text(
            [
              if (diagnostics.loginRequiredPages > 0)
                '${diagnostics.loginRequiredPages}个商品页要求登录',
              if (diagnostics.verificationRequiredPages > 0)
                '${diagnostics.verificationRequiredPages}个商品页要求安全验证',
            ].join('；'),
            style: const TextStyle(
              fontSize: 11,
              height: 1.8,
              color: Color(0xFFAD7950),
            ),
          ),
        ],
        const SizedBox(height: 8),
        Text(
          diagnostics.modelInvoked
              ? '模型已整理价格文本；$quoteCount 条通过后端核验。'
              : '模型未进行价格整理：没有可读取的价格证据。',
          key: const Key('model-research-status'),
          style: const TextStyle(fontSize: 11, color: _muted, height: 1.8),
        ),
        if (diagnostics.searches.isNotEmpty) ...[
          const SizedBox(height: 8),
          ExpansionTile(
            tilePadding: EdgeInsets.zero,
            childrenPadding: EdgeInsets.zero,
            shape: const Border(),
            collapsedShape: const Border(),
            title: const Text('查看各平台检索结果', style: TextStyle(fontSize: 12)),
            children: [
              for (final search in diagnostics.searches)
                Padding(
                  padding: const EdgeInsets.only(bottom: 14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          '${search.platform} · ${search.status == 'failed' ? '检索失败' : '${search.resultCount}条结果 / ${search.productPageCount}个详情链接'}',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        search.message,
                        style: const TextStyle(
                          fontSize: 10,
                          height: 1.7,
                          color: _muted,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ],
      ],
    ),
  );
}

class _QuoteCard extends StatelessWidget {
  const _QuoteCard({required this.quote});
  final CurrentPriceQuote quote;

  @override
  Widget build(BuildContext context) => _Panel(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Text(
                quote.seller,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Text(
              _money(quote.price),
              style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w700),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          '${quote.source.platform} · 商品 ${quote.source.productId}',
          style: const TextStyle(fontSize: 10, color: _muted),
        ),
        const SizedBox(height: 7),
        Text(
          '“${quote.evidence}”',
          maxLines: 4,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontSize: 12, height: 1.8, color: _muted),
        ),
        const SizedBox(height: 12),
        Text(
          quote.source.title,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontSize: 11),
        ),
        const SizedBox(height: 7),
        Wrap(
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 12,
          children: [
            Text(
              quote.source.fetchedAt == null
                  ? '平台商品页'
                  : '详情页读取于 ${_time(quote.source.fetchedAt!)}',
              style: const TextStyle(fontSize: 10, color: _muted),
            ),
            TextButton.icon(
              onPressed: () => _openSource(context, quote.source.url),
              icon: const Icon(Icons.open_in_new_rounded, size: 13),
              label: const Text('查看原文', style: TextStyle(fontSize: 11)),
            ),
          ],
        ),
      ],
    ),
  );
}

class _StatusPanel extends StatelessWidget {
  const _StatusPanel({
    required this.title,
    required this.description,
    this.loading = false,
    this.error = false,
    this.action,
  });
  final String title;
  final String description;
  final bool loading;
  final bool error;
  final Widget? action;

  @override
  Widget build(BuildContext context) => _Panel(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            color: error ? const Color(0xFFF9EEE5) : const Color(0xFFEDF3E9),
            borderRadius: BorderRadius.circular(17),
          ),
          child: Icon(
            error ? Icons.wifi_off_rounded : Icons.query_stats_rounded,
            color: error ? const Color(0xFFB58360) : _ink,
            size: 26,
          ),
        ),
        const SizedBox(height: 25),
        Text(
          title,
          style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 14),
        Text(
          description,
          style: const TextStyle(fontSize: 12, color: _muted, height: 2),
        ),
        if (loading) ...[
          const SizedBox(height: 25),
          const LinearProgressIndicator(minHeight: 3),
        ],
        if (action != null) ...[const SizedBox(height: 15), action!],
        const SizedBox(height: 12),
      ],
    ),
  );
}

class _Panel extends StatelessWidget {
  const _Panel({
    required this.child,
    this.color = Colors.white,
    this.padding = const EdgeInsets.all(24),
  });
  final Widget child;
  final Color color;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: padding,
    decoration: BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(24),
      border: Border.all(color: const Color(0xFFE5EBE2)),
    ),
    child: child,
  );
}

class _Pill extends StatelessWidget {
  const _Pill({required this.label, required this.icon});
  final String label;
  final IconData icon;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
    decoration: BoxDecoration(
      color: const Color(0xFFEAF0E6),
      borderRadius: BorderRadius.circular(30),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 12),
        const SizedBox(width: 5),
        Text(label, style: const TextStyle(fontSize: 10)),
      ],
    ),
  );
}

class _Metric extends StatelessWidget {
  const _Metric({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(label, style: const TextStyle(fontSize: 10, color: _muted)),
      const SizedBox(height: 6),
      Text(
        value,
        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
      ),
    ],
  );
}

String _money(double value) => '¥${value.toStringAsFixed(2)}';
String _time(DateTime value) {
  final local = value.toLocal();
  String two(int number) => number.toString().padLeft(2, '0');
  return '${two(local.month)}/${two(local.day)} ${two(local.hour)}:${two(local.minute)}';
}

Future<void> _openSource(BuildContext context, Uri url) async {
  var opened = false;
  try {
    if (['http', 'https'].contains(url.scheme)) {
      opened = await launchUrl(
        url,
        mode: LaunchMode.externalApplication,
        webOnlyWindowName: '_blank',
      );
    }
  } catch (_) {
    /* Keep the report usable if the platform cannot open a URL. */
  }
  if (!opened && context.mounted) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('暂时无法打开来源链接，请稍后重试。')));
  }
}
