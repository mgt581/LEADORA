import { createCipheriv, createDecipheriv, createHash, randomBytes, timingSafeEqual } from 'node:crypto';
import { getCloudflareContext } from '@opennextjs/cloudflare';

export const GMAIL_SCOPES = [
  'https://www.googleapis.com/auth/gmail.send',
  'https://www.googleapis.com/auth/gmail.readonly',
].join(' ');

const TOKEN_COOKIE = 'leadora-gmail-token';
const STATE_COOKIE = 'leadora-gmail-oauth-state';

type TokenSet = { access_token: string; refresh_token?: string; expiry_date?: number; token_type?: string };
export type GmailErrorCode =
  | 'GOOGLE_OAUTH_NOT_CONFIGURED'
  | 'MISSING_CLIENT_ID'
  | 'MISSING_CLIENT_SECRET'
  | 'MISSING_ENCRYPTION_KEY'
  | 'MISSING_REDIRECT_URI'
  | 'MISSING_CLOUDFLARE_ENV'
  | 'USER_NOT_AUTHENTICATED'
  | 'OAUTH_TOKEN_MISSING'
  | 'OAUTH_TOKEN_EXPIRED'
  | 'GMAIL_API_UNAVAILABLE'
  | 'INVALID_AUTHORIZATION'
  | 'REDIRECT_URI_MISMATCH';
export class GmailIntegrationError extends Error {
  constructor(public readonly code: GmailErrorCode, message: string) {
    super(message);
    this.name = 'GmailIntegrationError';
  }
}
export const GMAIL_REQUIRED_ENV_VARS = [
  'GOOGLE_OAUTH_CLIENT_ID',
  'GOOGLE_OAUTH_CLIENT_SECRET',
  'GOOGLE_OAUTH_REDIRECT_URL',
  'GMAIL_TOKEN_ENCRYPTION_KEY',
  'NEXT_PUBLIC_APP_URL',
  'CLOUDFLARE_ACCOUNT_ID',
  'CLOUDFLARE_API_TOKEN',
  'CLOUDFLARE_D1_DATABASE_ID',
] as const;
type RuntimeEnv = Record<string, string | undefined>;
function getRuntimeEnv(): RuntimeEnv {
  try {
    return getCloudflareContext().env as RuntimeEnv;
  } catch {
    return process.env;
  }
}
function env(name: string) {
  return getRuntimeEnv()[name];
}
const friendlyMessages: Record<GmailErrorCode, string> = {
  GOOGLE_OAUTH_NOT_CONFIGURED: 'Google OAuth is not configured. Add the Google OAuth environment variables to the deployment.',
  MISSING_CLIENT_ID: 'Google OAuth Client ID is missing.',
  MISSING_CLIENT_SECRET: 'Google OAuth Client Secret is missing.',
  MISSING_ENCRYPTION_KEY: 'The Gmail token encryption key is missing.',
  MISSING_REDIRECT_URI: 'The Google OAuth redirect URI is missing.',
  MISSING_CLOUDFLARE_ENV: 'Cloudflare environment variables are missing. Configure the account, API token and D1 database ID.',
  USER_NOT_AUTHENTICATED: 'Sign in to LEADORA before connecting Gmail.',
  OAUTH_TOKEN_MISSING: 'No Gmail OAuth token was found. Connect a Gmail account.',
  OAUTH_TOKEN_EXPIRED: 'The Gmail OAuth token has expired. Reconnect Gmail.',
  GMAIL_API_UNAVAILABLE: 'The Gmail API is unavailable right now. Try again shortly.',
  INVALID_AUTHORIZATION: 'The Google authorization response was invalid. Start the connection again.',
  REDIRECT_URI_MISMATCH: 'The OAuth callback URL does not match this deployment URL.',
};
export function gmailErrorMessage(code: GmailErrorCode) { return friendlyMessages[code]; }
export type GmailDiagnostic = { name: string; configured: boolean };
export function getGmailDiagnostics(): GmailDiagnostic[] {
  return GMAIL_REQUIRED_ENV_VARS.map(name => ({ name, configured: Boolean(env(name)) }));
}
export function configurationError(): GmailIntegrationError | null {
  const id = Boolean(env('GOOGLE_OAUTH_CLIENT_ID'));
  const secretValue = Boolean(env('GOOGLE_OAUTH_CLIENT_SECRET'));
  const redirect = Boolean(env('GOOGLE_OAUTH_REDIRECT_URL'));
  const encryption = Boolean(env('GMAIL_TOKEN_ENCRYPTION_KEY'));
  const appUrlValue = env('NEXT_PUBLIC_APP_URL');
  const cloudflare = ['CLOUDFLARE_ACCOUNT_ID', 'CLOUDFLARE_API_TOKEN', 'CLOUDFLARE_D1_DATABASE_ID'].every(name => Boolean(env(name)));
  if (!id && !secretValue && !redirect) return new GmailIntegrationError('GOOGLE_OAUTH_NOT_CONFIGURED', gmailErrorMessage('GOOGLE_OAUTH_NOT_CONFIGURED'));
  if (!id) return new GmailIntegrationError('MISSING_CLIENT_ID', gmailErrorMessage('MISSING_CLIENT_ID'));
  if (!secretValue) return new GmailIntegrationError('MISSING_CLIENT_SECRET', gmailErrorMessage('MISSING_CLIENT_SECRET'));
  if (!encryption) return new GmailIntegrationError('MISSING_ENCRYPTION_KEY', gmailErrorMessage('MISSING_ENCRYPTION_KEY'));
  if (!redirect || !appUrlValue) return new GmailIntegrationError('MISSING_REDIRECT_URI', gmailErrorMessage('MISSING_REDIRECT_URI'));
  const expected = `${appUrlValue.replace(/\/$/, '')}/api/gmail/callback`;
  if (env('GOOGLE_OAUTH_REDIRECT_URL') !== expected) return new GmailIntegrationError('REDIRECT_URI_MISMATCH', gmailErrorMessage('REDIRECT_URI_MISMATCH'));
  if (!cloudflare) return new GmailIntegrationError('MISSING_CLOUDFLARE_ENV', gmailErrorMessage('MISSING_CLOUDFLARE_ENV'));
  return null;
}
export type GmailHeader = { name: string; value: string };
export type ParsedGmailMessage = {
  id: string; threadId: string; labelIds: string[]; headers: GmailHeader[];
  from: string; to: string; cc: string; replyTo: string; subject: string;
  body: string; internalDate: string; attachments: Array<{ id: string; filename: string; mimeType: string; size: number }>;
};

