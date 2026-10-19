import test from 'node:test';
import assert from 'node:assert/strict';
import { proposalFor, PROPOSAL_TEMPLATE_VERSION } from './proposal-copy';

test('digital proposal uses a supplied audit finding and avoids invented local claims', () => {
  const proposal = proposalFor('bryant-digital', 'Acme Studio', 'local business', 'Dorset', {
    finding: 'The homepage does not include a meta description.',
  });
  assert.equal(PROPOSAL_TEMPLATE_VERSION, 4);
  assert.match(proposal.subject, /Acme Studio/);
  assert.match(proposal.body, /does not include a meta description/i);
  assert.doesNotMatch(proposal.body, /local businesses|small number|Hi Acme Studio team/i);
  assert.match(proposal.body, /Alex Bryant/);
});

test('business proposals use readable categories and verifiable discovery context', () => {
  const proposal = proposalFor('bryant-construction', 'Harbour Homes', 'estate_agent', 'Poole');
  assert.match(proposal.body, /listed as an estate agent in Poole/);
  assert.match(proposal.body, /public business listing/i);
  assert.doesNotMatch(proposal.body, /often need|active project/i);
});

test('all proposal bodies use a neutral professional greeting', () => {
  for (const companyId of ['bryant-digital', 'bryant-cleaning', 'bryant-construction', 'mr-white-teeth']) {
    const proposal = proposalFor(companyId, 'Example Business', 'Local business', 'Bournemouth');
    assert.ok(proposal.body.startsWith('Hello,\n'));
    assert.ok(proposal.body.includes('Kind regards'));
    assert.ok(proposal.subject.length <= 100);
  }
});
