import { NextRequest, NextResponse } from 'next/server';
import { getOutreachWorkflow, type OutreachWorkflowConfig } from '@/lib/outreach-workflows';
import { decodeHtmlEntities } from '@/lib/text';
import { isPublicBusinessEmail } from '@/lib/leads/public-email';
import { auditPublicWebsite } from '@/lib/leads/public-website';
import { proposalFor } from '@/lib/proposal-copy';
import { isKnownLead, normaliseLeadEmail, normaliseLeadName, normaliseLeadWebsite } from '@/lib/leads/identity';

export const runtime = 'nodejs';

type OsmElement = { id: number; type: string; lat?: number; lon?: number; center?: { lat: number; lon: number }; tags?: Record<string, string> };

const clean = (value: string) => decodeHtmlEntities(value).replace(/\s+/g, ' ').trim();
const publicDirectoryMirrors = [
  'https://overpass.atownsend.org.uk/api/interpreter',
  'https://overpass-api.de/api/interpreter',
  'https://overpass.private.coffee/api/interpreter',
];
const publicDirectoryTimeoutMs = 18_000;
const publicDirectoryDeadlineMs = 21_000;
const dorsetBounds = '50.50,-2.95,51.10,-1.70';
// Keep the Digital website-only discovery path in the same deploy as sender-domain updates.
// Combined deploy trigger.

function normaliseWebsite(value: string) {
  const trimmed = value.trim();
  return /^https?:\/\//i.test(trimmed) ? trimmed : `https://${trimmed}`;
}
function location(tags: Record<string, string>) {
  return [tags['addr:housenumber'], tags['addr:street'], tags['addr:city'] || tags['addr:town'] || tags['addr:village'], tags['addr:postcode']].filter(Boolean).join(', ') || 'Dorset';
}
function industry(tags: Record<string, string>) {
  return tags.office || tags.amenity || tags.tourism || tags.shop || tags.craft || 'Local business';
}
function matchesWorkflow(tags: Record<string, string>, config: OutreachWorkflowConfig) {
  const searchable = Object.entries(tags).flat().join(' ').toLowerCase();
  return config.prospectCategories.some(category => searchable.includes(category));
}
function relevanceScore(tags: Record<string, string>, config: OutreachWorkflowConfig, website: string, email: string, phone: string) {
  const searchable = Object.entries(tags).flat().join(' ').toLowerCase();
  const categoryMatches = config.prospectCategories.reduce((total, category) => total + (searchable.includes(category) ? 1 : 0), 0);
  return categoryMatches * 10 + (email ? 8 : 0) + (website ? 5 : 0) + (phone ? 2 : 0);
}

function publicDirectoryQuery(config: OutreachWorkflowConfig, digitalDiscovery: boolean) {
  if (digitalDiscovery) return `[out:json][timeout:16];(nwr["name"]["website"](${dorsetBounds});nwr["name"]["contact:website"](${dorsetBounds}););out center tags 800;`;
  const selectors = config.companyId === 'bryant-construction' ? [
    '["office"~"estate_agent|property_management|architect|surveying"]',
    '["craft"~"builder|carpenter|roofer|plumber|electrician"]',
    '["shop"~"estate_agent|trade"]',
    '["amenity"~"school|hospital|clinic|office"]',
  ] : config.companyId === 'mr-white-teeth' ? [
    '["shop"~"beauty|hairdresser|cosmetics|wedding"]',
    '["amenity"~"spa"]',
    '["craft"~"beautician"]',
  ] : [
    '["office"]',
    '["amenity"~"restaurant|pub|cafe|school|clinic|hospital|gym|community_centre"]',
    '["tourism"~"hotel|hostel|guest_house"]',
    '["shop"~"retail|supermarket"]',
  ];
  const statements = selectors.map(filter => `nwr["name"]${filter}(${dorsetBounds});`).join('');
  return `[out:json][timeout:22];(${statements});out center tags 1200;`;
}

async function fetchPublicDirectory(query: string) {
  for (let pass = 0; pass < 2; pass += 1) {
    const attempts = publicDirectoryMirrors.map(async endpoint => {
      const response = await fetch(endpoint, {
        method: 'POST',
        headers: { 'content-type': 'application/x-www-form-urlencoded', 'user-agent': 'LeadRally/2.0 public-contact discovery (https://leadrally.co.uk)' },
        body: new URLSearchParams({ data: query }),
        signal: AbortSignal.timeout(publicDirectoryTimeoutMs),
      });
      if (!response.ok) throw new Error(`${response.status}`);
      const data = await response.json() as { elements?: OsmElement[] };
      if (!data.elements?.length) throw new Error('empty response');
      return data;
    });
    try {
      const deadline = new Promise<never>((_, reject) => setTimeout(() => reject(new Error('directory deadline exceeded')), publicDirectoryDeadlineMs));
      return await Promise.race([Promise.any(attempts), deadline]);
    } catch {
      if (pass === 0) await new Promise(resolve => setTimeout(resolve, 350));
    }
  }
  throw new Error('The public directory is temporarily unavailable after trying every fallback. Please try again shortly.');
}