function secret() {
  const value = env('GMAIL_TOKEN_ENCRYPTION_KEY');
  if (!value) throw new GmailIntegrationError('MISSING_ENCRYPTION_KEY', gmailErrorMessage('MISSING_ENCRYPTION_KEY'));
  return createHash('sha256').update(value).digest();
}
function seal(value: string) {
  const iv = randomBytes(12);
  const cipher = createCipheriv('aes-256-gcm', secret(), iv);
  const encrypted = Buffer.concat([cipher.update(value, 'utf8'), cipher.final()]);
  return `${iv.toString('base64url')}.${cipher.getAuthTag().toString('base64url')}.${encrypted.toString('base64url')}`;
}
function unseal(value: string) {
  const [iv, tag, data] = value.split('.');
  if (!iv || !tag || !data) throw new Error('Invalid Gmail token');
  const decipher = createDecipheriv('aes-256-gcm', secret(), Buffer.from(iv, 'base64url'));
  decipher.setAuthTag(Buffer.from(tag, 'base64url'));
  return Buffer.concat([decipher.update(Buffer.from(data, 'base64url')), decipher.final()]).toString('utf8');
}

export { TOKEN_COOKIE, STATE_COOKIE };
export function oauthStateMatches(expected: string, actual: string | undefined) {
  if (!actual || expected.length !== actual.length) return false;
  return timingSafeEqual(Buffer.from(expected), Buffer.from(actual));
}
export function createOAuthState() { return randomBytes(32).toString('base64url'); }
export function getAuthorizationUrl(state: string) {
  const error = configurationError();
  if (error) throw error;
  const params = new URLSearchParams({
    client_id: env('GOOGLE_OAUTH_CLIENT_ID') ?? '',
    redirect_uri: env('GOOGLE_OAUTH_REDIRECT_URL') ?? '',
    response_type: 'code', access_type: 'offline', prompt: 'consent',
    scope: GMAIL_SCOPES, state,
  });
  return `https://accounts.google.com/o/oauth2/v2/auth?${params}`;
}
export function encryptTokenSet(tokens: TokenSet) { return seal(JSON.stringify(tokens)); }
export function decryptTokenSet(value: string): TokenSet { return JSON.parse(unseal(value)) as TokenSet; }

export async function exchangeCode(code: string): Promise<TokenSet> {
  const error = configurationError();
  if (error) throw error;
  const response = await fetch('https://oauth2.googleapis.com/token', {
    method: 'POST', headers: { 'content-type': 'application/x-www-form-urlencoded' },
    body: new URLSearchParams({
      code, client_id: env('GOOGLE_OAUTH_CLIENT_ID') ?? '',
      client_secret: env('GOOGLE_OAUTH_CLIENT_SECRET') ?? '',
      redirect_uri: env('GOOGLE_OAUTH_REDIRECT_URL') ?? '', grant_type: 'authorization_code',
    }),
  });
  if (!response.ok) throw new GmailIntegrationError('GMAIL_API_UNAVAILABLE', `Google authorization failed (${response.status})`);
  return await response.json() as TokenSet;
}

