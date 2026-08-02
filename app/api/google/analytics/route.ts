import { NextRequest, NextResponse } from 'next/server';
import { decryptTokenSet, encryptTokenSet } from '@/lib/server/gmail';
import { googleAccessToken, googleCompanyCookie, validGoogleCompanyId } from '@/lib/server/google-integrations';

export const runtime = 'nodejs';
type Metrics = { activeUsers: number; sessions: number; pageViews: number; keyEvents: number };

function parseMetrics(data: { rows?: Array<{ metricValues?: Array<{ value?: string }> }> }): Metrics {
  const values = data.rows?.[0]?.metricValues ?? [];
  return {
    activeUsers: Number(values[0]?.value || 0),
    sessions: Number(values[1]?.value || 0),
    pageViews: Number(values[2]?.value || 0),
    keyEvents: Number(values[3]?.value || 0),
  };
}

async function runReport(accessTokenValue: string, propertyId: string, startDate: string, endDate: string) {
  const response = await fetch(`https://analyticsdata.googleapis.com/v1beta/properties/${propertyId}:runReport`, {
    method: 'POST',
    headers: { authorization: `Bearer ${accessTokenValue}`, 'content-type': 'application/json' },
    body: JSON.stringify({
      dateRanges: [{ startDate, endDate }],
      metrics: [
        { name: 'activeUsers' },
        { name: 'sessions' },
        { name: 'screenPageViews' },
        { name: 'keyEvents' },
      ],
    }),
  });
  if (!response.ok) throw new Error(response.status === 403
    ? 'Google Analytics Data API is not enabled or this account cannot access that property.'
    : `Google Analytics report failed (${response.status}).`);
  return parseMetrics(await response.json());
}

export async function POST(request: NextRequest) {
  const body = await request.json().catch(() => ({})) as { companyId?: string; propertyId?: string };
  if (!validGoogleCompanyId(body.companyId) || !/^\d+$/.test(body.propertyId ?? '')) {
    return NextResponse.json({ error: 'Choose a valid company and GA4 property.' }, { status: 400 });
  }
  const cookieName = googleCompanyCookie(body.companyId);
  const encrypted = request.cookies.get(cookieName)?.value;
  if (!encrypted) return NextResponse.json({ error: 'Connect Google for this company first.' }, { status: 401 });
  try {
    const tokens = await googleAccessToken(decryptTokenSet(encrypted));
    const [current, previous] = await Promise.all([
      runReport(tokens.access_token, body.propertyId!, '30daysAgo', 'yesterday'),
      runReport(tokens.access_token, body.propertyId!, '60daysAgo', '31daysAgo'),
    ]);
    const response = NextResponse.json({ current, previous, period: 'Last 30 complete days' });
    response.cookies.set(cookieName, encryptTokenSet(tokens), {
      httpOnly: true, secure: process.env.NODE_ENV === 'production', sameSite: 'lax', maxAge: 60 * 60 * 24 * 90, path: '/',
    });
    return response;
  } catch (error) {
    return NextResponse.json({ error: error instanceof Error ? error.message : 'Google Analytics is unavailable.' }, { status: 502 });
  }
}
