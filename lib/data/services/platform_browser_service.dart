import 'package:flutter/foundation.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../domain/models/shopping_platform.dart';

typedef OfficialPageOpener = Future<bool> Function(Uri url);

/// Opens the platform's own pages. This does not grant the research API access
/// to browser sessions or infer that a user has successfully signed in.
class PlatformBrowserService {
  PlatformBrowserService({OfficialPageOpener? opener})
    : _opener = opener ?? _launch;
  final OfficialPageOpener _opener;

  Future<bool> openLogin(ShoppingPlatform platform) =>
      _opener(platform.loginUri);

  Future<bool> openProduct(Uri url) {
    if (ShoppingPlatform.forProductUri(url) == null) {
      throw ArgumentError(
        'Only supported official product pages can be opened.',
      );
    }
    return _opener(url);
  }

  static Future<bool> _launch(Uri url) {
    final mobile =
        !kIsWeb &&
        [
          TargetPlatform.android,
          TargetPlatform.iOS,
        ].contains(defaultTargetPlatform);
    // Invoke directly from the tap, without an async capability check that can
    // lose the browser's user gesture and cause a blocked popup on Web.
    return launchUrl(
      url,
      mode: mobile ? LaunchMode.inAppBrowserView : LaunchMode.platformDefault,
      browserConfiguration: const BrowserConfiguration(showTitle: true),
      webOnlyWindowName: '_blank',
    );
  }
}