/** Free discovery source: public business listings, with email accepted only when published by the business or its website. */
export async function POST(request: NextRequest) {
  const body = await request.json().catch(() => ({})) as {
    limit?: number;
    companyId?: string;
    excludeEmails?: string[];
    excludeWebsites?: string[];
    excludeNames?: string[];
  };
  const config = getOutreachWorkflow(body.companyId || '');
  const digitalDiscovery = config?.companyId === 'bryant-digital';
  if (!config || (!digitalDiscovery && (config.websiteAuditEnabled || config.workflowType !== 'dorset-prospecting'))) {
    return NextResponse.json({ error: 'This company does not have a Dorset prospecting workflow.' }, { status: 400 });
  }
  const limit = Math.max(1, Math.min(Number(body.limit) || 10, 10));
  const excludedEmails = new Set((body.excludeEmails ?? []).map(normaliseLeadEmail).filter(Boolean).slice(0, 1000));
  const excludedWebsites = new Set((body.excludeWebsites ?? []).map(normaliseLeadWebsite).filter(Boolean).slice(0, 1000));
  const excludedNames = new Set((body.excludeNames ?? []).map(normaliseLeadName).filter(Boolean).slice(0, 1000));

  try {
    const data = await fetchPublicDirectory(publicDirectoryQuery(config, digitalDiscovery));
    const seenCandidates: Array<{ name: string; email: string; website: string }> = [];
    const allCandidates = (data.elements ?? []).flatMap(element => {
      const tags = element.tags ?? {};
      const listedEmail = (tags.email || tags['contact:email'] || '').toLowerCase().trim();
      const email = isPublicBusinessEmail(listedEmail) ? listedEmail : '';
      const name = clean(tags.name || '');
      const rawWebsite = tags.website || tags['contact:website'] || '';
      const website = rawWebsite ? normaliseWebsite(rawWebsite) : '';
      const websiteKey = normaliseLeadWebsite(website);
      const nameIdentity = normaliseLeadName(name);
      const identity = { name, email, website };
      const excluded = (email && excludedEmails.has(normaliseLeadEmail(email))) || (websiteKey && excludedWebsites.has(websiteKey)) || excludedNames.has(nameIdentity);
      if (!name || excluded || isKnownLead(identity, seenCandidates)) return [];
      if (!digitalDiscovery && !matchesWorkflow(tags, config)) return [];
      seenCandidates.push(identity);
      const lat = element.lat ?? element.center?.lat; const lon = element.lon ?? element.center?.lon;
      const phone = tags.phone || tags['contact:phone'] || '';
      return [{
        name,
        email,
        website,
        phone,
        location: location(tags),
        industry: industry(tags),
        tags,
        contactUrl: website,
        googleMapsUrl: lat && lon ? `https://www.google.com/maps/search/?api=1&query=${lat},${lon}` : `https://www.google.com/maps/search/?api=1&query=${encodeURIComponent(`${name} Dorset`)}`,
        score: relevanceScore(tags, config, website, email, phone),
      }];
    });
    allCandidates.sort((a, b) => b.score - a.score || a.name.localeCompare(b.name));
    const selectionLimit = digitalDiscovery ? Math.min(48, limit * 5) : Math.min(36, limit * 4);
    const candidates = allCandidates.slice(0, selectionLimit).map(({ tags: _tags, score: _score, ...candidate }) => candidate);

    const auditedCandidates = digitalDiscovery ? candidates : (await Promise.all(candidates.map(async candidate => {
      if (candidate.email) return candidate;
      if (!candidate.website) return null;
      try {
        const audited = await auditPublicWebsite(candidate.website);
        const email = audited.contactEmail?.toLowerCase().trim() ?? '';
        if (!isPublicBusinessEmail(email) || excludedEmails.has(email)) return null;
        return {
          ...candidate,
          email,
          website: audited.website || candidate.website,
          phone: candidate.phone || audited.phoneNumber || '',
          contactUrl: audited.contactPageUrl || audited.website || candidate.website,
        };
      } catch {
        return null;
      }
    }))).filter((candidate): candidate is NonNullable<typeof candidate> => Boolean(candidate));

    const uniqueRecords: Array<{ email: string; website: string; name: string }> = [];
    const finalCandidates = auditedCandidates.filter(candidate => {
      const website = normaliseLeadWebsite(candidate.website);
      const email = normaliseLeadEmail(candidate.email);
      const name = normaliseLeadName(candidate.name);
      const identity = { website, email, name };
      if ((!website && !email && !name) || isKnownLead(identity, uniqueRecords)) return false;
      uniqueRecords.push(identity);
      return true;
    }).slice(0, digitalDiscovery ? selectionLimit : limit);

    const prospects = digitalDiscovery
      ? finalCandidates
      : await Promise.all(finalCandidates.map(async candidate => ({
          ...candidate,
          proposal: proposalFor(config.companyId, candidate.name, candidate.industry, candidate.location, { companyName: config.companyName }),
        })));

    return NextResponse.json({
      prospects,
      source: config.leadSource,
      companyId: config.companyId,
      limit,
      candidateLimit: digitalDiscovery ? selectionLimit : limit,
      exhausted: prospects.length === 0,
    });
  } catch (error) {
    return NextResponse.json({ error: error instanceof Error ? error.message : 'Public directory search failed.' }, { status: 502 });
  }
}
