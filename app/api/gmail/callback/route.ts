import { NextRequest, NextResponse } from 'next/server';
import { encryptTokenSet, exchangeCode, oauthStateMatches, STATE_COOKIE, TOKEN_COOKIE } from '@/lib/server/gmail';

export const runtime = 'nodejs';
export async function GET(request: NextRequest) {
  const { searchParams } = new URL(request.url);
  const code = searchParams.get('code'); const state = searchParams.get('state');
  if (!code || !oauthStateMatches(request.cookies.get(STATE_COOKIE)?.value ?? '', state ?? undefined)) {
    return NextResponse.redirect(new URL('/settings/?gmail=error&reason=invalid_authorization', request.url));
  }
  try {
    const tokens = await exchangeCode(code);
    const response = NextResponse.redirect(new URL('/settings/?gmail=connected', request.url));
    response.cookies.set(TOKEN_COOKIE, encryptTokenSet(tokens), { httpOnly: true, secure: process.env.NODE_ENV === 'production', sameSite: 'lax', maxAge: 60 * 60 * 24 * 30, path: '/' });
    response.cookies.delete(STATE_COOKIE);
    return response;
  } catch {
    return NextResponse.redirect(new URL('/settings/?gmail=error&reason=authorization_failed', request.url));
  }
}
