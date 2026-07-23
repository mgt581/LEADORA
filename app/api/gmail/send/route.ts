import { NextRequest, NextResponse } from 'next/server';
import { decryptTokenSet, encodeRawMessage, gmailRequest, TOKEN_COOKIE } from '@/lib/server/gmail';

export const runtime = 'nodejs';
export async function POST(request: NextRequest) {
  const cookie = request.cookies.get(TOKEN_COOKIE)?.value;
  if (!cookie) return NextResponse.json({ error: 'Connect Gmail before sending.' }, { status: 401 });
  const input = await request.json() as { to?: string; subject?: string; body?: string; from?: string; threadId?: string; inReplyTo?: string; references?: string };
  if (!input.to || !input.subject || !input.body || !input.from) return NextResponse.json({ error: 'Recipient, sender, subject and body are required.' }, { status: 400 });
  try {
    const { response } = await gmailRequest('messages/send', decryptTokenSet(cookie), { method: 'POST', headers: { 'content-type': 'application/json' }, body: JSON.stringify({ raw: encodeRawMessage(input as Required<typeof input>), ...(input.threadId ? { threadId: input.threadId } : {}) }) });
    return NextResponse.json(await response.json());
  } catch (error) { return NextResponse.json({ error: error instanceof Error ? error.message : 'Gmail send failed.' }, { status: 502 }); }
}
