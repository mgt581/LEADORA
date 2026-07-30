import type { WebsiteAudit } from './types';

const socialHosts = ['facebook.com', 'instagram.com', 'linkedin.com', 'x.com', 'twitter.com', 'youtube.com', 'tiktok.com'];
const clean = (value: string) => value.replace(/\s+/g, ' ').trim();
const absolute = (href: string, origin: string) => { try { return new URL(href, origin).toString(); } catch { return null; } };

/** Extracts only information published by the website owner. It never guesses an address. */
export function inspectPublicWebsite(html: string, website: string) {
  const title = clean(html.match(/<title[^>]*>([\s\S]*?)<\/title>/i)?.[1] ?? '');
  const description = clean(html.match(/<meta[^>]+name=["']description["'][^>]+content=["']([^"']*)/i)?.[1] ?? html.match(/<meta[^>]+content=["']([^"']*)["'][^>]+name=["']description/i)?.[1] ?? '');
  const h1Tags = [...html.matchAll(/<h1[^>]*>([\s\S]*?)<\/h1>/gi)].map(match => clean(match[1].replace(/<[^>]+>/g, ''))).filter(Boolean).slice(0, 5);
  const imageTags = html.match(/<img\b[^>]*>/gi) ?? [];
  const missingAltText = imageTags.filter(tag => !/\balt\s*=\s*["'][^"']+["']/i.test(tag)).length;
  const emails = [...html.matchAll(/(?:mailto:)?([A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,})/gi)].map(match => match[1].toLowerCase()).filter(email => !/example\.|wixpress|sentry|cloudflare/i.test(email));
  const phone = html.match(/(?:tel:|\+?44\s?\(?0?\d{2,4}\)?[\s\d-]{6,})/i)?.[0]?.replace(/^tel:/i, '').trim() ?? null;
  const links = [...html.matchAll(/<a\b[^>]*href=["']([^"']+)["'][^>]*>/gi)].map(match => absolute(match[1], website)).filter((link): link is string => Boolean(link));
  const contactPageUrl = links.find(link => /\/(contact|contact-us|enquiries|enquire)(\/|$|\?)/i.test(link)) ?? null;
  const socialLinks = [...new Set(links.filter(link => socialHosts.some(host => new URL(link).hostname.includes(host))))];
  const googleBusinessProfileDetected = links.some(link => /google\.[^/]+\/maps|g\.page|maps\.app\.goo\.gl/i.test(link));
  const hasViewport = /<meta[^>]+name=["']viewport/i.test(html);
  const hasLang = /<html[^>]+lang=["']/i.test(html);
  const hasTitle = Boolean(title); const hasDescription = Boolean(description); const hasH1 = Boolean(h1Tags.length);
  const basicSeoScore = Math.max(0, Math.min(100, 20 + (hasTitle ? 25 : 0) + (hasDescription ? 25 : 0) + (hasH1 ? 20 : 0) + (hasViewport ? 10 : 0)));
  const accessibilityScore = Math.max(0, Math.min(100, 45 + (hasLang ? 15 : 0) + (hasH1 ? 15 : 0) + (hasViewport ? 10 : 0) - Math.min(30, missingAltText * 3)));
  const overallScore = Math.round((basicSeoScore * .6) + (accessibilityScore * .4));
  const notes = [!hasTitle && 'No page title found', !hasDescription && 'No meta description found', !hasH1 && 'No H1 heading found', missingAltText > 0 && `${missingAltText} image${missingAltText === 1 ? '' : 's'} may be missing alt text`, !hasViewport && 'No mobile viewport tag found'].filter((note): note is string => Boolean(note));
  return { title, description, h1Tags, missingAltText, emails: [...new Set(emails)].slice(0, 5), phone, contactPageUrl, socialLinks, googleBusinessProfileDetected, basicSeoScore, accessibilityScore, overallScore, notes };
}

export async function auditPublicWebsite(rawUrl: string): Promise<{ website: string; businessName: string; contactEmail: string | null; phoneNumber: string | null; contactPageUrl: string | null; audit: WebsiteAudit }> {
  const url = new URL(/^https?:\/\//i.test(rawUrl) ? rawUrl : `https://${rawUrl}`);
  if (!['http:', 'https:'].includes(url.protocol)) throw new Error('Only public HTTP(S) websites can be analysed.');
  // Do not turn the audit endpoint into a proxy for local or private infrastructure.
  const host = url.hostname.toLowerCase();
  if (host === 'localhost' || host.endsWith('.local') || /^127\.|^10\.|^192\.168\.|^169\.254\.|^0\.|^\[?::1\]?$/i.test(host)) throw new Error('Only publicly reachable websites can be analysed.');
  const response = await fetch(url, { headers: { 'user-agent': 'LEADORA/1.0 (public website audit)' }, redirect: 'follow', signal: AbortSignal.timeout(12_000) });
  if (!response.ok) throw new Error(`The website could not be read (${response.status}).`);
  const html = await response.text();
  if (html.length > 2_000_000) throw new Error('The website response is too large to analyse safely.');
  const result = inspectPublicWebsite(html, response.url);
  const origin = new URL(response.url).origin;
  let contactEmail = result.emails[0] ?? null;
  let phoneNumber = result.phone;
  if (!contactEmail && result.contactPageUrl && new URL(result.contactPageUrl).origin === origin) {
    try {
      const contactResponse = await fetch(result.contactPageUrl, { headers: { 'user-agent': 'LEADORA/1.0 (public website audit)' }, redirect: 'follow', signal: AbortSignal.timeout(8_000) });
      if (contactResponse.ok) {
        const contactHtml = await contactResponse.text();
        if (contactHtml.length <= 1_000_000) {
          const contactResult = inspectPublicWebsite(contactHtml, contactResponse.url);
          contactEmail = contactResult.emails[0] ?? null;
          phoneNumber = phoneNumber ?? contactResult.phone;
        }
      }
    } catch { /* The homepage audit remains valid if a contact page is unavailable. */ }
  }
  return { website: origin, businessName: result.title || new URL(response.url).hostname.replace(/^www\./, ''), contactEmail, phoneNumber, contactPageUrl: result.contactPageUrl, audit: { auditedAt: new Date().toISOString(), websiteSpeed: 'not_measured', mobileFriendly: 'not_measured', https: new URL(response.url).protocol === 'https:', metaTitle: result.title, metaDescription: result.description, h1Tags: result.h1Tags, missingAltText: result.missingAltText, brokenLinks: 0, basicSeoScore: result.basicSeoScore, accessibilityScore: result.accessibilityScore, googleBusinessProfileDetected: result.googleBusinessProfileDetected, socialLinks: result.socialLinks, overallScore: result.overallScore, notes: result.notes } };
}
