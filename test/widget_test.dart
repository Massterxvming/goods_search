import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:goods_search/app.dart';
import 'package:goods_search/data/repositories/backend_repository.dart';

void main() {
  testWidgets(
    'All four categories open price research and return to the home tab',
    (tester) async {
      await tester.pumpWidget(
        GoodsSearchApp(backendRepository: _FakeRepository()),
      );
      await tester.pumpAndSettle();

      expect(find.text('已连接'), findsOneWidget);
      for (final title in ['数码家电', '食品生鲜', '日用百货', '出行能源']) {
        await tester.tap(find.byKey(ValueKey('category-$title')));
        await tester.pumpAndSettle();
        expect(
          find.byKey(ValueKey('market-price-page-$title')),
          findsOneWidget,
        );
        await tester.tap(find.byTooltip('返回'));
        await tester.pumpAndSettle();
        expect(find.byKey(const Key('tab-home')), findsOneWidget);
      }
    },
  );

  testWidgets('Profile tab, settings demo, and home tab are navigable', (
    tester,
  ) async {
    await tester.pumpWidget(
      GoodsSearchApp(backendRepository: _FakeRepository()),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('tab-profile')));
    await tester.pumpAndSettle();
    expect(find.text('你好，探索者'), findsOneWidget);
    await tester.ensureVisible(find.byKey(const Key('profile-platform-login')));
    await tester.tap(find.byKey(const Key('profile-platform-login')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('platform-login-page')), findsOneWidget);
    await tester.tap(find.byTooltip('返回'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('偏好设置'));
    await tester.tap(find.text('偏好设置'));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('demo-page-偏好设置')), findsOneWidget);
    await tester.tap(find.byTooltip('返回'));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('tab-home')));
    await tester.pumpAndSettle();
    expect(find.text('从日常，发现变化。'), findsOneWidget);
  });

  testWidgets(
    'Four cards remain visible on small, tall, landscape and wide screens',
    (tester) async {
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.view.resetPhysicalSize);
      await tester.pumpWidget(
        GoodsSearchApp(backendRepository: _FakeRepository()),
      );

      for (final size in [
        const Size(320, 568),
        const Size(390, 844),
        const Size(844, 390),
        const Size(1440, 900),
      ]) {
        tester.view.physicalSize = size;
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        final navigationTop = tester.getTopLeft(find.byType(NavigationBar)).dy;
        for (final title in ['数码家电', '食品生鲜', '日用百货', '出行能源']) {
          final card = find.byKey(ValueKey('category-$title'));
          expect(card.hitTestable(), findsOneWidget);
          expect(tester.getRect(card).bottom, lessThanOrEqualTo(navigationTop));
        }
      }
    },
  );

  testWidgets('An offline connection can be retried from the profile', (
    tester,
  ) async {
    final repository = _FakeRepository(failFirst: true);
    await tester.pumpWidget(GoodsSearchApp(backendRepository: repository));
    await tester.pumpAndSettle();
    expect(find.text('离线演示'), findsOneWidget);
    await tester.tap(find.byKey(const Key('tab-profile')));
    await tester.pumpAndSettle();
    expect(find.text('当前为离线演示'), findsOneWidget);
    final retry = find.byTooltip('重新连接');
    await tester.ensureVisible(retry);
    await tester.tap(retry);
    await tester.pumpAndSettle();
    expect(find.text('服务已连接'), findsOneWidget);
    expect(repository.calls, 2);
  });
}

class _FakeRepository implements BackendRepository {
  _FakeRepository({this.failFirst = false});
  final bool failFirst;
  int calls = 0;

  @override
  Future<void> checkConnection() async {
    calls++;
    if (failFirst && calls == 1) throw StateError('Offline');
  }

  @override
  void dispose() {}
}
