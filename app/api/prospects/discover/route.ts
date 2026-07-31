import { NextRequest, NextResponse } from 'next/server';
import { getOutreachWorkflow, type OutreachWorkflowConfig, CLIENT_CONTACT_PHONE } from '@/lib/outreach-workflows';
import { decodeHtmlEntities } from '@/lib/text';
import { isPublicBusinessEmail } from '@/lib/leads/public-email';

export const runtime = 'nodejs';

type OsmElement = { id: number; type: string; lat?: number; lon?: number; center?: { lat: number; lon: number }; tags?: Record<string, string> };

const clean = (value: string) => decodeHtmlEntities(value).replace(/\s+/g, ' ').trim();
const publicDirectoryMirrors = [
  // Britain-and-Ireland regional instance: smaller dataset and consistently
  // faster for Dorset than the global public mirrors.
  'https://overpass.atownsend.org.uk/api/interpreter',
  'https://overpass-api.de/api/interpreter',
  'https://overpass.private.coffee/api/interpreter',
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
  const searchable = Object.entries(tags).flat().join(' ').toLowerCase();
  return config.prospectCategories.some(category => searchable.includes(category));
}

function publicDirectoryQuery(config: OutreachWorkflowConfig, digitalDiscovery: boolean) {
  const selectors = digitalDiscovery ? ['']
    : config.companyId === 'bryant-construction' ? [
        '["office"~"estate_agent|property_management|architect|surveying"]',
        '["craft"~"builder|carpenter|roofer|plumber|electrician"]',
        '["shop"="estate_agent"]',
      ]
    : config.companyId === 'mr-white-teeth' ? [
        '["shop"~"beauty|hairdresser|cosmetics|wedding"]',
        '["beauty"]',
      ]
    : [''];
  const statements = selectors.flatMap(filter => [
    `nwr["email"]["name"]${filter}(${dorsetBounds});`,
    `nwr["contact:email"]["name"]${filter}(${dorsetBounds});`,
  ]).join('');
  return `[out:json][timeout:12];(${statements});out center tags 600;`;
}

function fallbackProposal(config: OutreachWorkflowConfig, name: string, businessType: string, place: string) {
  if (config.proposalTemplate === 'cleaning') return {
    subject: `A cleaner, easier option for ${name}`,
    body: `Hi there,\n\nI came across ${name} in ${place} and thought this might be useful.\n\nBryant & Co Cleaning provides reliable commercial cleaning with a tailored plan built around your opening hours and requirements.\n\nI can put together a free, no-obligation quote, with replies normally within one hour during business hours.\n\nWould you like me to price up an option?\n\nhttps://www.bryantandcocleaning.co.uk\n\nAlex Bryant\nBryant & Co Cleaning\n${CLIENT_CONTACT_PHONE}`,
    callToAction: 'Would you like me to price up an option?',
  };
  const templates = {
    construction: {
      subject: `A clear quote for upcoming work at ${name}`,
      body: `Hi there,\n\nI came across ${name} in ${place} and thought this might be useful.\n\nBryant Construction Group handles repairs, maintenance and refurbishment across Bournemouth, Poole and Christchurch.\n\nWe can provide a free, clear quote before work starts, with no hidden extras.\n\nDo you have any upcoming property work we could quote for?\n\nhttps://bryantconstructiongroup.co.uk\n\nAlex Bryant\nBryant Construction Group\n${CLIENT_CONTACT_PHONE}`,
      question: 'Do you have any upcoming property work we could quote for?',
    },
    partnership: {
      subject: `A local partnership idea for ${name}`,
      body: `Hi there,\n\nI came across ${name} in ${place} and thought there could be a good local partnership fit.\n\nMr White provides professional, pain-free teeth whitening in Bournemouth from £69. I would love to explore a simple referral or cross-promotion partnership that could benefit both of our clients.\n\nWould you be open to a quick, no-obligation chat?\n\nhttps://teethwhiteningbournemouth.co.uk\n\nAlex Bryant\nMr White Teeth Whitening\n${CLIENT_CONTACT_PHONE}`,
      question: 'Would you be open to a quick, no-obligation chat?',
    },
  } as const;
  const template = templates[config.proposalTemplate as keyof typeof templates];
  return {
    subject: template.subject,
    body: template.body,
    callToAction: template.question,
  };
}
async function proposal(config: OutreachWorkflowConfig, name: string, businessType: string, place: string) {
  // Deterministic proposals keep discovery fast and prevent a text model from
  // inventing claims, attachments, links or contact details.
  return fallbackProposal(config, name, businessType, place);
}

