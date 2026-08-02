import { NextRequest, NextResponse } from 'next/server';
import {
  createGoogleIntegrationState,
  GOOGLE_INTEGRATION_STATE_COOKIE,
  googleIntegrationAuthorizationUrl,
  googleIntegrationRedirectUrl,
  validGoogleCompanyId,
} from '@/lib/server/google-integrations';

export const runtime = 'nodejs';

export async function GET(request: NextRequest) {
  const companyId = new URL(request.url).searchParams.get('companyId');
  if (!validGoogleCompanyId(companyId)) {
    return NextResponse.redirect(new URL('/google-profiles/?google=error&reason=INVALID_COMPANY', request.url));
  }
  try {
    const state = createGoogleIntegrationState(companyId);
    const redirectUri = googleIntegrationRedirectUrl(request.url);
    const response = NextResponse.redirect(googleIntegrationAuthorizationUrl(state, redirectUri));
    response.cookies.set(GOOGLE_INTEGRATION_STATE_COOKIE, state, {
      httpOnly: true, secure: process.env.NODE_ENV === 'production', sameSite: 'lax', maxAge: 600, path: '/',
    });
    return response;
  } catch {
    return NextResponse.redirect(new URL('/google-profiles/?google=error&reason=OAUTH_NOT_CONFIGURED', request.url));
  }
}
