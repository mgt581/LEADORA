import { CLIENT_CONTACT_PHONE } from './outreach-workflows';

export const PROPOSAL_TEMPLATE_VERSION = 3;

export type Proposal = {
  subject: string;
  body: string;
  callToAction: string;
};

function clean(value: string) {
  return value.replace(/\s+/g, ' ').trim();
}

function serviceLink(companyId: string) {
  return {
    'bryant-digital': 'https://bryantdigitalsolutions.com',
    'bryant-cleaning': 'https://www.bryantandcocleaning.co.uk',
    'bryant-construction': 'https://bryantconstructiongroup.co.uk',
    'mr-white-teeth': 'https://teethwhiteningbournemouth.co.uk',
  }[companyId] ?? 'https://leadrally.co.uk';
}

function signature(companyName: string) {
  return `Alex Bryant
${companyName}
${CLIENT_CONTACT_PHONE}`;
}

export function proposalFor(
  companyId: string,
  name: string,
  businessType = 'local business',
  place = 'Dorset',
  options: { finding?: string; website?: string; companyName?: string } = {},
): Proposal {
  const business = clean(name) || 'your business';
  const category = clean(businessType).toLowerCase() || 'local business';
  const location = clean(place) || 'Dorset';
  const companyName = options.companyName ?? ({
    'bryant-digital': 'Bryant Digital Solutions',
    'bryant-cleaning': 'Bryant & Co Cleaning',
    'bryant-construction': 'Bryant Construction Group',
    'mr-white-teeth': 'Mr White Teeth Whitening',
  }[companyId] ?? 'Bryant Group');
  const link = serviceLink(companyId);

  if (companyId === 'bryant-digital') {
    const finding = options.finding
      ? clean(options.finding).replace(/[.]+$/, '')
      : 'there may be a few straightforward opportunities to improve visibility and enquiries';
    return {
      subject: `A practical website idea for ${business}`,
      body: `Hi ${business} team,

I was reviewing local businesses in ${location} and came across ${business}. I noticed ${finding.toLowerCase()}.

I run ${companyName}. I can send over a short, no-obligation website and SEO review with the specific actions I would prioritise — no hard sell and no long contract.

If that would be useful, reply “audit” and I’ll send it across. If someone else looks after the website, I’m happy to speak with them instead.

Kind regards,

${signature(companyName)}

${link}`,
      callToAction: 'Would you like me to send the short audit over?',
    };
  }

  if (companyId === 'bryant-cleaning') {
    return {
      subject: `Cleaning cover for ${business}`,
      body: `Hi ${business} team,

I’m contacting a small number of ${category} businesses in ${location} because reliable cleaning cover can be difficult to arrange around opening hours.

${companyName} provides dependable commercial cleaning with clear, tailored quotations rather than a one-size-fits-all package. I’m not assuming you need a new cleaner — I wanted to offer a sensible alternative if you are reviewing cover, have a gap in the rota, or need a backup team.

Would it be useful if I sent a short outline and indicative quotation?

Kind regards,

${signature(companyName)}

${link}`,
      callToAction: 'Would an indicative quotation be useful?',
    };
  }

  if (companyId === 'bryant-construction') {
    return {
      subject: `Property maintenance support for ${business}`,
      body: `Hi ${business} team,

I’m getting in touch because ${category} businesses and property teams in ${location} often need a reliable contractor for repairs, maintenance and small refurbishment work.

${companyName} provides clear, itemised quotations before work starts, covering practical jobs such as repairs, alterations and property refreshes. There’s no assumption that you have an active project — if something is coming up, I’d be glad to price it properly.

Would it be helpful to have our details on file for future work?

Kind regards,

${signature(companyName)}

${link}`,
      callToAction: 'Would it be helpful to keep our details on file?',
    };
  }

  return {
    subject: `A simple local referral idea for ${business}`,
    body: `Hi ${business} team,

I run ${companyName} in Bournemouth and I’m contacting a small number of complementary local businesses about straightforward referral partnerships.

Your ${category} business looks like it could be a natural fit for clients who ask about professional teeth whitening. I’m not suggesting anything complicated: just a conversation about whether a referral or cross-promotion arrangement would genuinely benefit both businesses.

Would you be open to a quick, no-obligation chat?

Kind regards,

${signature(companyName)}

${link}`,
    callToAction: 'Would you be open to a quick partnership chat?',
  };
}
