import assert from 'node:assert/strict';
import test from 'node:test';
import { NextRequest } from 'next/server';
import { GET as auth } from '../../app/api/gmail/auth/route';
import { GET as callback } from '../../app/api/gmail/callback/route';
import { GET as status } from '../../app/api/gmail/status/route';
import { POST as disconnect } from '../../app/api/gmail/disconnect/route';
import { POST as sync } from '../../app/api/gmail/sync/route';
import { GET as readState, PUT as writeState } from '../../app/api/state/[key]/route';
import { encryptTokenSet, decryptTokenSet, TOKEN_COOKIE, STATE_COOKIE, RETURN_COOKIE, oauthStateMatches, isLeadRallyAlias } from './gmail';

const env = { GOOGLE_OAUTH_CLIENT_ID: 'test-client', GOOGLE_OAUTH_CLIENT_SECRET: 'test-secret', GMAIL_TOKEN_ENCRYPTION_KEY: 'test-only-encryption-key', GOOGLE_OAUTH_REDIRECT_URL: 'https://leadrally.co.uk/api/gmail/callback' };
(globalThis as any)[Symbol.for('__cloudflare-context__')] = { env };
const originalFetch = globalThis.fetch;
function request(url: string, cookie = '', init: RequestInit = {}) { return new NextRequest(url, { ...init, headers: { ...init.headers, cookie } }); }

test('both production hosts initiate the registered callback with secure shared state', async () => {
  for (const host of ['leadrally.co.uk', 'www.leadrally.co.uk']) {
    const response = await auth(request(`https://${host}/api/gmail/auth`));
    const url = new URL(response.headers.get('location')!);
    assert.equal(url.hostname, 'accounts.google.com');
    assert.equal(url.searchParams.get('redirect_uri'), env.GOOGLE_OAUTH_REDIRECT_URL);
    assert.equal(url.searchParams.get('access_type'), 'offline');
    const cookie = response.cookies.get(STATE_COOKIE)!;
    assert.equal(cookie.value, url.searchParams.get('state'));
    assert.equal(cookie.domain, 'leadrally.co.uk');
    assert.equal(cookie.httpOnly, true); assert.equal(cookie.secure, true);
    assert.equal(response.cookies.get(RETURN_COOKIE)?.value, `https://${host}`);
  }
  const wrongHost = await auth(request('https://untrusted.example/api/gmail/auth'));
  assert.match(wrongHost.headers.get('location')!, /REDIRECT_URI_MISMATCH/);
  assert.equal(isLeadRallyAlias(env.GOOGLE_OAUTH_REDIRECT_URL, 'https://evil.leadrally.co.uk/api/gmail/callback'), false);
  assert.equal(oauthStateMatches('a', 'é'), false);
});

test('callback validates state, seals expiring tokens and returns to the original hostname', async () => {
  let calls = 0;
  globalThis.fetch = async (url, init) => {
    calls++;
    assert.equal(String(url), 'https://oauth2.googleapis.com/token');
    assert.equal(new URLSearchParams(init?.body as string).get('redirect_uri'), env.GOOGLE_OAUTH_REDIRECT_URL);
    return Response.json({ access_token: 'test-access', refresh_token: 'test-refresh', expires_in: 3600 });
  };
  try {
    const cookies = `${STATE_COOKIE}=test-state; ${RETURN_COOKIE}=https://www.leadrally.co.uk`;
    const response = await callback(request('https://leadrally.co.uk/api/gmail/callback?code=test-code&state=test-state', cookies));
    assert.equal(response.headers.get('location'), 'https://www.leadrally.co.uk/settings/?gmail=connected');
    const token = response.cookies.get(TOKEN_COOKIE)!;
    assert.equal(token.domain, 'leadrally.co.uk'); assert.equal(token.httpOnly, true);
    const decrypted = decryptTokenSet(token.value);
    assert.equal(decrypted.refresh_token, 'test-refresh'); assert.ok(decrypted.expiry_date! > Date.now());
    assert.equal(response.cookies.get(STATE_COOKIE)?.maxAge, 0);
    const invalid = await callback(request('https://leadrally.co.uk/api/gmail/callback?code=x&state=wrong', cookies));
    assert.match(invalid.headers.get('location')!, /INVALID_AUTHORIZATION/);
    const denied = await callback(request('https://leadrally.co.uk/api/gmail/callback?error=access_denied&state=test-state', cookies));
    assert.match(denied.headers.get('location')!, /INVALID_AUTHORIZATION/);
    assert.equal(calls, 1);
  } finally { globalThis.fetch = originalFetch; }
});

