import { NextResponse } from 'next/server';
import { createOAuthState, getAuthorizationUrl, GmailIntegrationError, STATE_COOKIE } from '@/lib/server/gmail';

export const runtime = 'nodejs';
export async function GET() {
  try {
    const state = createOAuthState();
    const response = NextResponse.redirect(getAuthorizationUrl(state));
    response.cookies.set(STATE_COOKIE, state, { httpOnly: true, secure: process.env.NODE_ENV === 'production', sameSite: 'lax', maxAge: 600, path: '/' });
    return response;
  } catch (error) {
    const code = error instanceof GmailIntegrationError ? error.code : 'GOOGLE_OAUTH_NOT_CONFIGURED';
    return NextResponse.redirect(`/settings/?gmail=error&reason=${code}`);
  }
}
