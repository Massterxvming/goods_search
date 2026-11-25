import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:goods_search/data/repositories/market_price_repository.dart';
import 'package:goods_search/domain/models/current_price_report.dart';
import 'package:goods_search/domain/models/price_history.dart';
import 'package:goods_search/ui/features/market_price/view_models/market_price_view_model.dart';
import 'package:goods_search/ui/features/market_price/views/market_price_page.dart';

class _Repository implements MarketPriceRepository {
  int calls = 0;
  PriceHistoryRange? receivedRange;
  final pending = Completer<CurrentPriceReport>();
  @override
  Future<CurrentPriceReport> research(
    String productName, {
    required PriceHistoryRange range,
  }) {
    calls++;
    receivedRange = range;
    return pending.future;
  }

  @override
  void dispose() {}
}

CurrentPriceReport _report({
  String status = 'completed',
  MarketPriceHistory? history,
}) => CurrentPriceReport(
  status: status,
  message: status == 'completed' ? '调研完成' : '可比报价不足3条，暂不计算均价。',
  productName: '测试鼠标',
  researchedAt: DateTime.utc(2026, 11, 16),
  averagePrice: status == 'completed' ? 20.02 : null,
  lowestPrice: status == 'completed' ? 10.01 : null,
  highestPrice: status == 'completed' ? 30.03 : null,
  sourceCount: 3,
  methodology: '按三条同口径报价计算均价。',
  history: history,
  quotes: status != 'completed'
      ? []
      : List.generate(
          3,
          (index) => CurrentPriceQuote(
            seller: '商家${index + 1}',
            price: (index + 1) * 10.01,
            evidence: '测试鼠标 页面公开标价',
            source: PriceReference(
              id: '$index',
              title: '来源${index + 1}',
              url: Uri.parse('https://item.jd.com/${1001 + index}.html'),
              platform: '京东',
              productId: '${1001 + index}',
              fetchedAt: DateTime.utc(2026, 11, 16),
            ),
          ),
        ),
);

MarketPriceHistory _history({bool gap = false}) {
  final range = PriceHistoryRange.recent(6);
  return MarketPriceHistory(
    range: range,
    coveredMonths: gap ? 5 : 6,
    changePercent: -45.45,
    methodology: '核验采样，缺失不补值。',
    points: List.generate(
      6,
      (i) => MonthlyPricePoint(
        month: DateTime.utc(range.startMonth.year, range.startMonth.month + i),
        averagePrice: gap && i == 2 ? null : 110 - i * 10,
        lowestPrice: gap && i == 2 ? null : 105 - i * 10,
        highestPrice: gap && i == 2 ? null : 115 - i * 10,
        sampleCount: gap && i == 2 ? 0 : 3,
      ),
    ),
    forecast: PriceForecast(
      status: gap ? 'insufficient_data' : 'available',
      method: 'linear_regression',
      sampleMonths: gap ? 2 : 6,
      message: gap ? '连续月份不足，暂不预测。' : '基于核验均价线性外推。',
      points: gap
          ? []
          : List.generate(
              3,
              (i) => ForecastPricePoint(
                month: DateTime.utc(
                  range.endMonth.year,
                  range.endMonth.month + i + 1,
                ),
                predictedPrice: 50 - i * 10,
              ),
            ),
    ),
  );
}

Widget _page(_Repository repository) => MaterialApp(
  home: MarketPricePage(category: '数码家电', repository: repository),
);

