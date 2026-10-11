import { NextRequest, NextResponse } from 'next/server';
import { exchangeCode, GmailIntegrationError, oauthStateMatches, STATE_COOKIE, RETURN_COOKIE, gmailSettingsUrl, clearGmailOAuthCookies, persistGmailTokens } from '@/lib/server/gmail';

export const runtime = 'nodejs';
export async function GET(request: NextRequest) {
  const { searchParams } = new URL(request.url);
  const code = searchParams.get('code'), state = searchParams.get('state');
  const validState = oauthStateMatches(request.cookies.get(STATE_COOKIE)?.value ?? '', state ?? undefined);
  const settings = gmailSettingsUrl(request.url, validState ? request.cookies.get(RETURN_COOKIE)?.value : undefined);
  function finish(query: string) {
    const response = NextResponse.redirect(new URL(query, settings));
    clearGmailOAuthCookies(response, request.url);
    response.headers.set('Cache-Control', 'no-store');
    return response;
  }
  if (!code || !validState || searchParams.has('error')) return finish('?gmail=error&reason=INVALID_AUTHORIZATION');
  try {
    const callbackUrl = new URL('/api/gmail/callback', request.url).toString();
    const tokens = await exchangeCode(code, callbackUrl);
    return persistGmailTokens(finish('?gmail=connected'), request, tokens);
  } catch (error) {
    const reason = error instanceof GmailIntegrationError ? error.code : 'GMAIL_API_UNAVAILABLE';
    return finish(`?gmail=error&reason=${reason}`);
  }
}
