import { NextRequest, NextResponse } from 'next/server';
import { businessEmailFromHeaders, decryptTokenSet, gmailRequest, parseGmailMessage, TOKEN_COOKIE } from '@/lib/server/gmail';

export const runtime = 'nodejs';

export async function POST(request: NextRequest) {
  const cookie = request.cookies.get(TOKEN_COOKIE)?.value;
  if (!cookie) return NextResponse.json({ error: 'Connect Gmail before synchronising.' }, { status: 401 });
  const input = await request.json().catch(() => ({})) as { historyId?: string; mappings?: Record<string, string[]> };
  try {
    const path = input.historyId
      ? `history?startHistoryId=${encodeURIComponent(input.historyId)}&historyTypes=messageAdded`
      : 'messages?maxResults=100&labelIds=INBOX';
    const { response } = await gmailRequest(path, decryptTokenSet(cookie));
    const listing = await response.json() as { messages?: Array<{ id: string }>; history?: Array<{ messagesAdded?: Array<{ message: { id: string } }> }>; historyId?: string };
    const ids = input.historyId
      ? (listing.history ?? []).flatMap(item => (item.messagesAdded ?? []).map(entry => entry.message.id))
      : (listing.messages ?? []).map(message => message.id);
    const messages = await Promise.all([...new Set(ids)].map(async (id) => {
      const result = await gmailRequest(`messages/${encodeURIComponent(id)}?format=full`, decryptTokenSet(cookie));
      const parsed = parseGmailMessage(await result.response.json());
      return { ...parsed, businessId: businessEmailFromHeaders(parsed.headers, input.mappings ?? {}) };
    }));
    return NextResponse.json({ messages, historyId: listing.historyId ?? input.historyId ?? null, synchronisedAt: new Date().toISOString() });
  } catch (error) {
    return NextResponse.json({ error: error instanceof Error ? error.message : 'Gmail synchronisation failed.' }, { status: 502 });
  }
}
