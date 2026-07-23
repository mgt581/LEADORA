import { NextResponse } from 'next/server';
import { createOAuthState, getAuthorizationUrl, STATE_COOKIE } from '@/lib/server/gmail';

export const runtime = 'nodejs';
export async function GET() {
  const state = createOAuthState();
  const response = NextResponse.redirect(getAuthorizationUrl(state));
  response.cookies.set(STATE_COOKIE, state, { httpOnly: true, secure: process.env.NODE_ENV === 'production', sameSite: 'lax', maxAge: 600, path: '/' });
  return response;
}
