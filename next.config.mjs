/** @type {import('next').NextConfig} */
const isPages = process.env.DEPLOYMENT_TARGET === 'pages';

const nextConfig = {
  ...(isPages ? { output: 'export' } : {}),
  trailingSlash: true,
  images: { unoptimized: true },
  basePath: isPages ? '/LEADORA' : '',
  assetPrefix: isPages ? '/LEADORA/' : undefined,
};

export default nextConfig;