async function fetchPublicDirectory(query: string) {
  for (let pass = 0; pass < 2; pass += 1) {
    const attempts = publicDirectoryMirrors.map(async endpoint => {
      const response = await fetch(endpoint, {
        method: 'POST',
        headers: {
          'content-type': 'application/x-www-form-urlencoded',
          'user-agent': 'LEADORA/1.0 public-contact discovery',
        },
        body: new URLSearchParams({ data: query }),
        signal: AbortSignal.timeout(12_000),
      });
      if (!response.ok) throw new Error(`${response.status}`);
      const data = await response.json() as { elements?: OsmElement[] };
      if (!data.elements?.length) throw new Error('empty response');
      return data;
    });
    try {
      const deadline = new Promise<never>((_, reject) => {
        setTimeout(() => reject(new Error('directory deadline exceeded')), 13_000);
      });
      return await Promise.race([Promise.any(attempts), deadline]);
    } catch {
      if (pass === 0) await new Promise(resolve => setTimeout(resolve, 350));
    }
  }
  throw new Error('The public directory is temporarily unavailable after trying every fallback. Please try again shortly.');
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
  const query = publicDirectoryQuery(config, digitalDiscovery);
  try {
    const data = await fetchPublicDirectory(query);
    const seen = new Set<string>();
    const allCandidates = (data.elements ?? []).flatMap(element => {
      const tags = element.tags ?? {}; const listedEmail = (tags.email || tags['contact:email'] || '').toLowerCase(); const email = isPublicBusinessEmail(listedEmail) ? listedEmail : ''; const name = tags.name;
      const rawWebsite = tags.website || tags['contact:website'] || '';
      const website = rawWebsite ? normaliseWebsite(rawWebsite) : '';
      const identity = digitalDiscovery ? website.toLowerCase() : email;
      if (!name || (!digitalDiscovery && !email) || !identity || seen.has(identity) || (email && excludedEmails.has(email)) || (website && excludedWebsites.has(website.toLowerCase()))) return [];
      seen.add(identity);
      const lat = element.lat ?? element.center?.lat; const lon = element.lon ?? element.center?.lon;
      return [{ name: clean(name), email, website, phone: tags.phone || tags['contact:phone'] || '', location: location(tags), industry: industry(tags), tags, contactUrl: website, googleMapsUrl: lat && lon ? `https://www.google.com/maps/search/?api=1&query=${lat},${lon}` : `https://www.google.com/maps/search/?api=1&query=${encodeURIComponent(`${name} Dorset`)}` }];
    });
    if (digitalDiscovery) allCandidates.sort((a, b) => Number(Boolean(b.email)) - Number(Boolean(a.email)));
    const relevant = digitalDiscovery ? allCandidates : allCandidates.filter(candidate => matchesWorkflow(candidate.tags, config));
    const selectionLimit = digitalDiscovery ? Math.min(20, limit * 2) : limit;
    const selected = relevant.slice(0, selectionLimit);
    const candidates = selected.map(({ tags: _tags, ...candidate }) => candidate);
    const prospects = digitalDiscovery ? candidates : await Promise.all(candidates.map(async candidate => ({ ...candidate, proposal: await proposal(config, candidate.name, candidate.industry, candidate.location) })));
    return NextResponse.json({
      prospects,
      source: config.leadSource,
      companyId: config.companyId,
      limit,
      categoryFallbackUsed: false,
      exhausted: prospects.length === 0,
    });
  } catch (error) { return NextResponse.json({ error: error instanceof Error ? error.message : 'Public directory search failed.' }, { status: 502 }); }
}
