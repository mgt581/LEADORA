import assert from 'node:assert/strict';
import test from 'node:test';
import { cleaningOutreachHtml, constructionOutreachHtml, digitalOutreachHtml, teethWhiteningOutreachHtml } from './email-templates';

const cases = [
  [digitalOutreachHtml, 'bryant-digital.jpg', 'Bryant Digital Solutions'],
  [cleaningOutreachHtml, 'bryant-cleaning.png', 'Bryant and Co Cleaning'],
  [constructionOutreachHtml, 'bryant-construction.png', 'Bryant Construction Group'],
  [teethWhiteningOutreachHtml, 'mr-white.jpg', 'Mr White Teeth Whitening'],
] as const;

test('every branded email uses a LeadRally-hosted logo with useful alternative text', () => {
  for (const [render, filename, alt] of cases) {
    const html = render('Hello');
    assert.match(html, new RegExp(`src="https://www\\.leadrally\\.co\\.uk/branding/outreach/${filename.replace('.', '\\.')}"`));
    assert.match(html, new RegExp(`alt="${alt}"`));
  }
});
