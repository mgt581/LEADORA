import { NextRequest, NextResponse } from 'next/server';
import { getCloudflareContext } from '@opennextjs/cloudflare';

export const runtime = 'nodejs';

type OsmElement = { id: number; type: string; lat?: number; lon?: number; center?: { lat: number; lon: number }; tags?: Record<string, string> };
type AiBinding = { run: (model: string, input: Record<string, unknown>) => Promise<{ response?: string }> };

const clean = (value: string) => value.replace(/\s+/g, ' ').trim();
const emailPattern = /^[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,}$/i;

function location(tags: Record<string, string>) {
  return [tags['addr:housenumber'], tags['addr:street'], tags['addr:city'] || tags['addr:town'] || tags['addr:village'], tags['addr:postcode']].filter(Boolean).join(', ') || 'Dorset';
}
function industry(tags: Record<string, string>) {
  return tags.office || tags.amenity || tags.tourism || tags.shop || 'Local business';
}
function fallbackProposal(name: string, businessType: string, place: string) {
  return {
    subject: `A reliable cleaning option for ${name}`,
    body: `Hello,\n\nI came across ${name}, a ${businessType} in ${place}, through its public business listing.\n\nBryant & Co Cleaning provides dependable commercial cleaning for local businesses. If keeping your premises consistently clean is something you are reviewing, we would be happy to discuss a flexible cleaning plan around your hours and requirements.\n\nThere is no obligation — would a short call next week be useful?\n\nAlex Bryant\nBryant & Co Cleaning`,
    callToAction: 'Would a short call next week be useful?',
  };
}
async function proposal(name: string, businessType: string, place: string) {
  const fallback = fallbackProposal(name, businessType, place);
  try {
    const env = getCloudflareContext().env as unknown as { AI?: AiBinding };
    if (!env.AI) return fallback;
    const prompt = `Write a concise UK commercial-cleaning outreach email in JSON only with keys subject, body, callToAction. Use only these facts: business name=${name}; public category=${businessType}; location=${place}. Sender is Bryant & Co Cleaning. Do not claim to have visited, audited, or know any needs of the business. Helpful, professional, no pressure, 120 words maximum.`;
    const result = await env.AI.run('@cf/meta/llama-3.2-1b-instruct', { prompt, max_tokens: 360, temperature: 0.35 });
    const raw = result.response?.match(/\{[\s\S]*\}/)?.[0];
    if (!raw) return fallback;
    const parsed = JSON.parse(raw) as Partial<typeof fallback>;
    if (!parsed.subject || !parsed.body || !parsed.callToAction) return fallback;
    return { subject: clean(parsed.subject).slice(0, 140), body: clean(parsed.body).replace(/\\n/g, '\n'), callToAction: clean(parsed.callToAction).slice(0, 180) };
  } catch { return fallback; }
}

/** Free discovery source: OpenStreetMap records and only the email that its contributor/business has published. */
export async function POST(request: NextRequest) {
  const body = await request.json().catch(() => ({})) as { limit?: number };
  const limit = Math.max(1, Math.min(Number(body.limit) || 10, 10));
  const query = `[out:json][timeout:25];area["name"="Dorset"]["boundary"="administrative"]->.area;(nwr["email"](area.area);nwr["contact:email"](area.area););out center tags 100;`;
  try {
    const response = await fetch('https://overpass-api.de/api/interpreter', { method: 'POST', headers: { 'content-type': 'application/x-www-form-urlencoded', 'user-agent': 'LEADORA/1.0 public-contact discovery' }, body: new URLSearchParams({ data: query }), signal: AbortSignal.timeout(30_000) });
    if (!response.ok) throw new Error(`The public directory is temporarily unavailable (${response.status}).`);
    const data = await response.json() as { elements?: OsmElement[] };
    const seen = new Set<string>();
    const candidates = (data.elements ?? []).flatMap(element => {
      const tags = element.tags ?? {}; const email = (tags.email || tags['contact:email'] || '').toLowerCase(); const name = tags.name;
      if (!name || !emailPattern.test(email) || seen.has(email)) return [];
      seen.add(email);
      const lat = element.lat ?? element.center?.lat; const lon = element.lon ?? element.center?.lon;
      return [{ name: clean(name), email, website: tags.website || tags['contact:website'] || '', phone: tags.phone || tags['contact:phone'] || '', location: location(tags), industry: industry(tags), contactUrl: tags.website || tags['contact:website'] || '', googleMapsUrl: lat && lon ? `https://www.google.com/maps/search/?api=1&query=${lat},${lon}` : `https://www.google.com/maps/search/?api=1&query=${encodeURIComponent(`${name} Dorset`)}` }];
    }).slice(0, limit);
    const prospects = await Promise.all(candidates.map(async candidate => ({ ...candidate, proposal: await proposal(candidate.name, candidate.industry, candidate.location) })));
    return NextResponse.json({ prospects, source: 'OpenStreetMap public business listings', limit });
  } catch (error) { return NextResponse.json({ error: error instanceof Error ? error.message : 'Public directory search failed.' }, { status: 502 }); }
}
