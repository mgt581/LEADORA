import { NextRequest, NextResponse } from 'next/server';
import {
  configurationError,
  decryptTokenSet,
  getGmailDiagnostics,
  gmailErrorMessage,
  GmailIntegrationError,
  gmailRequest,
  readGmailToken,
  persistGmailTokens,
} from '@/lib/server/gmail';

export const runtime = 'nodejs';

export async function GET(request: NextRequest) {
  const diagnostics = process.env.NODE_ENV === 'development' ? { diagnostics: getGmailDiagnostics() } : {};
  const configError = configurationError();
  if (configError) {
    return NextResponse.json({ connected: false, code: configError.code, error: configError.message, ...diagnostics });
  }
  const value = readGmailToken(request);
  if (!value) return NextResponse.json({ connected: false, code: 'OAUTH_TOKEN_MISSING', error: gmailErrorMessage('OAUTH_TOKEN_MISSING'), ...diagnostics });
  try {
    const { response, tokens } = await gmailRequest('profile', decryptTokenSet(value));
    const profile = await response.json() as { emailAddress: string };
    return persistGmailTokens(NextResponse.json({ connected: true, code: null, emailAddress: profile.emailAddress, ...diagnostics }), request, tokens);
  } catch (error) {
    const integrationError = error instanceof GmailIntegrationError
      ? error
      : new GmailIntegrationError('GMAIL_API_UNAVAILABLE', gmailErrorMessage('GMAIL_API_UNAVAILABLE'));
    return NextResponse.json({ connected: false, code: integrationError.code, error: integrationError.message, ...diagnostics });
  }
}
