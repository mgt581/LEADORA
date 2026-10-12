export type CloudflareProjectConfig = {
  id: string;
  name: string;
  description: string;
  publicUrl: string;
  cloudflareKind: 'worker' | 'pages' | 'external';
  cloudflareName?: string;
  database?: { name: string; id: string };
};

export const CLOUDFLARE_ACCOUNT_ID = 'b1173369c5dee97d46e465be28702897';

export const CLOUDFLARE_PROJECTS: CloudflareProjectConfig[] = [
  {
    id: 'leadrally',
    name: 'LeadRally',
    description: 'CRM, outreach, Gmail and reporting workspace',
    publicUrl: 'https://www.leadrally.co.uk',
    cloudflareKind: 'worker',
    cloudflareName: 'leadora',
    database: { name: 'leadora-production', id: 'ab675c7e-e9e2-4253-9281-7db496792337' },
  },
  {
    id: 'construction',
    name: 'Bryant Construction Group',
    description: 'Construction website and lead database',
    publicUrl: 'https://bryantconstructiongroup.co.uk',
    cloudflareKind: 'external',
    database: { name: 'bryant-construction-leads', id: 'f969696f-5c93-43ff-929b-74c16e0c459d' },
  },
  {
    id: 'cleaning',
    name: 'Bryant & Co Cleaning',
    description: 'Cleaning website, leads and bookings',
    publicUrl: 'https://www.bryantandcocleaning.co.uk',
    cloudflareKind: 'pages',
    cloudflareName: 'bryantandco-cleaning',
    database: { name: 'bryant-cleaning-leads', id: '87575044-f7eb-4fdb-93c4-cec0795c3045' },
  },
  {
    id: 'digital',
    name: 'Bryant Digital Solutions',
    description: 'Digital services website and lead database',
    publicUrl: 'https://bryantdigitalsolutions.com',
    cloudflareKind: 'pages',
    cloudflareName: 'bds-site',
    database: { name: 'bryant-digital-solutions-leads', id: 'fc8164ba-2aad-4bea-bb7c-3b1a61aa5bd7' },
  },
  {
    id: 'mr-white',
    name: 'Mr White Teeth Whitening',
    description: 'Booking website and lead database',
    publicUrl: 'https://teethwhiteningbournemouth.co.uk',
    cloudflareKind: 'pages',
    cloudflareName: 'mr-white-website',
    database: { name: 'mr-white-leads', id: '7ed68e17-444a-42a1-b94d-ced72d47c718' },
  },
  {
    id: 'holdings',
    name: 'Bryant Holdings',
    description: 'Group website and central lead database',
    publicUrl: 'https://bryantholdings-com.pages.dev',
    cloudflareKind: 'pages',
    cloudflareName: 'bryantholdings-com',
    database: { name: 'bryant-holdings-leads', id: '40a2a052-2635-4fb1-8380-509ef1206210' },
  },
];

export function cloudflareDashboardUrl(project: CloudflareProjectConfig) {
  const root = `https://dash.cloudflare.com/${CLOUDFLARE_ACCOUNT_ID}`;
  if (project.cloudflareKind === 'pages' && project.cloudflareName) return `${root}/pages/view/${project.cloudflareName}`;
  if (project.cloudflareKind === 'worker' && project.cloudflareName) return `${root}/workers/services/view/${project.cloudflareName}/production`;
  if (project.database) return `${root}/workers/d1/databases/${project.database.id}`;
  return `${root}/workers-and-pages`;
}

