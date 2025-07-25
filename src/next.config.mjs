/** @type {import('next').NextConfig} */
const nextConfig = {
  reactStrictMode: true,
  // A linha 'swcMinify: true,' foi removida daqui.
  eslint: {
    ignoreDuringBuilds: true,
  },
  typescript: {
    ignoreBuildErrors: true,
  },
  images: {
    unoptimized: true,
  },
}

export default nextConfig