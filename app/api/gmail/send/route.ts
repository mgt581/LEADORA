import { NextRequest, NextResponse } from 'next/server';
import { decryptTokenSet, encodeRawMessage, gmailRequest, TOKEN_COOKIE } from '@/lib/server/gmail';
import { decodeHtmlEntities } from '@/lib/text';

export const runtime = 'nodejs';
export async function POST(request: NextRequest) {
  const cookie = request.cookies.get(TOKEN_COOKIE)?.value;
  if (!cookie) return NextResponse.json({ error: 'Connect Gmail before sending.' }, { status: 401 });
  const input = await request.json() as { to?: string; subject?: string; body?: string; from?: string; threadId?: string; inReplyTo?: string; references?: string };
  if (!input.to || !input.subject || !input.body || !input.from) return NextResponse.json({ error: 'Recipient, sender, subject and body are required.' }, { status: 400 });
  const emailPattern = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
  if (!emailPattern.test(input.to) || !emailPattern.test(input.from) || /[\r\n]/.test(input.to + input.from)) return NextResponse.json({ error: 'Enter valid sender and recipient email addresses.' }, { status: 400 });
  if (input.subject.length > 200 || input.body.length > 100_000) return NextResponse.json({ error: 'The subject or email body is too long.' }, { status: 413 });
  try {
    const message = { ...input, subject: decodeHtmlEntities(input.subject.trim()), body: decodeHtmlEntities(input.body) } as Required<typeof input>;
    const { response } = await gmailRequest('messages/send', decryptTokenSet(cookie), { method: 'POST', headers: { 'content-type': 'application/json' }, body: JSON.stringify({ raw: encodeRawMessage(message), ...(input.threadId ? { threadId: input.threadId } : {}) }) });
    return NextResponse.json(await response.json());
  } catch (error) { return NextResponse.json({ error: error instanceof Error ? error.message : 'Gmail send failed.' }, { status: 502 }); }
}
