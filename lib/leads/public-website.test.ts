import test from 'node:test';
import assert from 'node:assert/strict';
import { inspectPublicWebsite } from './public-website';

test('SEO audit recognises a well-formed Happy Birthday landing page', () => {
  const page = `<!doctype html><html lang="en-GB"><head><title>Happy Birthday Wishes and Cards | Example</title><meta name="description" content="Find thoughtful happy birthday wishes, messages and cards for friends and family."><meta name="viewport" content="width=device-width, initial-scale=1"></head><body><h1>Happy Birthday Wishes</h1><img src="card.jpg" alt="A birthday card with balloons"><a href="mailto:hello@example.co.uk">Contact</a></body></html>`;
  const audit = inspectPublicWebsite(page, 'https://example.co.uk');
  assert.equal(audit.title, 'Happy Birthday Wishes and Cards | Example');
  assert.match(audit.description, /happy birthday wishes/i);
  assert.deepEqual(audit.h1Tags, ['Happy Birthday Wishes']);
  assert.equal(audit.basicSeoScore, 100);
  assert.equal(audit.overallScore, 94);
  assert.deepEqual(audit.notes, []);
});
