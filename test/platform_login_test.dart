import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:goods_search/data/services/platform_browser_service.dart';
import 'package:goods_search/domain/models/current_price_report.dart';
import 'package:goods_search/domain/models/shopping_platform.dart';
import 'package:goods_search/ui/features/platform_login/view_models/platform_login_view_model.dart';
import 'package:goods_search/ui/features/platform_login/views/platform_login_page.dart';

void main() {
  test(
    'only canonical official products are opened, rejecting spoofed hosts and executable links',
    () async {
      final opened = <Uri>[];
      final service = PlatformBrowserService(
        opener: (url) async {
          opened.add(url);
          return true;
        },
      );
      for (final address in [
        'https://item.jd.com/1001.html',
        'https://item.taobao.com/item.htm?id=1002',
        'https://detail.tmall.com/item.htm?id=1003',
        'https://mobile.yangkeduo.com/goods.html?goods_id=1004',
      ]) {
        expect(await service.openProduct(Uri.parse(address)), isTrue);
      }
      for (final address in [
        'javascript:alert(1)',
        'http://item.jd.com/1001.html',
        'https://item.jd.com.evil.example/1001.html',
        'https://item.jd.com@evil.example/1001.html',
        'https://item.jd.com/1001.html?redirect=https://evil.example',
        'https://item.taobao.com/item.htm?id=1&id=2',
        'https://news.jd.com/1001.html',
      ]) {
        expect(
          () => service.openProduct(Uri.parse(address)),
          throwsArgumentError,
        );
      }
      expect(opened.length, 4);
    },
  );

  test(
    'launching a page blocks duplicate taps and does not claim a verified sign-in',
    () async {
      final pending = Completer<bool>();
      var calls = 0;
      final model = PlatformLoginViewModel(
        PlatformBrowserService(
          opener: (url) {
            calls++;
            return pending.future;
          },
        ),
      );
      final first = model.openLogin(ShoppingPlatform.jd);
      await model.openLogin(ShoppingPlatform.taobao);
      expect(calls, 1);
      expect(model.isOpening, isTrue);
      pending.complete(true);
      await first;
      expect(model.notice, contains('已请求打开京东官方登录页'));
      expect(model.notice, isNot(contains('已登录')));
      expect(model.isOpening, isFalse);
      model.dispose();
    },
  );

  test(
    'disposing while the official page opens ignores the later completion',
    () async {
      final pending = Completer<bool>();
      final model = PlatformLoginViewModel(
        PlatformBrowserService(opener: (_) => pending.future),
      );
      final opening = model.openLogin(ShoppingPlatform.jd);
      model.dispose();
      pending.complete(true);
      await opening;
    },
  );

  testWidgets(
    'offers four official login pages and explains that browser login is separate from research',
    (tester) async {
      final opened = <Uri>[];
      await tester.pumpWidget(
        MaterialApp(
          home: PlatformLoginPage(
            browserService: PlatformBrowserService(
              opener: (url) async {
                opened.add(url);
                return true;
              },
            ),
          ),
        ),
      );
      expect(find.byKey(const Key('platform-login-scope')), findsOneWidget);
      for (final platform in ShoppingPlatform.values) {
        final button = find.byKey(ValueKey('login-platform-${platform.name}'));
        await tester.ensureVisible(button);
        await tester.tap(button);
        await tester.pumpAndSettle();
        expect(opened.last, platform.loginUri);
        expect(
          find.textContaining('已请求打开${platform.label}官方登录页'),
          findsOneWidget,
        );
      }
      expect(find.text('已登录'), findsNothing);
      expect(opened.length, 4);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'launch failures remain retryable and never expose upstream details',
    (tester) async {
      var calls = 0;
      await tester.pumpWidget(
        MaterialApp(
          home: PlatformLoginPage(
            browserService: PlatformBrowserService(
              opener: (_) async {
                calls++;
                throw StateError('private-session-details');
              },
            ),
          ),
        ),
      );
      final button = find.byKey(const ValueKey('login-platform-jd'));
      await tester.ensureVisible(button);
      await tester.tap(button);
      await tester.pumpAndSettle();
      expect(find.text('无法打开官方页面，请检查浏览器设置或稍后重试。'), findsOneWidget);
      expect(find.textContaining('private-session-details'), findsNothing);
      expect(tester.widget<FilledButton>(button).onPressed, isNotNull);
      await tester.tap(button);
      await tester.pumpAndSettle();
      expect(calls, 2);
    },
  );

  testWidgets(
    'opens a researched product in the platform browser after the login entry',
    (tester) async {
      final opened = <Uri>[];
      final product = Uri.parse('https://item.jd.com/1001.html');
      await tester.pumpWidget(
        MaterialApp(
          home: PlatformLoginPage(
            browserService: PlatformBrowserService(
              opener: (url) async {
                opened.add(url);
                return true;
              },
            ),
            sources: [
              PriceReference(
                id: 's1',
                title: '京东商品 1001',
                url: product,
                platform: '京东',
                productId: '1001',
              ),
            ],
          ),
        ),
      );
      final login = find.byKey(const ValueKey('login-platform-jd'));
      await tester.ensureVisible(login);
      await tester.tap(login);
      await tester.pumpAndSettle();
      final item = find.byKey(const ValueKey('platform-product-s1'));
      await tester.ensureVisible(item);
      await tester.tap(item);
      await tester.pumpAndSettle();
      expect(opened, [ShoppingPlatform.jd.loginUri, product]);
      expect(find.textContaining('已请求打开平台商品页'), findsOneWidget);
    },
  );

  testWidgets('login chooser fits small, landscape and wide windows', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);
    await tester.pumpWidget(const MaterialApp(home: PlatformLoginPage()));
    for (final size in [
      const Size(320, 568),
      const Size(844, 390),
      const Size(1440, 900),
    ]) {
      tester.view.physicalSize = size;
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(find.byKey(const ValueKey('login-platform-jd')), findsOneWidget);
    }
  });
}