test('legacy encrypted tokens refresh once and the new token is persisted without exposing it', async () => {
  let refreshes = 0;
  globalThis.fetch = async (url) => {
    if (String(url) === 'https://oauth2.googleapis.com/token') { refreshes++; return Response.json({ access_token: 'refreshed', expires_in: 3600 }); }
    return Response.json({ emailAddress: 'test@example.com' });
  };
  try {
    const legacy = encryptTokenSet({ access_token: 'expired', refresh_token: 'keep-refresh', expiry_date: 1 });
    const response = await status(request('https://www.leadrally.co.uk/api/gmail/status', `leadora-gmail-token=${legacy}`));
    const body = await response.json(); assert.equal(body.connected, true); assert.equal(body.access_token, undefined);
    const value = response.cookies.get(TOKEN_COOKIE)!.value;
    assert.equal(decryptTokenSet(value).refresh_token, 'keep-refresh');
    await status(request('https://www.leadrally.co.uk/api/gmail/status', `${TOKEN_COOKIE}=${value}`));
    assert.equal(refreshes, 1);
  } finally { globalThis.fetch = originalFetch; }
});

test('sync reuses one refreshed token for all messages and retains business matching', async () => {
  let refreshes = 0;
  globalThis.fetch = async (url) => {
    const value = String(url);
    if (value === 'https://oauth2.googleapis.com/token') { refreshes++; return Response.json({ access_token: 'refreshed', expires_in: 3600 }); }
    if (value.includes('messages?')) return Response.json({ messages: [{ id: 'm1' }, { id: 'm2' }] });
    return Response.json({ id: value.includes('m1') ? 'm1' : 'm2', payload: { headers: [{ name: 'Delivered-To', value: 'info@business.example' }] } });
  };
  try {
    const cookie = encryptTokenSet({ access_token: 'expired', refresh_token: 'refresh', expiry_date: 1 });
    const response = await sync(request('https://www.leadrally.co.uk/api/gmail/sync', `${TOKEN_COOKIE}=${cookie}`, { method: 'POST', headers: { 'content-type': 'application/json' }, body: JSON.stringify({ mappings: { business: ['info@business.example'] } }) }));
    const body = await response.json(); assert.equal(body.messages.length, 2); assert.equal(body.messages[0].businessId, 'business');
    assert.equal(refreshes, 1); assert.ok(response.cookies.get(TOKEN_COOKIE));
  } finally { globalThis.fetch = originalFetch; }
});

test('Gmail state uses the existing storage key and unknown keys remain rejected', async () => {
  const bindings: unknown[][] = [];
  const statement = { bind(...values: unknown[]) { bindings.push(values); return this; }, async first() { return { value_json: '[{"id":"existing"}]', updated_at: 'test-date' }; }, async run() {} };
  (env as any).LEADORA_DB = { prepare() { return statement; } };
  const params = { params: Promise.resolve({ key: 'leadora-gmail-messages' }) };
  const response = await readState(request('https://leadrally.co.uk/api/state/leadora-gmail-messages'), params);
  assert.deepEqual((await response.json()).value, [{ id: 'existing' }]);
  const write = await writeState(request('https://leadrally.co.uk/api/state/leadora-gmail-messages', '', { method: 'PUT', body: JSON.stringify({ value: [{ id: 'preserved' }] }) }), params);
  assert.equal(write.status, 200); assert.equal(bindings[1][0], 'leadora-gmail-messages');
  const invalid = await readState(request('https://leadrally.co.uk/api/state/arbitrary'), { params: Promise.resolve({ key: 'arbitrary' }) });
  assert.equal(invalid.status, 404);
});

test('refresh failures and damaged cookies fail safely without leaking tokens', async () => {
  globalThis.fetch = async () => Response.json({ error: 'invalid_grant' }, { status: 400 });
  try {
    const cookie = encryptTokenSet({ access_token: 'expired', refresh_token: 'private-refresh', expiry_date: 1 });
    const expired = await status(request('https://leadrally.co.uk/api/gmail/status', `${TOKEN_COOKIE}=${cookie}`));
    const body = await expired.json(); assert.equal(body.connected, false); assert.equal(body.code, 'OAUTH_TOKEN_EXPIRED');
    assert.equal(JSON.stringify(body).includes('private-refresh'), false);
    const damaged = await status(request('https://leadrally.co.uk/api/gmail/status', `${TOKEN_COOKIE}=damaged`));
    assert.equal((await damaged.json()).connected, false);
  } finally { globalThis.fetch = originalFetch; }
});

test('disconnect clears shared and legacy cookies after revocation', async () => {
  globalThis.fetch = async () => new Response(null, { status: 200 });
  try {
    const cookie = encryptTokenSet({ access_token: 'test', refresh_token: 'test-refresh' });
    const response = await disconnect(request('https://www.leadrally.co.uk/api/gmail/disconnect', `${TOKEN_COOKIE}=${cookie}`, { method: 'POST' }));
    assert.equal(response.cookies.get(TOKEN_COOKIE)?.maxAge, 0);
    assert.equal(response.cookies.get(TOKEN_COOKIE)?.domain, 'leadrally.co.uk');
    assert.equal(response.cookies.get('leadora-gmail-token')?.maxAge, 0);
    assert.equal(response.cookies.get('leadora-gmail-token')?.domain, undefined);
  } finally { globalThis.fetch = originalFetch; }
});
