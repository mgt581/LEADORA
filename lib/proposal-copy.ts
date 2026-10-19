import { CLIENT_CONTACT_PHONE } from './outreach-workflows';

export const PROPOSAL_TEMPLATE_VERSION = 4;

export type Proposal = {
  subject: string;
  body: string;
  callToAction: string;
};

function clean(value: string) {
  return value.replace(/\s+/g, ' ').trim();
}

function readableCategory(value: string) {
  return clean(value).replace(/[_-]+/g, ' ').replace(/\b\p{L}/gu, letter => letter.toUpperCase()) || 'local business';
}

function serviceLink(companyId: string) {
  return {
    'bryant-digital': 'https://bryantdigitalsolutions.co.uk',
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
  const category = readableCategory(businessType);
  const categoryArticle = /^[aeiou]/i.test(category) ? 'an' : 'a';
  const location = clean(place) || 'Dorset';
  const companyName = options.companyName ?? ({
    'bryant-digital': 'Bryant Digital Solutions',
    'bryant-cleaning': 'Bryant & Co Cleaning',
    'bryant-construction': 'Bryant Construction Group',
    'mr-white-teeth': 'Mr White Teeth Whitening',
  }[companyId] ?? 'Bryant Group');
  const link = serviceLink(companyId);

  if (companyId === 'bryant-digital') {
    const finding = options.finding ? clean(options.finding).replace(/[.]+$/, '') : '';
    return {
      subject: `Website review for ${business}`,
      body: `Hello,

I’ve reviewed ${business}’s website${finding ? ` and noticed ${finding.charAt(0).toLowerCase()}${finding.slice(1)}` : ''}.

I’m Alex at ${companyName}. I can send a short, no-obligation review with practical improvements for your site’s search visibility and enquiry journey.

Would you like me to send it over?

Kind regards,

${signature(companyName)}

${link}`,
      callToAction: 'Would you like me to send the short audit over?',
    };
  }

  if (companyId === 'bryant-cleaning') {
    return {
      subject: `Cleaning support for ${business}`,
      body: `Hello,

I found ${business}, listed as ${categoryArticle} ${category.toLowerCase()} in ${location} in a public business listing. I’m Alex at ${companyName}.

We provide commercial cleaning with plans and quotes tailored to each site. If you are reviewing your current arrangements or need additional cover, I’d be happy to prepare a no-obligation quote.

Would that be useful?

Kind regards,

${signature(companyName)}

${link}`,
      callToAction: 'Would an indicative quotation be useful?',
    };
  }

  if (companyId === 'bryant-construction') {
    return {
      subject: `A contractor contact for ${business}`,
      body: `Hello,

I found ${business}, listed as ${categoryArticle} ${category.toLowerCase()} in ${location} in a public business listing. I’m Alex at ${companyName}.

We provide construction and refurbishment work, with clear, itemised quotes agreed before work starts. If a repair or project comes up, I’d be glad to discuss the scope and price it for you.

Would you like me to send our details for your supplier records?

Kind regards,

${signature(companyName)}

${link}`,
      callToAction: 'Would it be helpful to keep our details on file?',
    };
  }

  return {
    subject: `Local referral partnership idea`,
    body: `Hello,

I’m Alex at ${companyName} in Bournemouth. I found ${business}, listed as ${categoryArticle} ${category.toLowerCase()} in ${location} in a public business listing.

We offer professional teeth whitening and are exploring simple referral partnerships with complementary local businesses. Any arrangement would be discussed first and would only go ahead if it suited both sides.

Would you be open to a brief conversation?

Kind regards,

${signature(companyName)}

${link}`,
    callToAction: 'Would you be open to a quick partnership chat?',
  };
}
