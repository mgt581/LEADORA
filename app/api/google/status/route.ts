import { NextRequest, NextResponse } from 'next/server';
import { decryptTokenSet, encryptTokenSet } from '@/lib/server/gmail';
import {
  googleAccessToken,
  googleAccountEmail,
  googleCompanyCookie,
  listAnalyticsProperties,
  validGoogleCompanyId,
} from '@/lib/server/google-integrations';

export const runtime = 'nodejs';

export async function GET(request: NextRequest) {
  const companyId = new URL(request.url).searchParams.get('companyId');
  if (!validGoogleCompanyId(companyId)) return NextResponse.json({ error: 'Invalid company.' }, { status: 400 });
  const cookieName = googleCompanyCookie(companyId);
  const encrypted = request.cookies.get(cookieName)?.value;
  if (!encrypted) return NextResponse.json({ connected: false, properties: [] });
  try {
    const tokens = await googleAccessToken(decryptTokenSet(encrypted));
    const email = await googleAccountEmail(tokens.access_token);
    let properties: Awaited<ReturnType<typeof listAnalyticsProperties>> = [];
    let warning = '';
    try { properties = await listAnalyticsProperties(tokens.access_token); }
    catch (error) { warning = error instanceof Error ? error.message : 'Analytics properties are unavailable.'; }
    const response = NextResponse.json({ connected: true, email, properties, warning });
    response.cookies.set(cookieName, encryptTokenSet(tokens), {
      httpOnly: true, secure: process.env.NODE_ENV === 'production', sameSite: 'lax', maxAge: 60 * 60 * 24 * 90, path: '/',
    });
    return response;
  } catch {
    const response = NextResponse.json({ connected: false, properties: [], error: 'Google connection expired. Reconnect this company.' });
    response.cookies.delete(cookieName);
    return response;
  }
}