export async function accessToken(tokens: TokenSet): Promise<TokenSet> {
  if (!tokens.access_token) throw new GmailIntegrationError('OAUTH_TOKEN_MISSING', gmailErrorMessage('OAUTH_TOKEN_MISSING'));
  if (tokens.expiry_date && tokens.expiry_date > Date.now() + 60_000) return tokens;
  if (!tokens.refresh_token) throw new GmailIntegrationError('OAUTH_TOKEN_EXPIRED', gmailErrorMessage('OAUTH_TOKEN_EXPIRED'));
  const response = await fetch('https://oauth2.googleapis.com/token', {
    method: 'POST', headers: { 'content-type': 'application/x-www-form-urlencoded' },
    body: new URLSearchParams({
      client_id: env('GOOGLE_OAUTH_CLIENT_ID') ?? '',
      client_secret: env('GOOGLE_OAUTH_CLIENT_SECRET') ?? '',
      refresh_token: tokens.refresh_token, grant_type: 'refresh_token',
    }),
  });
  if (!response.ok) throw new GmailIntegrationError('OAUTH_TOKEN_EXPIRED', gmailErrorMessage('OAUTH_TOKEN_EXPIRED'));
  const next = await response.json() as TokenSet;
  return { ...tokens, ...next, expiry_date: Date.now() + ((next as { expires_in?: number }).expires_in ?? 3600) * 1000 };
}

export function parseGmailMessage(message: any): ParsedGmailMessage {
  const headers = (message.payload?.headers ?? []) as GmailHeader[];
  const header = (name: string) => headers.find(item => item.name.toLowerCase() === name.toLowerCase())?.value ?? '';
  const attachments: ParsedGmailMessage['attachments'] = [];
  let body = '';
  const visit = (part: any) => {
    if (part.filename && part.body?.attachmentId) attachments.push({ id: part.body.attachmentId, filename: part.filename, mimeType: part.mimeType ?? 'application/octet-stream', size: part.body.size ?? 0 });
    if (part.mimeType === 'text/plain' && part.body?.data && !body) body = Buffer.from(part.body.data, 'base64url').toString('utf8');
    (part.parts ?? []).forEach(visit);
  };
  visit(message.payload ?? {});
  return { id: message.id, threadId: message.threadId, labelIds: message.labelIds ?? [], headers, from: header('From'), to: header('To'), cc: header('Cc'), replyTo: header('Reply-To'), subject: header('Subject'), body, internalDate: message.internalDate ?? '', attachments };
}

export function businessEmailFromHeaders(headers: GmailHeader[], mappings: Record<string, string[]>) {
  const relevant = headers.filter(h => ['to', 'cc', 'delivered-to', 'x-forwarded-to', 'x-original-to', 'reply-to', 'from'].includes(h.name.toLowerCase())).map(h => h.value.toLowerCase());
  const matches = Object.entries(mappings).filter(([, addresses]) => addresses.some(address => relevant.some(value => value.includes(address.toLowerCase())))).map(([id]) => id);
  return matches.length === 1 ? matches[0] : null;
}

export function encodeRawMessage(fields: { from: string; to: string; subject: string; body: string; inReplyTo?: string; references?: string }) {
  const headers = [`From: ${fields.from}`, `To: ${fields.to}`, `Subject: ${fields.subject}`, 'MIME-Version: 1.0', 'Content-Type: text/plain; charset="UTF-8"'];
  if (fields.inReplyTo) headers.push(`In-Reply-To: ${fields.inReplyTo}`);
  if (fields.references) headers.push(`References: ${fields.references}`);
  return Buffer.from(`${headers.join('\r\n')}\r\n\r\n${fields.body}`, 'utf8').toString('base64url');
}

export async function gmailRequest(path: string, tokens: TokenSet, init?: RequestInit) {
  const current = await accessToken(tokens);
  const response = await fetch(`https://gmail.googleapis.com/gmail/v1/users/me/${path}`, {
    ...init, headers: { ...(init?.headers ?? {}), authorization: 'Bearer ' + current.access_token },
  });
  if (response.status === 401) throw new GmailIntegrationError('OAUTH_TOKEN_EXPIRED', gmailErrorMessage('OAUTH_TOKEN_EXPIRED'));
  if (!response.ok) throw new GmailIntegrationError('GMAIL_API_UNAVAILABLE', `Gmail request failed (${response.status})`);
  return { response, tokens: current };
}
