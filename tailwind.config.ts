import type { Config } from 'tailwindcss';

const config: Config = {
  content: ['./app/**/*.{ts,tsx}', './components/**/*.{ts,tsx}'],
  theme: {
    extend: {
      colors: {
        sidebar: '#0B1220',
        gold: '#C9A84C',
        canvas: '#F5F5F7',
        ink: '#171A21',
      },
      boxShadow: { card: '0 2px 10px rgba(15,23,42,.06)' },
      borderRadius: { xl: '12px' },
    },
  },
  plugins: [],
};

export default config;
