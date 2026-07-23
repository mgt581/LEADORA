import assert from 'node:assert/strict';
import test from 'node:test';
import { businessEmailFromHeaders, encodeRawMessage, oauthStateMatches, parseGmailMessage } from './gmail';

test('validates OAuth state with constant-time comparison', () => {
  assert.equal(oauthStateMatches('state', 'state'), true);
  assert.equal(oauthStateMatches('state', 'other'), false);
  assert.equal(oauthStateMatches('state', undefined), false);
});

test('matches a forwarded business using all relevant headers', () => {
  const headers = [{ name: 'Delivered-To', value: 'info@bryantandcocleaning.co.uk' }];
  assert.equal(businessEmailFromHeaders(headers, { cleaning: ['info@bryantandcocleaning.co.uk'] }), 'cleaning');
  assert.equal(businessEmailFromHeaders(headers, { construction: ['info@bryantconstruct.com'] }), null);
});

test('parses message headers and safe attachment metadata', () => {
  const message = parseGmailMessage({
    id: 'm1', threadId: 't1', internalDate: '1710000000000', labelIds: ['INBOX'],
    payload: { headers: [{ name: 'Subject', value: 'Hello' }, { name: 'From', value: 'a@example.com' }], parts: [
      { mimeType: 'text/plain', body: { data: Buffer.from('Reply').toString('base64url') } },
      { filename: 'quote.pdf', mimeType: 'application/pdf', body: { attachmentId: 'a1', size: 42 } },
    ] },
  });
  assert.equal(message.subject, 'Hello');
  assert.equal(message.body, 'Reply');
  assert.deepEqual(message.attachments, [{ id: 'a1', filename: 'quote.pdf', mimeType: 'application/pdf', size: 42 }]);
});

test('preserves threading headers in encoded replies', () => {
  const raw = Buffer.from(encodeRawMessage({ from: 'me@example.com', to: 'them@example.com', subject: 'Re: Hello', body: 'Thanks', inReplyTo: '<m1>', references: '<m1>' }), 'base64url').toString();
  assert.match(raw, /In-Reply-To: <m1>/);
  assert.match(raw, /References: <m1>/);
});
