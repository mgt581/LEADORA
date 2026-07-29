/** Core records deliberately do not depend on a provider (Hunter, Apollo, etc.). */
export type LeadSource = 'public_website' | 'manual' | 'apollo' | 'hunter' | 'google_maps';
export type ApprovalStatus = 'pending' | 'approved' | 'rejected' | 'sent' | 'follow_up_due' | 'send_failed';

export type WebsiteAudit = {
  auditedAt: string; websiteSpeed: 'not_measured'; mobileFriendly: 'not_measured'; https: boolean;
  metaTitle: string; metaDescription: string; h1Tags: string[]; missingAltText: number;
  brokenLinks: number; basicSeoScore: number; accessibilityScore: number;
  googleBusinessProfileDetected: boolean; socialLinks: string[]; overallScore: number;
  notes: string[];
};

export type PublicLead = {
  id: string; businessName: string; website: string; contactEmail: string | null;
  phoneNumber: string | null; location: string | null; googleMapsUrl: string;
  industry: string | null; contactPageUrl: string | null; source: LeadSource;
  createdAt: string; audit: WebsiteAudit;
};

export interface LeadSourceProvider {
  id: string;
  displayName: string;
  find(input: { query: string; location?: string; limit: number }): Promise<Partial<PublicLead>[]>;
}
