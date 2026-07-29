import { NextRequest, NextResponse } from 'next/server';
import { auditPublicWebsite } from '@/lib/leads/public-website';

export const runtime = 'nodejs';
export async function POST(request: NextRequest) {
  try {
    const body = await request.json() as { website?: string };
    if (!body.website || body.website.length > 2_048) return NextResponse.json({ error: 'Enter a valid website address.' }, { status: 400 });
    return NextResponse.json(await auditPublicWebsite(body.website));
  } catch (error) {
    return NextResponse.json({ error: error instanceof Error ? error.message : 'Website analysis failed.' }, { status: 422 });
  }
}
