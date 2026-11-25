import 'package:flutter/foundation.dart';

import '../../../../data/services/platform_browser_service.dart';
import '../../../../domain/models/shopping_platform.dart';

class PlatformLoginViewModel extends ChangeNotifier {
  PlatformLoginViewModel(this._browser);
  final PlatformBrowserService _browser;
  bool _busy = false;
  bool _disposed = false;
  String? _notice;
  String? _error;

  bool get isOpening => _busy;
  String? get notice => _notice;
  String? get error => _error;

  Future<void> openLogin(ShoppingPlatform platform) => _open(
    () => _browser.openLogin(platform),
    '已请求打开${platform.label}官方登录页。请在平台页面完成登录；若没有出现新页面，请允许浏览器弹出窗口后重试。',
  );

  Future<void> openProduct(Uri url) => _open(
    () => _browser.openProduct(url),
    '已请求打开平台商品页。请在刚才登录的同一浏览器中查看具体规格和在售价。',
  );

  Future<void> _open(Future<bool> Function() action, String notice) async {
    if (_busy || _disposed) return;
    _busy = true;
    _notice = null;
    _error = null;
    notifyListeners();
    try {
      final opened = await action();
      if (_disposed) return;
      if (opened) {
        _notice = notice;
      } else {
        _error = '无法打开官方页面，请检查浏览器设置或稍后重试。';
      }
    } catch (_) {
      if (_disposed) return;
      _error = '无法打开官方页面，请检查浏览器设置或稍后重试。';
    } finally {
      if (!_disposed) {
        _busy = false;
        notifyListeners();
      }
    }
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
