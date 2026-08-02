import { getCloudflareContext } from '@opennextjs/cloudflare';
import { accessToken, type TokenSet } from '@/lib/server/gmail';

export const GOOGLE_INTEGRATION_SCOPES = [
  'openid',
  'email',
  'https://www.googleapis.com/auth/analytics.readonly',
].join(' ');

export const GOOGLE_INTEGRATION_STATE_COOKIE = 'leadrally-google-oauth-state';
export const GOOGLE_COMPANY_IDS = new Set([
  'bryant-construction',
  'bryant-cleaning',
  'bryant-digital',
  'mr-white-teeth',
]);

type RuntimeEnv = Record<string, string | undefined>;
function runtimeEnv(): RuntimeEnv {
  try {
    return getCloudflareContext().env as RuntimeEnv;
  } catch {
    return process.env;
  }
}

function env(name: string) { return runtimeEnv()[name]; }

export function validGoogleCompanyId(value: string | null | undefined): value is string {
  return Boolean(value && GOOGLE_COMPANY_IDS.has(value));
}

export function googleCompanyCookie(companyId: string) {
  return `leadrally-google-${companyId}`;
}

export function googleIntegrationRedirectUrl(requestUrl: string) {
  return env('GOOGLE_INTEGRATIONS_REDIRECT_URL') || new URL('/api/google/callback', requestUrl).toString();
}

export function createGoogleIntegrationState(companyId: string) {
  return Buffer.from(JSON.stringify({ companyId, nonce: crypto.randomUUID() }), 'utf8').toString('base64url');
}

export function companyIdFromState(state: string) {
  try {
    const parsed = JSON.parse(Buffer.from(state, 'base64url').toString('utf8')) as { companyId?: string };
    return validGoogleCompanyId(parsed.companyId) ? parsed.companyId : null;
  } catch {
    return null;
  }
}

export function googleIntegrationAuthorizationUrl(state: string, redirectUri: string) {
  const clientId = env('GOOGLE_OAUTH_CLIENT_ID');
  const clientSecret = env('GOOGLE_OAUTH_CLIENT_SECRET');
  if (!clientId || !clientSecret) throw new Error('Google OAuth is not configured.');
  const params = new URLSearchParams({
    client_id: clientId,
    redirect_uri: redirectUri,
    response_type: 'code',
    access_type: 'offline',
    prompt: 'consent select_account',
    include_granted_scopes: 'true',
    scope: GOOGLE_INTEGRATION_SCOPES,
    state,
  });
  return `https://accounts.google.com/o/oauth2/v2/auth?${params}`;
}

export async function exchangeGoogleIntegrationCode(code: string, redirectUri: string): Promise<TokenSet> {
  const clientId = env('GOOGLE_OAUTH_CLIENT_ID');
  const clientSecret = env('GOOGLE_OAUTH_CLIENT_SECRET');
  if (!clientId || !clientSecret) throw new Error('Google OAuth is not configured.');
  const response = await fetch('https://oauth2.googleapis.com/token', {
    method: 'POST',
    headers: { 'content-type': 'application/x-www-form-urlencoded' },
    body: new URLSearchParams({
      code,
      client_id: clientId,
      client_secret: clientSecret,
      redirect_uri: redirectUri,
      grant_type: 'authorization_code',
    }),
  });
  if (!response.ok) throw new Error(`Google authorization failed (${response.status}).`);
  const tokens = await response.json() as TokenSet;
  return { ...tokens, expiry_date: Date.now() + (tokens.expires_in ?? 3600) * 1000 };
}

export async function googleAccessToken(tokens: TokenSet) {
  return accessToken(tokens);
}

export async function googleAccountEmail(accessTokenValue: string) {
  const response = await fetch('https://openidconnect.googleapis.com/v1/userinfo', {
    headers: { authorization: `Bearer ${accessTokenValue}` },
  });
  if (!response.ok) return '';
  return ((await response.json()) as { email?: string }).email ?? '';
}

export type AnalyticsProperty = { id: string; name: string; accountName: string };
export async function listAnalyticsProperties(accessTokenValue: string): Promise<AnalyticsProperty[]> {
  const response = await fetch('https://analyticsadmin.googleapis.com/v1beta/accountSummaries?pageSize=200', {
    headers: { authorization: `Bearer ${accessTokenValue}` },
  });
  if (!response.ok) throw new Error(response.status === 403
    ? 'Google Analytics Admin API is not enabled or this account has no Analytics access.'
    : `Google Analytics property lookup failed (${response.status}).`);
  const data = await response.json() as {
    accountSummaries?: Array<{ displayName?: string; propertySummaries?: Array<{ property?: string; displayName?: string }> }>;
  };
  return (data.accountSummaries ?? []).flatMap(account => (account.propertySummaries ?? []).map(property => ({
    id: (property.property ?? '').replace('properties/', ''),
    name: property.displayName || property.property || 'Google Analytics property',
    accountName: account.displayName || 'Google Analytics',
  }))).filter(property => /^\d+$/.test(property.id));
}
