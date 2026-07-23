import { NextRequest, NextResponse } from 'next/server';
import { decryptTokenSet, TOKEN_COOKIE } from '@/lib/server/gmail';

export const runtime = 'nodejs';
export async function POST(request: NextRequest) {
  const value = request.cookies.get(TOKEN_COOKIE)?.value;
  if (value) try { const token = decryptTokenSet(value); await fetch(`https://oauth2.googleapis.com/revoke?token=${encodeURIComponent(token.refresh_token ?? token.access_token)}`, { method: 'POST' }); } catch {}
  const response = NextResponse.json({ disconnected: true });
  response.cookies.delete(TOKEN_COOKIE);
  return response;
}
