import { NextRequest, NextResponse } from 'next/server';
import { getOutreachWorkflow, type OutreachWorkflowConfig, CLIENT_CONTACT_PHONE } from '@/lib/outreach-workflows';
import { decodeHtmlEntities } from '@/lib/text';

export const runtime = 'nodejs';

type OsmElement = { id: number; type: string; lat?: number; lon?: number; center?: { lat: number; lon: number }; tags?: Record<string, string> };

const clean = (value: string) => decodeHtmlEntities(value).replace(/\s+/g, ' ').trim();
const emailPattern = /^[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,}$/i;
const publicDirectoryMirrors = [
  'https://overpass-api.de/api/interpreter',
  'https://overpass.private.coffee/api/interpreter',
  'https://overpass.kumi.systems/api/interpreter',
  'https://maps.mail.ru/osm/tools/overpass/api/interpreter',
];
const dorsetBounds = '50.50,-2.95,51.10,-1.70';

function normaliseWebsite(value: string) {
  const trimmed = value.trim();
  return /^https?:\/\//i.test(trimmed) ? trimmed : `https://${trimmed}`;
}

function location(tags: Record<string, string>) {
  return [tags['addr:housenumber'], tags['addr:street'], tags['addr:city'] || tags['addr:town'] || tags['addr:village'], tags['addr:postcode']].filter(Boolean).join(', ') || 'Dorset';
}
function industry(tags: Record<string, string>) {
  return tags.office || tags.amenity || tags.tourism || tags.shop || 'Local business';
}
function matchesWorkflow(tags: Record<string, string>, config: OutreachWorkflowConfig) {
  const searchable = Object.values(tags).join(' ').toLowerCase();
  return config.prospectCategories.some(category => searchable.includes(category));
}

function fallbackProposal(config: OutreachWorkflowConfig, name: string, businessType: string, place: string) {
  const templates = {
    cleaning: {
      subject: `A reliable cleaning option for ${name}`,
      service: 'dependable commercial cleaning with flexible plans built around a business’s hours and requirements',
      question: 'Would a short call next week be useful?',
    },
    construction: {
      subject: `Construction support for ${name}`,
      service: 'construction, renovation and refurbishment support for Dorset property businesses and commercial premises',
      question: 'Would a brief conversation about upcoming property work be useful?',
    },
    partnership: {
      subject: `A local partnership idea for ${name}`,
      service: 'professional teeth-whitening partnership opportunities for local beauty, hair and wedding businesses',
      question: 'Would you be open to a short conversation about a partnership?',
    },
  } as const;
  const template = templates[config.proposalTemplate as keyof typeof templates];
  return {
    subject: template.subject,
    body: `Hello,\n\nI came across ${name}, a ${businessType} in ${place}, through its public business listing.\n\n${config.companyName} provides ${template.service}. I thought there may be a relevant opportunity to work together.\n\nThere is no obligation — ${template.question}\n\nAlex Bryant\n${config.companyName}\n${CLIENT_CONTACT_PHONE}`,
    callToAction: template.question,
  };
}
async function proposal(config: OutreachWorkflowConfig, name: string, businessType: string, place: string) {
  // Deterministic proposals keep discovery fast and prevent a text model from
  // inventing claims, attachments, links or contact details.
  return fallbackProposal(config, name, businessType, place);
}

async function fetchPublicDirectory(query: string) {
  const attempts = publicDirectoryMirrors.map(async endpoint => {
    const response = await fetch(endpoint, {
      method: 'POST',
      headers: {
        'content-type': 'application/x-www-form-urlencoded',
        'user-agent': 'LEADORA/1.0 public-contact discovery',
      },
      body: new URLSearchParams({ data: query }),
      signal: AbortSignal.timeout(15_000),
    });
    if (!response.ok) throw new Error(`${response.status}`);
    const data = await response.json() as { elements?: OsmElement[] };
    if (!data.elements?.length) throw new Error('empty response');
    return data;
  });
  try {
    const deadline = new Promise<never>((_, reject) => {
      setTimeout(() => reject(new Error('directory deadline exceeded')), 16_000);
    });
    return await Promise.race([Promise.any(attempts), deadline]);
  } catch {
    throw new Error('The public directory is temporarily unavailable. Please try again shortly.');
  }
}

