import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../domain/models/price_history.dart';
import 'price_range_selector.dart';

const _ink = Color(0xFF203D34);
const _muted = Color(0xFF7C8980);
const _forecastColor = Color(0xFFBD8B53);

class PriceTrendSection extends StatefulWidget {
  const PriceTrendSection({super.key, required this.history});
  final MarketPriceHistory history;

  @override
  State<PriceTrendSection> createState() => _PriceTrendSectionState();
}

class _PriceTrendSectionState extends State<PriceTrendSection> {
  bool _bars = false;

  @override
  Widget build(BuildContext context) {
    final history = widget.history;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _Card(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(
                alignment: WrapAlignment.spaceBetween,
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 16,
                runSpacing: 10,
                children: [
                  const Text(
                    '价格浮动趋势',
                    style: TextStyle(fontSize: 19, fontWeight: FontWeight.w700),
                  ),
                  SegmentedButton<bool>(
                    showSelectedIcon: false,
                    style: const ButtonStyle(
                      visualDensity: VisualDensity.compact,
                      textStyle: WidgetStatePropertyAll(
                        TextStyle(fontSize: 11),
                      ),
                    ),
                    segments: const [
                      ButtonSegment(
                        value: false,
                        label: Text('折线'),
                        icon: Icon(Icons.show_chart_rounded, size: 16),
                      ),
                      ButtonSegment(
                        value: true,
                        label: Text('柱状'),
                        icon: Icon(Icons.bar_chart_rounded, size: 16),
                      ),
                    ],
                    selected: {_bars},
                    onSelectionChanged: (value) =>
                        setState(() => _bars = value.single),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                '${monthLabel(history.range.startMonth)} — ${monthLabel(history.range.endMonth)} · 人民币',
                style: const TextStyle(fontSize: 11, color: _muted),
              ),
              const SizedBox(height: 20),
              Wrap(
                spacing: 28,
                runSpacing: 12,
                children: [
                  _Stat(
                    '有效月份',
                    '${history.coveredMonths} / ${history.range.monthCount}',
                  ),
                  _Stat(
                    '区间涨跌',
                    history.changePercent == null
                        ? '暂无数据'
                        : '${history.changePercent! > 0 ? '+' : ''}${history.changePercent!.toStringAsFixed(2)}%',
                  ),
                  const _Stat('价格口径', '平台在售价'),
                ],
              ),
              const SizedBox(height: 14),
              _TrendChart(
                key: ValueKey('price-trend-chart-${_bars ? 'bar' : 'line'}'),
                history: history,
                bars: _bars,
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 18,
                runSpacing: 7,
                children: [
                  const _Legend(label: '已核验月度采样', color: _ink),
                  if (history.forecast.points.isNotEmpty)
                    const _Legend(label: '未来预测', color: _forecastColor),
                  const Text(
                    '空白月份不补值',
                    style: TextStyle(fontSize: 10, color: _muted),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        _ForecastCard(forecast: history.forecast),
        const SizedBox(height: 16),
        _Card(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '月度价格明细',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 8),
              const Text(
                '每月不少于3个商品样本才计算均价；点击月份查看核验来源。',
                style: TextStyle(fontSize: 11, color: _muted, height: 1.7),
              ),
              const SizedBox(height: 18),
              const _TableRow(values: ['月份', '采样均价', '环比', '样本'], header: true),
              ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 330),
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      for (var i = 0; i < history.points.length; i++)
                        _MonthRow(
                          point: history.points[i],
                          previous: i == 0 ? null : history.points[i - 1],
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                history.methodology,
                style: const TextStyle(
                  fontSize: 10,
                  color: _muted,
                  height: 1.8,
                ),
              ),
              const SizedBox(height: 10),
              for (final limitation in history.limitations)
                Padding(
                  padding: const EdgeInsets.only(bottom: 7),
                  child: Text(
                    '· $limitation',
                    style: const TextStyle(
                      fontSize: 10,
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

class _TrendChart extends StatefulWidget {
  const _TrendChart({super.key, required this.history, required this.bars});
  final MarketPriceHistory history;
  final bool bars;

  @override
  State<_TrendChart> createState() => _TrendChartState();
}

class _TrendChartState extends State<_TrendChart> {
  int? _selected;

  @override
  Widget build(BuildContext context) {
    final history = widget.history;
    final months = [
      ...history.points.map((p) => p.month),
      ...history.forecast.points.map((p) => p.month),
    ];
    final prices = [
      ...history.points.map((p) => p.averagePrice),
      ...history.forecast.points.map((p) => p.predictedPrice),
    ];
    final empty = prices.every((p) => p == null);
    final index = _selected != null && _selected! < prices.length
        ? _selected
        : null;
    final description = index == null
        ? '月度采样均价 · ¥'
        : '${monthLabel(months[index])} · ${index >= history.points.length ? '预测 ' : ''}${prices[index] == null ? '暂无核验数据' : _money(prices[index]!)}';
    return Semantics(
      label:
          '价格趋势图，${widget.bars ? '柱状图' : '折线图'}。${List.generate(months.length, (i) => '${monthLabel(months[i])} ${prices[i] == null ? '暂无数据' : '${i >= history.points.length ? '预测' : ''}${_money(prices[i]!)}'}').join('；')}',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            description,
            style: const TextStyle(fontSize: 11, color: _muted),
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 225,
            child: LayoutBuilder(
              builder: (context, constraints) {
                void select(double x) {
                  if (prices.isEmpty) return;
                  final index =
                      (((x - 43) / math.max(1, constraints.maxWidth - 53)) *
                              prices.length)
                          .floor()
                          .clamp(0, prices.length - 1);
                  setState(() => _selected = index);
                }

                return MouseRegion(
                  onHover: (event) => select(event.localPosition.dx),
                  onExit: (_) => setState(() => _selected = null),
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTapDown: (event) => select(event.localPosition.dx),
                    child: Stack(
                      children: [
                        Positioned.fill(
                          child: CustomPaint(
                            painter: _TrendPainter(
                              months: months,
                              prices: prices,
                              historyCount: history.points.length,
                              bars: widget.bars,
                              selected: index,
                            ),
                          ),
                        ),
                        if (empty)
                          const Positioned.fill(
                            left: 43,
                            bottom: 30,
                            child: Center(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.timeline_rounded,
                                    size: 30,
                                    color: _muted,
                                  ),
                                  SizedBox(height: 10),
                                  Text(
                                    '这个区间还没有足够的核验价格',
                                    style: TextStyle(fontSize: 12, color: _ink),
                                  ),
                                  SizedBox(height: 6),
                                  Text(
                                    '有真实采样后，趋势会显示在这里',
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: _muted,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _TrendPainter extends CustomPainter {
  const _TrendPainter({
    required this.months,
    required this.prices,
    required this.historyCount,
    required this.bars,
    this.selected,
  });
  final List<DateTime> months;
  final List<double?> prices;
  final int historyCount;
  final bool bars;
  final int? selected;

  @override
  void paint(Canvas canvas, Size size) {
    if (prices.isEmpty) return;
    final plot = Rect.fromLTRB(
      43,
      12,
      math.max(44, size.width - 10),
      size.height - 30,
    );
    final values = prices.whereType<double>().toList();
    final low = values.isEmpty ? 0.0 : values.reduce(math.min);
    final high = values.isEmpty ? 1.0 : values.reduce(math.max);
    final padding = math.max((high - low) * 0.2, high * 0.06);
    final min = bars ? 0.0 : math.max(0.0, low - padding);
    final max = math.max(min + 1, high + padding);
    double x(int index) =>
        plot.left + plot.width * (index + 0.5) / prices.length;
    double y(double value) =>
        plot.bottom - (value - min) / (max - min) * plot.height;
    final grid = Paint()
      ..color = const Color(0xFFE8EEE5)
      ..strokeWidth = 1;
    if (prices.length > historyCount) {
      final start = plot.left + plot.width * historyCount / prices.length;
      canvas.drawRect(
        Rect.fromLTRB(start, plot.top, plot.right, plot.bottom),
        Paint()..color = const Color(0xFFFCF7EE),
      );
    }
    for (var i = 0; i < 4; i++) {
      final dy = plot.top + plot.height * i / 3;
      canvas.drawLine(Offset(plot.left, dy), Offset(plot.right, dy), grid);
      final value = max - (max - min) * i / 3;
      _text(
        canvas,
        values.isEmpty ? '—' : value.toStringAsFixed(value >= 100 ? 0 : 1),
        Offset(plot.left - 6, dy - 5),
        right: true,
      );
    }
    for (var i = 0; i < prices.length; i++) {
      final step = (prices.length / (size.width < 340 ? 4 : 6)).ceil();
      if (i == 0 || i == prices.length - 1 || i % step == 0) {
        _text(
          canvas,
          '${months[i].month}月',
          Offset(x(i), plot.bottom + 12),
          center: true,
        );
      }
      final value = prices[i];
      if (value == null) continue;
      final forecast = i >= historyCount;
      final color = forecast ? _forecastColor : _ink;
      if (bars) {
        final width = (plot.width / prices.length * 0.5).clamp(3.0, 25.0);
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromLTRB(
              x(i) - width / 2,
              y(value),
              x(i) + width / 2,
              plot.bottom,
            ),
            const Radius.circular(4),
          ),
          Paint()..color = color.withValues(alpha: forecast ? 0.65 : 0.85),
        );
      } else {
        // A missing month breaks the line; it is never interpolated.
        if (i > 0 && prices[i - 1] != null) {
          final from = Offset(x(i - 1), y(prices[i - 1]!));
          final to = Offset(x(i), y(value));
          final paint = Paint()
            ..color = color
            ..strokeWidth = 2.5;
          if (forecast) {
            _dashed(canvas, from, to, paint);
          } else {
            canvas.drawLine(from, to, paint);
          }
        }
        canvas.drawCircle(Offset(x(i), y(value)), 4, Paint()..color = color);
        canvas.drawCircle(
          Offset(x(i), y(value)),
          2,
          Paint()..color = Colors.white,
        );
      }
    }
    if (selected != null) {
      _dashed(
        canvas,
        Offset(x(selected!), plot.top),
        Offset(x(selected!), plot.bottom),
        Paint()
          ..color = _muted.withValues(alpha: 0.5)
          ..strokeWidth = 1,
      );
    }
  }

  void _dashed(Canvas canvas, Offset from, Offset to, Paint paint) {
    final delta = to - from;
    final distance = delta.distance;
    if (distance == 0) return;
    final direction = delta / distance;
    for (var offset = 0.0; offset < distance; offset += 9) {
      canvas.drawLine(
        from + direction * offset,
        from + direction * math.min(offset + 5, distance),
        paint,
      );
    }
  }

  void _text(
    Canvas canvas,
    String value,
    Offset offset, {
    bool right = false,
    bool center = false,
  }) {
    final text = TextPainter(
      text: TextSpan(
        text: value,
        style: const TextStyle(fontSize: 9, color: _muted),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    text.paint(
      canvas,
      offset -
          Offset(
            right
                ? text.width
                : center
                ? text.width / 2
                : 0,
            0,
          ),
    );
  }

  @override
  bool shouldRepaint(covariant _TrendPainter old) => true;
}

class _ForecastCard extends StatelessWidget {
  const _ForecastCard({required this.forecast});
  final PriceForecast forecast;

  @override
  Widget build(BuildContext context) => _Card(
    color: const Color(0xFFFAF5EB),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Icon(Icons.auto_graph_rounded, size: 20, color: _forecastColor),
            SizedBox(width: 9),
            Expanded(
              child: Text(
                '未来3个月 · 简单预测',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
              ),
            ),
          ],
        ),
        const SizedBox(height: 13),
        if (forecast.points.isEmpty) ...[
          const Text(
            '暂不预测',
            key: Key('forecast-unavailable'),
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
        ] else ...[
          Wrap(
            spacing: 24,
            runSpacing: 14,
            children: [
              for (final point in forecast.points)
                _Stat(monthLabel(point.month), _money(point.predictedPrice)),
            ],
          ),
          const SizedBox(height: 14),
        ],
        Text(
          forecast.message,
          style: const TextStyle(fontSize: 11, height: 1.8, color: _muted),
        ),
        if (forecast.points.isNotEmpty) ...[
          const SizedBox(height: 8),
          const Text(
            '预测值与已核验历史价格分别标示，不代表未来成交价。',
            style: TextStyle(fontSize: 10, height: 1.7, color: _forecastColor),
          ),
        ],
      ],
    ),
  );
}

class _MonthRow extends StatelessWidget {
  const _MonthRow({required this.point, this.previous});
  final MonthlyPricePoint point;
  final MonthlyPricePoint? previous;

  @override
  Widget build(BuildContext context) {
    final average = point.averagePrice;
    final before = previous?.averagePrice;
    final change = average == null || before == null
        ? null
        : (average / before - 1) * 100;
    return InkWell(
      key: ValueKey('history-month-${monthLabel(point.month)}'),
      onTap: point.quotes.isEmpty
          ? null
          : () => _showMonthSources(context, point),
      child: _TableRow(
        values: [
          monthLabel(point.month),
          average == null ? '暂无数据' : _money(average),
          change == null
              ? '—'
              : '${change > 0 ? '+' : ''}${change.toStringAsFixed(1)}%',
          '${point.sampleCount}${point.sampleCount > 0 && point.sampleCount < 3 ? ' 不足' : ' 条'}',
        ],
      ),
    );
  }
}

class _TableRow extends StatelessWidget {
  const _TableRow({required this.values, this.header = false});
  final List<String> values;
  final bool header;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(vertical: 14),
    decoration: const BoxDecoration(
      border: Border(bottom: BorderSide(color: Color(0xFFEDF1E9))),
    ),
    child: Row(
      children: [
        for (var i = 0; i < values.length; i++)
          Expanded(
            flex: i == 1 ? 3 : 2,
            child: Text(
              values[i],
              textAlign: i == 0 ? TextAlign.left : TextAlign.right,
              style: TextStyle(
                fontSize: 10,
                color: header ? _muted : _ink,
                fontWeight: header ? FontWeight.w400 : FontWeight.w500,
              ),
            ),
          ),
      ],
    ),
  );
}

Future<void> _showMonthSources(
  BuildContext context,
  MonthlyPricePoint point,
) => showModalBottomSheet<void>(
  context: context,
  isScrollControlled: true,
  showDragHandle: true,
  builder: (context) => SafeArea(
    child: SizedBox(
      height: MediaQuery.sizeOf(context).height * 0.7,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(24, 6, 24, 24),
        children: [
          Text(
            '${monthLabel(point.month)} 核验明细',
            style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          Text(
            point.averagePrice == null
                ? '样本不足3条，暂不计算均价。'
                : '采样均价 ${_money(point.averagePrice!)} · 区间 ${_money(point.lowestPrice!)}–${_money(point.highestPrice!)}',
            style: const TextStyle(fontSize: 12, color: _muted),
          ),
          const SizedBox(height: 20),
          for (final quote in point.quotes)
            Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${quote.platform} · ${quote.seller}  ${_money(quote.price)}',
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    quote.evidence,
                    style: const TextStyle(fontSize: 12, height: 1.8),
                  ),
                  const SizedBox(height: 7),
                  Text(
                    '商品 ${quote.productId} · 核验于 ${quote.observedAt.toUtc().add(const Duration(hours: 8)).toString().substring(0, 16)}（北京时间）',
                    style: const TextStyle(fontSize: 10, color: _muted),
                  ),
                  TextButton.icon(
                    onPressed: () async {
                      var opened = false;
                      try {
                        opened = await launchUrl(
                          quote.url,
                          mode: LaunchMode.externalApplication,
                          webOnlyWindowName: '_blank',
                        );
                      } catch (_) {
                        /* Report stays available. */
                      }
                      if (!opened && context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('暂时无法打开来源链接。')),
                        );
                      }
                    },
                    icon: const Icon(Icons.open_in_new_rounded, size: 14),
                    label: const Text(
                      '查看平台商品页',
                      style: TextStyle(fontSize: 11),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    ),
  ),
);

class _Legend extends StatelessWidget {
  const _Legend({required this.label, required this.color});
  final String label;
  final Color color;
  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Container(width: 12, height: 3, color: color),
      const SizedBox(width: 6),
      Text(label, style: const TextStyle(fontSize: 10, color: _muted)),
    ],
  );
}

class _Stat extends StatelessWidget {
  const _Stat(this.label, this.value);
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
        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
      ),
    ],
  );
}

class _Card extends StatelessWidget {
  const _Card({required this.child, this.color = Colors.white});
  final Widget child;
  final Color color;
  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(22),
    decoration: BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(24),
      border: Border.all(color: const Color(0xFFE5EBE2)),
    ),
    child: child,
  );
}

String _money(double value) => '¥${value.toStringAsFixed(2)}';
