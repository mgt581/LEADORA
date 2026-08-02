import { NextRequest, NextResponse } from 'next/server';
import { encryptTokenSet, oauthStateMatches } from '@/lib/server/gmail';
import {
  companyIdFromState,
  exchangeGoogleIntegrationCode,
  GOOGLE_INTEGRATION_STATE_COOKIE,
  googleCompanyCookie,
  googleIntegrationRedirectUrl,
} from '@/lib/server/google-integrations';

export const runtime = 'nodejs';

export async function GET(request: NextRequest) {
  const { searchParams } = new URL(request.url);
  const code = searchParams.get('code');
  const state = searchParams.get('state') ?? '';
  const expected = request.cookies.get(GOOGLE_INTEGRATION_STATE_COOKIE)?.value ?? '';
  const companyId = companyIdFromState(state);
  if (!code || !companyId || !oauthStateMatches(expected, state)) {
    return NextResponse.redirect(new URL('/google-profiles/?google=error&reason=INVALID_AUTHORIZATION', request.url));
  }
  try {
    const tokens = await exchangeGoogleIntegrationCode(code, googleIntegrationRedirectUrl(request.url));
    const response = NextResponse.redirect(new URL(`/google-profiles/?google=connected&companyId=${companyId}`, request.url));
    response.cookies.set(googleCompanyCookie(companyId), encryptTokenSet(tokens), {
      httpOnly: true, secure: process.env.NODE_ENV === 'production', sameSite: 'lax', maxAge: 60 * 60 * 24 * 90, path: '/',
    });
    response.cookies.delete(GOOGLE_INTEGRATION_STATE_COOKIE);
    return response;
  } catch {
    return NextResponse.redirect(new URL(`/google-profiles/?google=error&reason=TOKEN_EXCHANGE_FAILED&companyId=${companyId}`, request.url));
  }
}
