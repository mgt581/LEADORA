import test from 'node:test';
import assert from 'node:assert/strict';
import { isKnownLead, normaliseLeadWebsite } from './identity';

test('website identity ignores protocol, www, path, and trailing slash', () => {
  assert.equal(normaliseLeadWebsite('https://www.Example.co.uk/contact/'), 'example.co.uk');
  assert.equal(normaliseLeadWebsite('example.co.uk'), 'example.co.uk');
});

test('lead identity catches reused email, website, and equivalent business names', () => {
  const known = [{ email: 'Info@Example.co.uk', website: 'https://www.example.co.uk/', name: 'Smith & Sons' }];
  assert.equal(isKnownLead({ email: ' info@example.co.uk ' }, known), true);
  assert.equal(isKnownLead({ name: 'Smith and Sons' }, known), true);
  assert.equal(isKnownLead({ name: 'Different business', website: 'https://example.co.uk/new' }, known), true);
  assert.equal(isKnownLead({ name: 'Different business', website: 'other.co.uk' }, known), false);
});
