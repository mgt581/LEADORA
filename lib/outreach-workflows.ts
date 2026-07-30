/** The permanent company contact number shown to clients in all outreach communications. */
export const CLIENT_CONTACT_PHONE = '07843 969254';

export type WorkflowType = 'website-audit' | 'dorset-prospecting';

export type OutreachWorkflowConfig = {
  companyId: string;
  companyName: string;
  buttonText: string;
  workflowType: WorkflowType;
  inputFields: Array<{ id: 'website'; label: string; placeholder: string }>;
  leadSource: string;
  proposalTemplate: 'digital-audit' | 'cleaning' | 'construction' | 'partnership';
  websiteAuditEnabled: boolean;
  title: string;
  description: string;
  steps: string[];
  prospectCategories: string[];
  recommendedService: string;
};

/** The sole source of truth for company-specific outreach behaviour. */
export const OUTREACH_WORKFLOWS: Record<string, OutreachWorkflowConfig> = {
  'bryant-digital': {
    companyId: 'bryant-digital',
    companyName: 'Bryant Digital Solutions',
    buttonText: 'Analyse Website',
    workflowType: 'website-audit',
    inputFields: [{ id: 'website', label: 'Prospect website', placeholder: 'https://example.co.uk' }],
    leadSource: 'Public business website',
    proposalTemplate: 'digital-audit',
    websiteAuditEnabled: true,
    title: 'Bryant Digital Solutions Outreach',
    description: 'Public website → audit → evidence-based proposal → your approval → Gmail.',
    steps: ['Enter website', 'Analyse website', 'Extract public contact email', 'Generate evidence-based proposal', 'Add to approval queue'],
    prospectCategories: [],
    recommendedService: 'Website and digital growth',
  },
  'bryant-cleaning': {
    companyId: 'bryant-cleaning', companyName: 'Bryant & Co Cleaning', buttonText: 'Find up to 10 Dorset Prospects',
    workflowType: 'dorset-prospecting', inputFields: [], leadSource: 'OpenStreetMap public Dorset business listings',
    proposalTemplate: 'cleaning', websiteAuditEnabled: false, title: 'Bryant & Co Cleaning Outreach',
    description: 'Public Dorset listings → cleaning proposal → your approval → Gmail.',
    steps: ['Find suitable commercial cleaning prospects in Dorset', 'Generate cleaning proposal', 'Add to approval queue'],
    prospectCategories: ['office', 'hotel', 'restaurant', 'pub', 'school', 'clinic', 'commercial', 'gym', 'warehouse', 'retail'], recommendedService: 'Commercial cleaning',
  },
  'bryant-construction': {
    companyId: 'bryant-construction', companyName: 'Bryant Construction Group', buttonText: 'Find up to 10 Dorset Prospects',
    workflowType: 'dorset-prospecting', inputFields: [], leadSource: 'OpenStreetMap public Dorset property and business listings',
    proposalTemplate: 'construction', websiteAuditEnabled: false, title: 'Bryant Construction Group Outreach',
    description: 'Dorset property prospects → construction proposal → your approval → Gmail.',
    steps: ['Find suitable Dorset construction prospects', 'Property developers', 'Estate agents', 'Commercial premises', 'Landlords', 'Refurbishment opportunities', 'Generate construction proposal', 'Add to approval queue'],
    prospectCategories: ['estate_agent', 'estate agent', 'property', 'developer', 'letting_agent', 'letting agent', 'commercial', 'real_estate', 'real estate', 'architect', 'builder', 'construction'], recommendedService: 'Construction and refurbishment',
  },
  'mr-white-teeth': {
    companyId: 'mr-white-teeth', companyName: 'Mr White Teeth Whitening', buttonText: 'Find up to 10 Dorset Prospects',
    workflowType: 'dorset-prospecting', inputFields: [], leadSource: 'OpenStreetMap public Dorset beauty and wedding business listings',
    proposalTemplate: 'partnership', websiteAuditEnabled: false, title: 'Mr White Teeth Whitening Outreach',
    description: 'Dorset partnership prospects → partnership proposal → your approval → Gmail.',
    steps: ['Find suitable Dorset partnership prospects', 'Beauty salons', 'Hair salons', 'Barbers', 'Wedding suppliers', 'Partnership opportunities', 'Generate partnership proposal', 'Add to approval queue'],
    prospectCategories: ['beauty', 'hairdresser', 'hair', 'barber', 'wedding', 'bridal', 'salon', 'nail', 'spa', 'beautician', 'cosmetics'], recommendedService: 'Teeth-whitening partnership',
  },
};

export function getOutreachWorkflow(companyId: string) {
  return OUTREACH_WORKFLOWS[companyId];
}
