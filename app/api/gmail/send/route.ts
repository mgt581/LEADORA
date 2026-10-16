import { NextRequest, NextResponse } from 'next/server';
import { GMAIL_CONNECTION_EMAIL, decryptTokenSet, encodeRawMessage, gmailRequest, readGmailToken, persistGmailTokens } from '@/lib/server/gmail';
import { decodeHtmlEntities } from '@/lib/text';
import { cleaningOutreachHtml, constructionOutreachHtml, digitalOutreachHtml, teethWhiteningOutreachHtml } from '@/lib/email-templates';

export const runtime = 'nodejs';
const ALLOWED_SENDERS = new Set(['info@bryantandcocleaning.co.uk','info@bryantconstructiongroup.co.uk','info@bryantdigitalsolutions.com','info@mrwhiteteeth.co.uk']);
export async function POST(request: NextRequest) {
  const cookie = readGmailToken(request);
  if (!cookie) return NextResponse.json({ error: 'Connect Gmail before sending.' }, { status: 401 });
  const input = await request.json() as { to?: string; subject?: string; body?: string; from?: string; threadId?: string; inReplyTo?: string; references?: string; brandId?: string; isFollowUp?: boolean };
  if (!input.to || !input.subject || !input.body || !input.from) return NextResponse.json({ error: 'Recipient, sender, subject and body are required.' }, { status: 400 });
  const emailPattern = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
  if (!emailPattern.test(input.to) || !emailPattern.test(input.from) || !ALLOWED_SENDERS.has(input.from.toLowerCase()) || /[\r\n]/.test([input.to,input.from,input.subject,input.inReplyTo,input.references].filter(Boolean).join(''))) return NextResponse.json({ error: 'Enter valid, authorised email headers.' }, { status: 400 });
  if (input.subject.length > 200 || input.body.length > 100_000) return NextResponse.json({ error: 'The subject or email body is too long.' }, { status: 413 });
  try {
    const { response: profileResponse, tokens: verifiedTokens } = await gmailRequest('profile', decryptTokenSet(cookie));
    const profile = await profileResponse.json() as { emailAddress?: string };
    if ((profile.emailAddress ?? '').toLowerCase() !== GMAIL_CONNECTION_EMAIL) {
      return NextResponse.json({ error: `LeadRally is connected to ${profile.emailAddress || 'a different Google account'}. Reconnect Gmail with ${GMAIL_CONNECTION_EMAIL}.` }, { status: 409 });
    }
    const plainBody = decodeHtmlEntities(input.body);
    const html = input.brandId === 'bryant-digital' ? digitalOutreachHtml(plainBody, input.isFollowUp)
      : input.brandId === 'bryant-cleaning' ? cleaningOutreachHtml(plainBody, input.isFollowUp)
      : input.brandId === 'bryant-construction' ? constructionOutreachHtml(plainBody, input.isFollowUp)
      : input.brandId === 'mr-white-teeth' ? teethWhiteningOutreachHtml(plainBody, input.isFollowUp)
      : undefined;
    const message = { from: input.from, to: input.to, subject: decodeHtmlEntities(input.subject.trim()), body: plainBody, ...(input.threadId ? { threadId: input.threadId } : {}), ...(input.inReplyTo ? { inReplyTo: input.inReplyTo } : {}), ...(input.references ? { references: input.references } : {}), ...(html ? { html } : {}) };
    const { response, tokens } = await gmailRequest('messages/send', verifiedTokens, { method: 'POST', headers: { 'content-type': 'application/json' }, body: JSON.stringify({ raw: encodeRawMessage(message), ...(input.threadId ? { threadId: input.threadId } : {}) }) });
    return persistGmailTokens(NextResponse.json(await response.json()), request, tokens);
  } catch (error) { return NextResponse.json({ error: error instanceof Error ? error.message : 'Gmail send failed.' }, { status: 502 }); }
}
