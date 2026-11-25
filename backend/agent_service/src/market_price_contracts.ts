import { z } from 'zod';

export const marketPriceRequestSchema = z.object({
  productName: z.string().trim().min(2).max(120),
  market: z.string().trim().min(1).max(80),
  currency: z.literal('CNY'),
}).strict();

export const priceExtractionSchema = z.object({
  clarification: z.string().nullable(),
  quotes: z.array(z.object({
    sourceId: z.string(),
    seller: z.string(),
    price: z.number().positive(),
    priceText: z.string().min(1).max(200),
    matchesProduct: z.boolean(),
    isNewRetail: z.boolean(),
    priceBasis: z.enum(['current_sale', 'conditional', 'reference', 'historical', 'unknown']),
  })).max(10),
  limitations: z.array(z.string()).max(5),
});

export type MarketPriceRequest = z.infer<typeof marketPriceRequestSchema>;
export type PriceExtraction = z.infer<typeof priceExtractionSchema>;
export type MarketPriceStatus = 'completed' | 'insufficient_data' | 'needs_clarification'
  | 'failed' | 'invalid_request' | 'not_configured' | 'busy' | 'service_unavailable';

export type PageAccessStatus = 'readable' | 'login_required' | 'verification_required'
  | 'not_available' | 'no_price' | 'empty_content' | 'fetch_timeout' | 'fetch_failed' | 'invalid_response';

export interface PlatformSearchDiagnostic {
  platform: string;
  status: 'completed' | 'failed';
  resultCount: number;
  productPageCount: number;
  message: string;
}

export interface PriceRetrievalDiagnostics {
  searches: PlatformSearchDiagnostic[];
  attemptedPages: number;
  readablePages: number;
  evidencePages: number;
  loginRequiredPages: number;
  verificationRequiredPages: number;
  modelInvoked: boolean;
}

export interface MarketPriceSource {
  id: string;
  title: string;
  url: string;
  publishedAt: string | null;
  platform: string;
  productId: string;
  fetchedAt: string | null;
  accessStatus?: PageAccessStatus;
  accessMessage?: string;
}

export interface MarketPriceQuote {
  sourceId: string;
  seller: string;
  price: number;
  priceText: string;
}

export interface MarketPriceReport {
  status: MarketPriceStatus;
  message: string;
  productName: string;
  market: string;
  currency: string;
  averagePrice: number | null;
  lowestPrice: number | null;
  highestPrice: number | null;
  sampleCount: number;
  sourceCount: number;
  summary: string;
  methodology: string;
  limitations: string[];
  researchedAt: string;
  cached: boolean;
  quotes: MarketPriceQuote[];
  sources: MarketPriceSource[];
  diagnostics?: PriceRetrievalDiagnostics;
}

export const marketPricePolicyVersion = 'platform-product-v2';
export const methodology = '仅采用京东、淘宝、天猫、拼多多商品详情页实时读取到的同型号同规格全新在售价。资讯转载、比价站、搜索摘要、参考/划线/历史价格，以及有个人优惠、会员、补贴、预售或拼团条件的价格不参与计算。同一平台商品ID最多一条，去重后等权计算；少于3条不计算均价。至少3条候选时，超出中位数÷2.5至中位数×2.5范围的异常报价暂不纳入。商品页在售价不等于实际订单成交价。';

export function emptyMarketReport(
  query: MarketPriceRequest,
  status: MarketPriceStatus,
  message: string,
  now = new Date(),
): MarketPriceReport {
  return {
    ...query, status, message, averagePrice: null, lowestPrice: null, highestPrice: null,
    sampleCount: 0, sourceCount: 0, summary: '', methodology, limitations: [],
    researchedAt: now.toISOString(), cached: false, quotes: [], sources: [],
  };
}
