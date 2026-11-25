import { z } from 'zod';

export const researchRequestSchema = z.object({
  productName: z.string().trim().min(1).max(200),
  market: z.string().trim().min(1).max(80),
  currency: z.string().regex(/^[A-Z]{3}$/),
  historyMonths: z.number().int().min(1).max(120),
  forecastMonths: z.number().int().min(0).max(12),
}).strict();

// A plan deliberately contains no purported historical prices or predictions.
export const researchPlanSchema = z.object({
  summary: z.string(),
  requiredData: z.array(z.string()),
  steps: z.array(z.string()),
});

export type ResearchRequest = z.infer<typeof researchRequestSchema>;
export type ResearchPlan = z.infer<typeof researchPlanSchema>;
export type ResearchResultStatus =
  | 'not_configured' | 'invalid_request' | 'service_unavailable'
  | 'planned' | 'failed' | 'busy';

export interface ResearchResult {
  status: ResearchResultStatus;
  message: string;
  summary: string | null;
  requiredData: string[];
  steps: string[];
}

export function emptyResult(status: ResearchResultStatus, message: string): ResearchResult {
  return { status, message, summary: null, requiredData: [], steps: [] };
}
