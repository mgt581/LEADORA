import { LeadoraApp } from '@/components/leadora-app';

const sections = [
  'login','dashboard','leads','contacts','companies','deals','pipelines',
  'email-outreach','outreach-history','website-audits','ai-agents','automations','analytics','reports','settings'
];

export function generateStaticParams() {
  return sections.map(section => ({ section }));
}

export default async function SectionPage({ params }: { params: Promise<{ section:string }> }) {
  const { section } = await params;
  return <LeadoraApp route={section} />;
}
