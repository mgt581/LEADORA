import type { MetadataRoute } from 'next';
import { LEADRALLY_BRAND } from '@/lib/brand';

export default function manifest(): MetadataRoute.Manifest {
  return {
    name: `${LEADRALLY_BRAND.name} — ${LEADRALLY_BRAND.tagline}`,
    short_name: LEADRALLY_BRAND.name,
    description: LEADRALLY_BRAND.description,
    start_url: '/',
    display: 'standalone',
    background_color: '#071425',
    theme_color: '#071425',
    icons: [
      {
        src: LEADRALLY_BRAND.logoPath,
        sizes: '512x512',
        type: 'image/png',
        purpose: 'any',
      },
    ],
  };
}
