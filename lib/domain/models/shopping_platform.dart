enum ShoppingPlatform {
  jd('京东', 'https://passport.jd.com/new/login.aspx'),
  taobao('淘宝', 'https://login.taobao.com/member/login.jhtml'),
  tmall('天猫', 'https://login.tmall.com/'),
  pinduoduo('拼多多', 'https://mobile.yangkeduo.com/login.html');

  const ShoppingPlatform(this.label, this.loginAddress);
  final String label;
  final String loginAddress;
  Uri get loginUri => Uri.parse(loginAddress);

  /// Only the canonical product pages accepted by the price research service.
  bool acceptsProductUri(Uri uri) {
    if (uri.scheme != 'https' ||
        uri.userInfo.isNotEmpty ||
        uri.hasPort ||
        uri.hasFragment) {
      return false;
    }
    bool itemId(String name) =>
        uri.queryParametersAll.length == 1 &&
        uri.queryParametersAll[name]?.length == 1 &&
        RegExp(r'^\d{1,24}$').hasMatch(uri.queryParameters[name] ?? '');
    return switch (this) {
      ShoppingPlatform.jd =>
        uri.host == 'item.jd.com' &&
            RegExp(r'^/\d{1,24}\.html$').hasMatch(uri.path) &&
            !uri.hasQuery,
      ShoppingPlatform.taobao =>
        uri.host == 'item.taobao.com' &&
            uri.path == '/item.htm' &&
            itemId('id'),
      ShoppingPlatform.tmall =>
        uri.host == 'detail.tmall.com' &&
            uri.path == '/item.htm' &&
            itemId('id'),
      ShoppingPlatform.pinduoduo =>
        uri.host == 'mobile.yangkeduo.com' &&
            uri.path == '/goods.html' &&
            itemId('goods_id'),
    };
  }

  static ShoppingPlatform? forProductUri(Uri uri) {
    for (final platform in values) {
      if (platform.acceptsProductUri(uri)) return platform;
    }
    return null;
  }
}
