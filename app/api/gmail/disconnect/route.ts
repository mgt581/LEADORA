import { NextRequest, NextResponse } from 'next/server';
import { decryptTokenSet, readGmailToken, clearGmailTokens } from '@/lib/server/gmail';

export const runtime = 'nodejs';
export async function POST(request: NextRequest) {
  const value = readGmailToken(request);
  if (value) try { const token = decryptTokenSet(value); await fetch(`https://oauth2.googleapis.com/revoke?token=${encodeURIComponent(token.refresh_token ?? token.access_token)}`, { method: 'POST' }); } catch {}
  const response = NextResponse.json({ disconnected: true });
  clearGmailTokens(response, request.url);
  return response;
}
