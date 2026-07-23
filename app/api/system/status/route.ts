import { NextResponse } from 'next/server';
import { configurationError, getGmailDiagnostics } from '@/lib/server/gmail';

export const runtime = 'nodejs';

export async function GET() {
  const gmailError = configurationError();
  const configured = getGmailDiagnostics();
  const has = (name: string) => configured.find(item => item.name === name)?.configured ?? false;
  return NextResponse.json({
    statuses: {
      cloudflare: { ok: has('CLOUDFLARE_ACCOUNT_ID') && has('CLOUDFLARE_API_TOKEN'), detail: 'Deployment environment' },
      backend: { ok: true, detail: 'API is responding' },
      database: { ok: has('CLOUDFLARE_D1_DATABASE_ID'), detail: has('CLOUDFLARE_D1_DATABASE_ID') ? 'D1 configured' : 'D1 database ID missing' },
      googleOAuth: { ok: !gmailError || !['GOOGLE_OAUTH_NOT_CONFIGURED', 'MISSING_CLIENT_ID', 'MISSING_CLIENT_SECRET', 'MISSING_REDIRECT_URI', 'REDIRECT_URI_MISMATCH'].includes(gmailError.code), detail: gmailError?.message ?? 'Configured' },
      gmailApi: { ok: true, detail: 'Available when an account is connected' },
      connectedAccount: { ok: false, detail: 'Check Gmail status for the signed-in user' },
    },
    ...(process.env.NODE_ENV === 'development' ? { diagnostics: configured } : {}),
  });
}
