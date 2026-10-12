export type CloudflareProjectConfig = {
  id: string;
  name: string;
  description: string;
  publicUrl: string;
  dashboardUrl: string;
  access: 'leadrally' | 'cloudflare-access' | 'app-login' | 'cloudflare-console' | 'public';
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
    dashboardUrl: '/dashboard/',
    access: 'leadrally',
    cloudflareKind: 'worker',
    cloudflareName: 'leadora',
    database: { name: 'leadora-production', id: 'ab675c7e-e9e2-4253-9281-7db496792337' },
  },
  {
    id: 'digital',
    name: 'Bryant Digital Solutions',
    description: 'Digital services website and lead database',
    publicUrl: 'https://bryantdigitalsolutions.co.uk',
    dashboardUrl: 'https://bds-site.pages.dev/dashboard',
    access: 'cloudflare-access',
    cloudflareKind: 'pages',
    cloudflareName: 'bds-site',
    database: { name: 'bryant-digital-solutions-leads', id: 'fc8164ba-2aad-4bea-bb7c-3b1a61aa5bd7' },
  },
  {
    id: 'multipost',
    name: 'MultiPost App',
    description: 'Social publishing application and analytics database',
    publicUrl: 'https://multipostapp.co.uk',
    dashboardUrl: 'https://feat-private-admin-analytics.multipost-private-admin.pages.dev/',
    access: 'cloudflare-access',
    cloudflareKind: 'pages',
    cloudflareName: 'multi-post-dashboard',
    database: { name: 'accountsmultipostapp', id: '19dfae46-a6cb-4e88-ab7c-2ab2fea3279a' },
  },
  {
    id: 'construction',
    name: 'Bryant Construction Group',
    description: 'Construction website and lead database',
    publicUrl: 'https://bryantconstructiongroup.co.uk',
    dashboardUrl: 'https://bryantconstructiongroup.co.uk/dashboard.html',
    access: 'cloudflare-access',
    cloudflareKind: 'external',
    database: { name: 'bryant-construction-leads', id: 'f969696f-5c93-43ff-929b-74c16e0c459d' },
  },
  {
    id: 'cleaning',
    name: 'Bryant & Co Cleaning',
    description: 'Cleaning website, leads and bookings',
    publicUrl: 'https://bryantandcocleaning.co.uk',
    dashboardUrl: 'https://bryantandcocleaning.co.uk/dashboard',
    access: 'cloudflare-access',
    cloudflareKind: 'pages',
    cloudflareName: 'bryantandco-cleaning',
    database: { name: 'bryant-cleaning-leads', id: '87575044-f7eb-4fdb-93c4-cec0795c3045' },
  },
  {
    id: 'mr-white',
    name: 'Mr White Teeth Whitening',
    description: 'Booking website and lead database',
    publicUrl: 'https://teethwhiteningbournemouth.co.uk',
    dashboardUrl: 'https://teethwhiteningbournemouth.co.uk/dashboard',
    access: 'cloudflare-access',
    cloudflareKind: 'pages',
    cloudflareName: 'mr-white-website',
    database: { name: 'mr-white-leads', id: '7ed68e17-444a-42a1-b94d-ced72d47c718' },
  },
  {
    id: 'holdings',
    name: 'Bryant Holdings',
    description: 'Group website and central lead database',
    publicUrl: 'https://bryantgroupholdings.co.uk',
    dashboardUrl: 'https://preview-lead-generation-dash.bryantholdings-com.pages.dev/dashboard',
    access: 'cloudflare-access',
    cloudflareKind: 'pages',
    cloudflareName: 'bryantholdings-com',
    database: { name: 'bryant-holdings-leads', id: '40a2a052-2635-4fb1-8380-509ef1206210' },
  },
  {
    id: 'casa4',
    name: 'Casa4 Developments',
    description: 'Property development website and lead database',
    publicUrl: 'https://casa4developments.co.uk',
    dashboardUrl: 'https://5af99dfc.casa4dev.pages.dev/dashboard',
    access: 'cloudflare-access',
    cloudflareKind: 'pages',
    cloudflareName: 'casa4dev',
    database: { name: 'casa4dev-leads', id: '95feab18-a3e8-4cfb-96b0-dc3eb554186c' },
  },
];

export function cloudflareDashboardUrl(project: CloudflareProjectConfig) {
  const root = `https://dash.cloudflare.com/${CLOUDFLARE_ACCOUNT_ID}`;
  if (project.cloudflareKind === 'pages' && project.cloudflareName) return `${root}/pages/view/${project.cloudflareName}`;
  if (project.cloudflareKind === 'worker' && project.cloudflareName) return `${root}/workers/services/view/${project.cloudflareName}/production`;
  if (project.database) return `${root}/workers/d1/databases/${project.database.id}`;
  return `${root}/workers-and-pages`;
}