/** Free discovery source: OpenStreetMap records and only the email that its contributor/business has published. */
export async function POST(request: NextRequest) {
  const body = await request.json().catch(() => ({})) as {
    limit?: number;
    companyId?: string;
    excludeEmails?: string[];
    excludeWebsites?: string[];
  };
  const config = getOutreachWorkflow(body.companyId || '');
  const digitalDiscovery = config?.companyId === 'bryant-digital';
  if (!config || (!digitalDiscovery && (config.websiteAuditEnabled || config.workflowType !== 'dorset-prospecting'))) return NextResponse.json({ error: 'This company does not have a Dorset prospecting workflow.' }, { status: 400 });
  const limit = Math.max(1, Math.min(Number(body.limit) || 10, 10));
  const excludedEmails = new Set((body.excludeEmails ?? []).map(value => value.toLowerCase()).slice(0, 500));
  const excludedWebsites = new Set((body.excludeWebsites ?? []).map(value => value.toLowerCase()).slice(0, 500));
  // Start with published email records for every workflow. Digital discovery
  // then keeps only records that also publish a website and audits those sites.
  // This is far faster and more useful than enumerating every Dorset website.
  const query = `[out:json][timeout:12];(nwr["email"]["name"](${dorsetBounds});nwr["contact:email"]["name"](${dorsetBounds}););out center tags 600;`;
  try {
    const data = await fetchPublicDirectory(query);
    const seen = new Set<string>();
    const allCandidates = (data.elements ?? []).flatMap(element => {
      const tags = element.tags ?? {}; const email = (tags.email || tags['contact:email'] || '').toLowerCase(); const name = tags.name;
      const rawWebsite = tags.website || tags['contact:website'] || '';
      const website = rawWebsite ? normaliseWebsite(rawWebsite) : '';
      const identity = digitalDiscovery ? website.toLowerCase() : email;
      if (!name || (!digitalDiscovery && !emailPattern.test(email)) || !identity || seen.has(identity) || (email && excludedEmails.has(email)) || (website && excludedWebsites.has(website.toLowerCase()))) return [];
      seen.add(identity);
      const lat = element.lat ?? element.center?.lat; const lon = element.lon ?? element.center?.lon;
      return [{ name: clean(name), email, website, phone: tags.phone || tags['contact:phone'] || '', location: location(tags), industry: industry(tags), tags, contactUrl: website, googleMapsUrl: lat && lon ? `https://www.google.com/maps/search/?api=1&query=${lat},${lon}` : `https://www.google.com/maps/search/?api=1&query=${encodeURIComponent(`${name} Dorset`)}` }];
    });
    if (digitalDiscovery) allCandidates.sort((a, b) => Number(Boolean(b.email)) - Number(Boolean(a.email)));
    const relevant = digitalDiscovery ? allCandidates : allCandidates.filter(candidate => matchesWorkflow(candidate.tags, config));
    // OpenStreetMap tagging is incomplete for property and beauty businesses. A
    // transparent public-contact fallback is preferable to returning no leads.
    const selectionLimit = digitalDiscovery ? Math.min(20, limit * 2) : limit;
    const selected = (relevant.length ? relevant : allCandidates).slice(0, selectionLimit);
    const candidates = selected.map(({ tags: _tags, ...candidate }) => candidate);
    const prospects = digitalDiscovery ? candidates : await Promise.all(candidates.map(async candidate => ({ ...candidate, proposal: await proposal(config, candidate.name, candidate.industry, candidate.location) })));
    return NextResponse.json({
      prospects,
      source: config.leadSource,
      companyId: config.companyId,
      limit,
      categoryFallbackUsed: !digitalDiscovery && relevant.length === 0,
      exhausted: prospects.length === 0,
    });
  } catch (error) { return NextResponse.json({ error: error instanceof Error ? error.message : 'Public directory search failed.' }, { status: 502 }); }
}
