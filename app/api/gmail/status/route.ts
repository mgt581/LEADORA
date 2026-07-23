import { NextRequest, NextResponse } from 'next/server';
import { decryptTokenSet, TOKEN_COOKIE } from '@/lib/server/gmail';

export const runtime = 'nodejs';
export async function GET(request: NextRequest) {
  const value = request.cookies.get(TOKEN_COOKIE)?.value;
  if (!value) return NextResponse.json({ connected: false });
  try {
    const token = decryptTokenSet(value);
    const response = await fetch('https://gmail.googleapis.com/gmail/v1/users/me/profile', { headers: { authorization: 'Bearer ' + token.access_token } });
    if (!response.ok) return NextResponse.json({ connected: false, error: 'Gmail authorization has expired; reconnect Gmail.' });
    const profile = await response.json() as { emailAddress: string };
    return NextResponse.json({ connected: true, emailAddress: profile.emailAddress });
  } catch { return NextResponse.json({ connected: false, error: 'Gmail connection is unavailable.' }); }
}
