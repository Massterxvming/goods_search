export interface PlatformProduct {
  platform: '京东' | '淘宝' | '天猫' | '拼多多';
  productId: string;
  canonicalUrl: string;
}

/** Only known product-detail routes qualify, never platform news, search or affiliate links. */
export function getPlatformProduct(value: string): PlatformProduct | null {
  try {
    const url = new URL(value);
    if (!['http:', 'https:'].includes(url.protocol) || url.username || url.password
      || (url.port && !['80', '443'].includes(url.port))) return null;
    const host = url.hostname.toLowerCase();
    const path = url.pathname;
    const id = (name: string) => {
      const values = url.searchParams.getAll(name);
      return values.length === 1 && /^\d{1,24}$/.test(values[0]!) ? values[0]! : null;
    };
    const jd = host === 'item.jd.com' ? path.match(/^\/(\d{1,24})\.html$/)?.[1]
      : host === 'item.m.jd.com' ? path.match(/^\/product\/(\d{1,24})\.html$/)?.[1]
        ?? (path === '/ware/view.action' ? id('wareId') : null) : null;
    if (jd) return { platform: '京东', productId: jd, canonicalUrl: `https://item.jd.com/${jd}.html` };
    const taobaoRoute = (host === 'item.taobao.com' && path === '/item.htm')
      || (host === 'h5.m.taobao.com' && path === '/awp/core/detail.htm')
      || (host === 'main.m.taobao.com' && path === '/detail/index.html');
    if (taobaoRoute && id('id')) return { platform: '淘宝', productId: id('id')!, canonicalUrl: `https://item.taobao.com/item.htm?id=${id('id')}` };
    if (['detail.tmall.com', 'detail.m.tmall.com'].includes(host) && path === '/item.htm' && id('id')) {
      return { platform: '天猫', productId: id('id')!, canonicalUrl: `https://detail.tmall.com/item.htm?id=${id('id')}` };
    }
    if (host === 'mobile.yangkeduo.com' && /^\/goods\d*\.html$/.test(path) && id('goods_id')) {
      return { platform: '拼多多', productId: id('goods_id')!, canonicalUrl: `https://mobile.yangkeduo.com/goods.html?goods_id=${id('goods_id')}` };
    }
    return null;
  } catch { return null; }
}

export function platformSearchQueries(productName: string): string[] {
  return ['jd.com', 'taobao.com', 'tmall.com', 'yangkeduo.com'].map(domain => {
    const suffix = ` site:${domain}`;
    return Array.from(productName).slice(0, 128 - Array.from(suffix).length).join('') + suffix;
  });
}
