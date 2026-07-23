/** @type {import('next').NextConfig} */
const isGitHub = process.env.GITHUB_ACTIONS === 'true';

const nextConfig = {
  ...(isGitHub ? { output: 'export' } : {}),
  trailingSlash: true,
  images: { unoptimized: true },
  basePath: isGitHub ? '/LEADORA' : '',
  assetPrefix: isGitHub ? '/LEADORA/' : undefined,
};

export default nextConfig;
