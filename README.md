# LeadRally

AI-powered sales operating system for lead generation, outreach, CRM, automations and business growth.

## Overview

LeadRally is a Next.js SaaS application deployed to a Cloudflare Worker. It finds public business prospects, prepares evidence-based outreach for manual approval, sends approved messages through Gmail and records activity in Cloudflare D1.

## Design System

| Token | Value |
|-------|-------|
| Sidebar Background | `#0F0F0F` |
| Gold Accent | `#C9A84C` |
| Content Background | `#F5F5F7` |
| Card Background | `#FFFFFF` |
| Primary Font | Inter (Google Fonts) |
| Card Radius | 12px |
| Shadow | Soft, `0 2px 8px rgba(0,0,0,0.04)` |

## Pages

| Page | Route |
|------|-------|
| Dashboard | `/` |
| Leads | `/leads` |
| Contacts | `/contacts` |
| Companies | `/companies` |
| Deals | `/deals` |
| Pipelines | `/pipelines` |
| Email Outreach | `/email-outreach` |
| Website Audits | `/website-audits` |
| AI Agents | `/ai-agents` |
| Automations | `/automations` |
| Analytics | `/analytics` |
| Reports | `/reports` |
| Settings | `/settings` |

## Production architecture

- Next.js application and API routes
- Cloudflare Worker deployment through OpenNext
- Cloudflare D1 for durable CRM and outreach state
- Gmail OAuth for approved-message sending and reply synchronisation
- Custom production domains: `leadrally.co.uk` and `www.leadrally.co.uk`

## Getting Started

### Deployment

LeadRally runs on Cloudflare because the Gmail OAuth and prospect-discovery
routes require a server runtime. GitHub Pages cannot run these routes. The
production Google OAuth redirect URI is
`https://leadrally.co.uk/api/gmail/callback`.

### Prerequisites

- Node.js 22
- npm
- Cloudflare Wrangler authentication for deployment

### Run the app

`npm install` then `npm run dev`.

### Build for web

Use `npm run build` for Next.js validation or `npm run cf:deploy` for a direct Cloudflare build and deployment.

## Features

- **Dashboard** — KPI stats, leads overview chart, recent activity, pipeline funnel, tasks
- **Leads** — Filterable lead table with status badges
- **Contacts** — Full contact directory
- **Companies** — Company accounts with revenue data
- **Deals** — Deal pipeline with probability bars
- **Pipelines** — Kanban board view
- **Email Outreach** — Campaign management and metrics
- **Website Audits** — SEO/performance scores
- **AI Agents** — Autonomous sales agents with toggle controls
- **Automations** — Workflow automations with progress bars
- **Analytics** — Charts, funnels, channel performance
- **Reports** — Revenue trends, sales rep leaderboard
- **Settings** — Profile, security (2FA, sessions), billing
