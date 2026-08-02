import type { Metadata } from 'next';
import './globals.css';
import { Providers } from '@/components/providers';
import { LEADRALLY_BRAND } from '@/lib/brand';

export const metadata: Metadata = {
  metadataBase: new URL(LEADRALLY_BRAND.url),
  title: `${LEADRALLY_BRAND.name} — ${LEADRALLY_BRAND.tagline}`,
  description: LEADRALLY_BRAND.description,
  applicationName: LEADRALLY_BRAND.name,
  icons: {
    icon: LEADRALLY_BRAND.logoPath,
    apple: LEADRALLY_BRAND.logoPath,
  },
};

export default function RootLayout({ children }: Readonly<{ children: React.ReactNode }>) {
  return (
    <html lang="en">
      <body><Providers>{children}</Providers></body>
    </html>
  );
}