void main() {
  testWidgets(
    'shows the login bottleneck before the chart and exposes page-specific access reasons',
    (tester) async {
      final repository = _Repository();
      repository.pending.complete(
        CurrentPriceReport(
          status: 'insufficient_data',
          message: '找到1个商品页，但1个需要登录，未取得公开在售价。',
          productName: '测试鼠标',
          researchedAt: DateTime.utc(2026, 11, 17),
          sourceCount: 1,
          cached: true,
          history: _history(gap: true),
          sources: [
            PriceReference(
              id: 's1',
              title: '京东商品 1001',
              url: Uri.parse('https://item.jd.com/1001.html'),
              platform: '京东',
              productId: '1001',
              accessStatus: 'login_required',
              accessMessage: '平台要求登录后查看商品或价格，未取得公开在售价。',
            ),
          ],
          diagnostics: PriceRetrievalDiagnostics(
            attemptedPages: 1,
            readablePages: 0,
            evidencePages: 0,
            loginRequiredPages: 1,
            verificationRequiredPages: 0,
            modelInvoked: false,
            searches: [
              const PlatformSearchDiagnostic(
                platform: '京东',
                status: 'completed',
                resultCount: 1,
                productPageCount: 1,
                message: '找到1个详情链接。',
              ),
            ],
          ),
        ),
      );
      await tester.pumpWidget(_page(repository));
      final start = find.byKey(const Key('start-price-research'));
      await tester.ensureVisible(start);
      await tester.tap(start);
      await tester.pumpAndSettle();
      final reason = find.text('平台需要登录，暂未取得价格');
      expect(reason, findsOneWidget);
      expect(
        tester.getTopLeft(reason).dy,
        lessThan(tester.getTopLeft(find.text('价格浮动趋势')).dy),
      );
      expect(find.text('模型未进行价格整理：没有可读取的价格证据。'), findsOneWidget);
      expect(find.textContaining('缓存结果 · 上次调研'), findsOneWidget);
      final sources = find.text('查看平台商品页（1）');
      await tester.ensureVisible(sources);
      await tester.tap(sources);
      await tester.pumpAndSettle();
      expect(find.textContaining('平台要求登录后查看商品或价格'), findsOneWidget);
      expect(find.byKey(const Key('average-price')), findsNothing);
      final login = find.text('登录平台并查看商品');
      await tester.ensureVisible(login);
      await tester.tap(login);
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('platform-login-page')), findsOneWidget);
      expect(find.byKey(const ValueKey('platform-product-s1')), findsOneWidget);
    },
  );

  testWidgets(
    'preset ranges are forwarded with exact calendar-month boundaries',
    (tester) async {
      final repository = _Repository();
      repository.pending.complete(_report());
      await tester.pumpWidget(_page(repository));
      final range = find.byKey(const Key('price-range-24'));
      await tester.ensureVisible(range);
      await tester.tap(range);
      await tester.pump();
      final start = find.byKey(const Key('start-price-research'));
      await tester.ensureVisible(start);
      await tester.tap(start);
      await tester.pumpAndSettle();
      final expected = PriceHistoryRange.recent(24);
      expect(repository.receivedRange!.monthCount, 24);
      expect(repository.receivedRange!.startMonth, expected.startMonth);
      expect(repository.receivedRange!.endMonth, expected.endMonth);
    },
  );

  testWidgets(
    'custom months reject reversed ranges and submit the chosen interval',
    (tester) async {
      final repository = _Repository();
      repository.pending.complete(_report());
      await tester.pumpWidget(_page(repository));
      final custom = find.byKey(const Key('price-range-custom'));
      await tester.ensureVisible(custom);
      await tester.tap(custom);
      await tester.pumpAndSettle();
      final current = PriceHistoryRange.recent(1).endMonth;
      String label(DateTime month) =>
          '${month.year}年${month.month.toString().padLeft(2, '0')}月';
      Future<void> chooseMonth(DateTime month) async {
        final option = find.descendant(
          of: find.byType(Scrollable).last,
          matching: find.text(label(month)),
        );
        await tester.scrollUntilVisible(
          option,
          -100,
          scrollable: find.byType(Scrollable).last,
          maxScrolls: 24,
        );
        await tester.pumpAndSettle();
        await tester.tap(option);
        await tester.pumpAndSettle();
      }

      await tester.tap(find.byKey(const Key('custom-start-month')));
      await tester.pumpAndSettle();
      await chooseMonth(current);
      await tester.tap(find.byKey(const Key('custom-end-month')));
      await tester.pumpAndSettle();
      final previous = DateTime.utc(current.year, current.month - 1);
      await chooseMonth(previous);
      expect(find.text('开始月份不能晚于结束月份'), findsOneWidget);
      expect(
        tester
            .widget<FilledButton>(find.byKey(const Key('confirm-price-range')))
            .onPressed,
        isNull,
      );
      await tester.tap(find.byKey(const Key('custom-start-month')));
      await tester.pumpAndSettle();
      final from = DateTime.utc(current.year, current.month - 3);
      await chooseMonth(from);
      await tester.tap(find.byKey(const Key('confirm-price-range')));
      await tester.pumpAndSettle();
      final start = find.byKey(const Key('start-price-research'));
      await tester.ensureVisible(start);
      await tester.tap(start);
      await tester.pumpAndSettle();
      expect(repository.receivedRange!.startMonth, from);
      expect(repository.receivedRange!.endMonth, previous);
      expect(repository.receivedRange!.monthCount, 3);
    },
  );

  testWidgets(
    'renders history, switches chart type and labels predicted prices separately',
    (tester) async {
      final repository = _Repository();
      repository.pending.complete(_report(history: _history()));
      await tester.pumpWidget(_page(repository));
      final start = find.byKey(const Key('start-price-research'));
      await tester.ensureVisible(start);
      await tester.tap(start);
      await tester.pumpAndSettle();
      expect(find.text('价格浮动趋势'), findsOneWidget);
      expect(
        find.byKey(const ValueKey('price-trend-chart-line')),
        findsOneWidget,
      );
      final bars = find.text('柱状');
      await tester.ensureVisible(bars);
      await tester.tap(bars);
      await tester.pumpAndSettle();
      expect(
        find.byKey(const ValueKey('price-trend-chart-bar')),
        findsOneWidget,
      );
      expect(find.text('未来3个月 · 简单预测'), findsOneWidget);
      expect(find.text('¥50.00'), findsOneWidget);
      expect(find.text('月度价格明细'), findsOneWidget);
      expect(find.text('未来预测'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'missing monthly data stays empty and no forecast amount is fabricated',
    (tester) async {
      final repository = _Repository();
      repository.pending.complete(_report(history: _history(gap: true)));
      await tester.pumpWidget(_page(repository));
      final start = find.byKey(const Key('start-price-research'));
      await tester.ensureVisible(start);
      await tester.tap(start);
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('forecast-unavailable')), findsOneWidget);
      expect(find.text('暂无数据'), findsOneWidget);
      expect(find.text('¥50.00'), findsNothing);
      expect(find.text('未来预测'), findsNothing);
    },
  );

  testWidgets(
    'research is explicit, disables repeat submits, and renders the returned average and sources',
    (tester) async {
      final repository = _Repository();
      await tester.pumpWidget(_page(repository));
      expect(repository.calls, 0);
      await tester.enterText(
        find.byKey(const Key('price-product-input')),
        '测试鼠标',
      );
      final start = find.byKey(const Key('start-price-research'));
      await tester.ensureVisible(start);
      await tester.tap(start);
      await tester.pump();
      expect(repository.calls, 1);
      expect(tester.widget<FilledButton>(start).onPressed, isNull);
      expect(find.text('正在寻找价格的依据'), findsOneWidget);
      repository.pending.complete(_report(history: _history()));
      await tester.pumpAndSettle();
      expect(
        tester.widget<Text>(find.byKey(const Key('average-price'))).data,
        '¥20.02',
      );
      expect(find.text('报价明细'), findsOneWidget);
      expect(find.text('查看原文'), findsNWidgets(3));
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('insufficient data does not display a fabricated average', (
    tester,
  ) async {
    final repository = _Repository();
    repository.pending.complete(_report(status: 'insufficient_data'));
    await tester.pumpWidget(_page(repository));
    final start = find.byKey(const Key('start-price-research'));
    await tester.ensureVisible(start);
    await tester.tap(start);
    await tester.pumpAndSettle();
    expect(find.text('可比报价还不够'), findsOneWidget);
    expect(find.byKey(const Key('average-price')), findsNothing);
  });

  testWidgets(
    'unreadable platform pages expose product links without inventing transaction prices',
    (tester) async {
      final repository = _Repository();
      repository.pending.complete(
        CurrentPriceReport(
          status: 'insufficient_data',
          message: '平台商品页暂未提供可核验的在售价。',
          productName: '测试鼠标',
          researchedAt: DateTime.utc(2026, 11, 16),
          sourceCount: 1,
          sources: [
            PriceReference(
              id: 's1',
              title: '京东测试鼠标商品页',
              url: Uri.parse('https://item.jd.com/1001.html'),
              platform: '京东',
              productId: '1001',
            ),
          ],
        ),
      );
      await tester.pumpWidget(_page(repository));
      final start = find.byKey(const Key('start-price-research'));
      await tester.ensureVisible(start);
      await tester.tap(start);
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('average-price')), findsNothing);
      final references = find.text('查看平台商品页（1）');
      await tester.ensureVisible(references);
      await tester.tap(references);
      await tester.pumpAndSettle();
      expect(find.text('京东测试鼠标商品页'), findsOneWidget);
      expect(find.textContaining('未取得可核验价格'), findsOneWidget);
      expect(find.textContaining('商品 1001'), findsOneWidget);
    },
  );

  testWidgets(
    'research form and report fit mobile, landscape and desktop windows',
    (tester) async {
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.view.resetPhysicalSize);
      final repository = _Repository();
      repository.pending.complete(_report(history: _history()));
      await tester.pumpWidget(_page(repository));
      final start = find.byKey(const Key('start-price-research'));
      await tester.ensureVisible(start);
      await tester.tap(start);
      await tester.pumpAndSettle();
      for (final size in [
        const Size(320, 568),
        const Size(390, 844),
        const Size(844, 390),
        const Size(1440, 900),
      ]) {
        tester.view.physicalSize = size;
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        expect(find.byKey(const Key('average-price')), findsOneWidget);
        expect(find.text('价格浮动趋势'), findsOneWidget);
      }
    },
  );

  test(
    'ViewModel prevents duplicate calls and safely ignores completion after disposal',
    () async {
      final repository = _Repository();
      final model = MarketPriceViewModel(repository);
      final first = model.research('测试鼠标');
      await model.research('测试鼠标');
      expect(repository.calls, 1);
      model.dispose();
      repository.pending.complete(_report());
      await first;
    },
  );
}
