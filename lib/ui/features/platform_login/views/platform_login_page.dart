import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../../../data/services/platform_browser_service.dart';
import '../../../../domain/models/current_price_report.dart';
import '../../../../domain/models/shopping_platform.dart';
import '../view_models/platform_login_view_model.dart';

const _ink = Color(0xFF203D34);
const _muted = Color(0xFF7C8980);

class PlatformLoginPage extends StatefulWidget {
  const PlatformLoginPage({
    super.key,
    this.browserService,
    this.sources = const [],
  });
  final PlatformBrowserService? browserService;
  final List<PriceReference> sources;

  @override
  State<PlatformLoginPage> createState() => _PlatformLoginPageState();
}

class _PlatformLoginPageState extends State<PlatformLoginPage> {
  late final _viewModel = PlatformLoginViewModel(
    widget.browserService ?? PlatformBrowserService(),
  );

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    key: const Key('platform-login-page'),
    appBar: AppBar(
      title: const Text(
        '平台登录',
        style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
      ),
      leading: IconButton(
        tooltip: '返回',
        onPressed: () => Navigator.pop(context),
        icon: const Icon(Icons.arrow_back_rounded),
      ),
    ),
    body: SafeArea(
      top: false,
      child: ListenableBuilder(
        listenable: _viewModel,
        builder: (context, _) => SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 14, 20, 36),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 800),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE9F1E4),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          Icons.open_in_browser_rounded,
                          color: _ink,
                          size: 27,
                        ),
                        const SizedBox(height: 18),
                        const Text(
                          '在官方页面，登录你的账号。',
                          style: TextStyle(
                            fontSize: 23,
                            fontWeight: FontWeight.w700,
                            height: 1.4,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          kIsWeb
                              ? '选择平台后会打开新的官方页面，请在该页面完成扫码、短信或账号登录。'
                              : '选择平台后会打开官方页面；iOS / Android 优先使用应用内浏览器。',
                          style: const TextStyle(
                            fontSize: 12,
                            height: 1.9,
                            color: _muted,
                          ),
                        ),
                        const SizedBox(height: 13),
                        const Text(
                          '登录用于你直接查看平台商品；当前自动调研尚未接入此浏览器的登录状态。',
                          key: Key('platform-login-scope'),
                          style: TextStyle(
                            fontSize: 12,
                            height: 1.9,
                            color: _ink,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final width = constraints.maxWidth >= 600
                          ? (constraints.maxWidth - 14) / 2
                          : constraints.maxWidth;
                      return Wrap(
                        spacing: 14,
                        runSpacing: 14,
                        children: [
                          for (final platform in ShoppingPlatform.values)
                            SizedBox(
                              width: width,
                              child: _PlatformCard(
                                platform: platform,
                                enabled: !_viewModel.isOpening,
                                onOpen: () =>
                                    unawaited(_viewModel.openLogin(platform)),
                              ),
                            ),
                        ],
                      );
                    },
                  ),
                  if (_viewModel.notice != null ||
                      _viewModel.error != null) ...[
                    const SizedBox(height: 18),
                    Container(
                      key: const Key('platform-open-result'),
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: _viewModel.error == null
                            ? const Color(0xFFF0F5ED)
                            : const Color(0xFFFAEFE6),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        _viewModel.error ?? _viewModel.notice!,
                        style: const TextStyle(fontSize: 12, height: 1.8),
                      ),
                    ),
                  ],
                  if (widget.sources.isNotEmpty) ...[
                    const SizedBox(height: 26),
                    const Text(
                      '登录后，打开刚才找到的商品',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      '使用登录时的同一浏览器，核对型号、规格和页面在售价。',
                      style: TextStyle(
                        fontSize: 11,
                        height: 1.8,
                        color: _muted,
                      ),
                    ),
                    const SizedBox(height: 14),
                    for (final source in widget.sources)
                      Card(
                        elevation: 0,
                        color: Colors.white,
                        child: ListTile(
                          key: ValueKey('platform-product-${source.id}'),
                          enabled:
                              !_viewModel.isOpening &&
                              ShoppingPlatform.forProductUri(source.url) !=
                                  null,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 18,
                            vertical: 8,
                          ),
                          title: Text(
                            source.title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 13),
                          ),
                          subtitle: Padding(
                            padding: const EdgeInsets.only(top: 7),
                            child: Text(
                              '${source.platform} · 商品 ${source.productId}',
                              style: const TextStyle(
                                fontSize: 11,
                                color: _muted,
                              ),
                            ),
                          ),
                          trailing: const Icon(
                            Icons.open_in_new_rounded,
                            size: 18,
                          ),
                          onTap: () =>
                              unawaited(_viewModel.openProduct(source.url)),
                        ),
                      ),
                  ],
                  const SizedBox(height: 24),
                  const Text(
                    '账号与登录状态由平台页面处理。价迹不会将本次浏览器登录标记为平台 API 授权。',
                    style: TextStyle(fontSize: 11, height: 1.8, color: _muted),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    ),
  );
}

class _PlatformCard extends StatelessWidget {
  const _PlatformCard({
    required this.platform,
    required this.enabled,
    required this.onOpen,
  });
  final ShoppingPlatform platform;
  final bool enabled;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(22),
      border: Border.all(color: const Color(0xFFE5EBE2)),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 42,
              height: 42,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: switch (platform) {
                  ShoppingPlatform.jd => const Color(0xFFF8E6E4),
                  ShoppingPlatform.taobao => const Color(0xFFFBEDDD),
                  ShoppingPlatform.tmall => const Color(0xFFEAEBE8),
                  ShoppingPlatform.pinduoduo => const Color(0xFFF8E7E2),
                },
                borderRadius: BorderRadius.circular(13),
              ),
              child: Text(
                switch (platform) {
                  ShoppingPlatform.jd => '京',
                  ShoppingPlatform.taobao => '淘',
                  ShoppingPlatform.tmall => '猫',
                  ShoppingPlatform.pinduoduo => '拼',
                },
                style: const TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                platform.label,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 13),
        SelectableText(
          platform.loginUri.host,
          style: const TextStyle(fontSize: 11, color: _muted),
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: FilledButton.tonalIcon(
            key: ValueKey('login-platform-${platform.name}'),
            onPressed: enabled ? onOpen : null,
            icon: const Icon(Icons.open_in_new_rounded, size: 16),
            label: Text(
              '打开${platform.label}官方登录页',
              style: const TextStyle(fontSize: 12),
            ),
          ),
        ),
      ],
    ),
  );
}
