import { NextRequest, NextResponse } from 'next/server';
import { createSession, SESSION_COOKIE, sessionCookieOptions, validMutationOrigin } from '@/lib/server/auth';

export const runtime = 'nodejs';

const FIREBASE_API_KEY = 'AIzaSyDPqyqjdmbLaOr7x4MWQA9eYvgc5jT0F_I';
const ALLOWED_GOOGLE_EMAILS = new Set([
  'alexbryant3234@gmail.com',
  'ajbryantsleads@gmail.com',
]);

export async function POST(request: NextRequest) {
  if (!validMutationOrigin(request)) return NextResponse.json({ error: 'Invalid request origin.' }, { status: 403 });
  const body = await request.json().catch(() => ({})) as { idToken?: string };
  if (!body.idToken || body.idToken.length > 10000) return NextResponse.json({ error: 'Google sign-in token is missing.' }, { status: 400 });

  try {
    const response = await fetch(`https://identitytoolkit.googleapis.com/v1/accounts:lookup?key=${FIREBASE_API_KEY}`, {
      method: 'POST',
      headers: { 'content-type': 'application/json' },
      body: JSON.stringify({ idToken: body.idToken }),
    });
    if (!response.ok) return NextResponse.json({ error: 'Google sign-in could not be verified.' }, { status: 401 });
    const data = await response.json() as { users?: Array<{ email?: string; emailVerified?: boolean }> };
    const user = data.users?.[0];
    const email = user?.email?.trim().toLowerCase();
    if (!email || !user?.emailVerified || !ALLOWED_GOOGLE_EMAILS.has(email)) {
      return NextResponse.json({ error: 'This Google account is not authorised for LeadRally.' }, { status: 403 });
    }

    const result = NextResponse.json({ ok: true, user: { email, role: 'admin', tenantId: 'owner' } });
    result.cookies.set(SESSION_COOKIE, createSession(email), sessionCookieOptions());
    result.headers.set('cache-control', 'no-store');
    return result;
  } catch {
    return NextResponse.json({ error: 'Google sign-in is temporarily unavailable.' }, { status: 503 });
  }
}
