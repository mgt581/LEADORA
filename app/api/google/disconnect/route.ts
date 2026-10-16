import { NextRequest, NextResponse } from 'next/server';
import { googleCompanyCookie, validGoogleCompanyId } from '@/lib/server/google-integrations';

export const runtime = 'nodejs';

export async function POST(request: NextRequest) {
  const body = await request.json().catch(() => ({})) as { companyId?: string };
  if (!validGoogleCompanyId(body.companyId)) return NextResponse.json({ error: 'Invalid company.' }, { status: 400 });
  const response = NextResponse.json({ ok: true });
  response.cookies.set(googleCompanyCookie(body.companyId),'',{httpOnly:true,secure:true,sameSite:'lax',path:'/',domain:'leadrally.co.uk',maxAge:0});
  return response;
}
