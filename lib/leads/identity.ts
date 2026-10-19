/** Stable identity keys used to avoid adding the same public business twice. */
export function normaliseLeadEmail(value: string) {
  return value.trim().toLowerCase();
}

export function normaliseLeadWebsite(value: string) {
  const input = value.trim();
  if (!input) return '';
  try {
    const url = new URL(/^https?:\/\//i.test(input) ? input : `https://${input}`);
    return url.hostname.toLowerCase().replace(/^www\./, '').replace(/\.$/, '');
  } catch {
    return input.toLowerCase().replace(/^https?:\/\//, '').replace(/^www\./, '').split(/[/?#]/, 1)[0].replace(/\.$/, '');
  }
}

export function normaliseLeadName(value: string) {
  return value.normalize('NFKC').toLowerCase().replace(/&/g, ' and ').replace(/[^\p{L}\p{N}]+/gu, ' ').trim().replace(/\s+/g, ' ');
}

export function leadIdentityKeys(lead: { email?: string; website?: string; name?: string }) {
  return [
    lead.email ? `email:${normaliseLeadEmail(lead.email)}` : '',
    lead.website ? `website:${normaliseLeadWebsite(lead.website)}` : '',
    lead.name ? `name:${normaliseLeadName(lead.name)}` : '',
  ].filter(Boolean);
}

export function isKnownLead(candidate: { email?: string; website?: string; name?: string }, known: Array<{ email?: string; website?: string; name?: string }>) {
  const keys = new Set(leadIdentityKeys(candidate));
  return known.some(item => leadIdentityKeys(item).some(key => keys.has(key)));
}
