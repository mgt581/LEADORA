import { NextRequest, NextResponse } from 'next/server';
import { getCloudflareContext } from '@opennextjs/cloudflare';
import { getOutreachWorkflow, type OutreachWorkflowConfig, CLIENT_CONTACT_PHONE } from '@/lib/outreach-workflows';

export const runtime = 'nodejs';

type OsmElement = { id: number; type: string; lat?: number; lon?: number; center?: { lat: number; lon: number }; tags?: Record<string, string> };
type AiBinding = { run: (model: string, input: Record<string, unknown>) => Promise<{ response?: string }> };

const clean = (value: string) => value.replace(/\s+/g, ' ').trim();
const emailPattern = /^[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,}$/i;
const publicDirectoryMirrors = [
  'https://overpass-api.de/api/interpreter',
  'https://overpass.private.coffee/api/interpreter',
  'https://overpass.kumi.systems/api/interpreter',
  'https://maps.mail.ru/osm/tools/overpass/api/interpreter',
];

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
  const fallback = fallbackProposal(config, name, businessType, place);
  try {
    const env = getCloudflareContext().env as unknown as { AI?: AiBinding };
    if (!env.AI) return fallback;
    const prompt = `Write a concise UK outreach email in JSON only with keys subject, body, callToAction. Use only these facts: business name=${name}; public category=${businessType}; location=${place}. Sender is ${config.companyName}. Use the ${config.proposalTemplate} proposal template for ${config.recommendedService}. Do not claim to have visited, audited, or know any needs of the business. Helpful, professional, no pressure, 120 words maximum.`;
    const result = await env.AI.run('@cf/meta/llama-3.2-1b-instruct', { prompt, max_tokens: 360, temperature: 0.35 });
    const raw = result.response?.match(/\{[\s\S]*\}/)?.[0];
    if (!raw) return fallback;
    const parsed = JSON.parse(raw) as Partial<typeof fallback>;
    if (!parsed.subject || !parsed.body || !parsed.callToAction) return fallback;
    const body = clean(parsed.body).replace(/\\n/g, '\n');
    return { subject: clean(parsed.subject).slice(0, 140), body: body.includes(CLIENT_CONTACT_PHONE) ? body : `${body}\n\nAlex Bryant\n${config.companyName}\n${CLIENT_CONTACT_PHONE}`, callToAction: clean(parsed.callToAction).slice(0, 180) };
  } catch { return fallback; }
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
  const query = digitalDiscovery
    ? `[out:json][timeout:25];area["name"="Dorset"]["boundary"="administrative"]->.area;(nwr["website"](area.area);nwr["contact:website"](area.area););out center tags 250;`
    : `[out:json][timeout:25];area["name"="Dorset"]["boundary"="administrative"]->.area;(nwr["email"](area.area);nwr["contact:email"](area.area););out center tags 100;`;
  try {
    let data: { elements?: OsmElement[] } | null = null;
    let lastStatus = 0;
    for (const endpoint of publicDirectoryMirrors) {
      try {
        const response = await fetch(endpoint, { method: 'POST', headers: { 'content-type': 'application/x-www-form-urlencoded', 'user-agent': 'LEADORA/1.0 public-contact discovery' }, body: new URLSearchParams({ data: query }), signal: AbortSignal.timeout(30_000) });
        lastStatus = response.status;
        if (response.ok) { data = await response.json() as { elements?: OsmElement[] }; break; }
      } catch { /* Try the next free public mirror. */ }
    }
    if (!data) throw new Error(`The public directory is temporarily unavailable (${lastStatus || 'network error'}). Please try again shortly.`);
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
    const relevant = digitalDiscovery ? allCandidates : allCandidates.filter(candidate => matchesWorkflow(candidate.tags, config));
    // OpenStreetMap tagging is incomplete for property and beauty businesses. A
    // transparent public-contact fallback is preferable to returning no leads.
    const selectionLimit = digitalDiscovery ? Math.min(40, limit * 4) : limit;
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
