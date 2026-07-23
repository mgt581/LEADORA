# LEADORA

AI-powered sales operating system for lead generation, outreach, CRM, automations and business growth.

## Overview

Leadora is a premium AI SaaS web application built with Flutter Web. It delivers an enterprise-grade dashboard experience inspired by Linear, Stripe, Notion, and Vercel — with a distinctive dark sidebar, gold accent colour, and clean white content panels.

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

## Architecture

Clean Architecture with feature-based folder structure:

```
lib/
├── main.dart
├── core/
│   ├── constants/          # Colors, typography, spacing
│   ├── router/             # GoRouter configuration
│   ├── theme/              # Material 3 theme
│   └── widgets/            # Shared widgets (sidebar, topbar, cards)
└── features/
    ├── dashboard/
    ├── leads/
    ├── contacts/
    ├── companies/
    ├── deals/
    ├── pipelines/
    ├── email_outreach/
    ├── website_audits/
    ├── ai_agents/
    ├── automations/
    ├── analytics/
    ├── reports/
    └── settings/
```

## Getting Started

### Deployment

LEADORA must run on a serverless host such as Vercel because the Gmail OAuth
routes exchange and encrypt tokens on the server. GitHub Pages is static-only
and cannot run these routes. Configure `VERCEL_TOKEN`, `VERCEL_ORG_ID`, and
`VERCEL_PROJECT_ID` as GitHub Actions secrets, then add the variables in
`.env.example` to the Vercel project. Set the Google redirect URI to
`https://<your-domain>/api/gmail/callback`.

### Prerequisites

- Flutter SDK ≥ 3.24.0
- Dart SDK ≥ 3.3.0

### Run the app

```bash
flutter pub get
flutter run -d chrome
```

### Build for web

```bash
flutter build web --release
```

## Key Dependencies

| Package | Purpose |
|---------|---------|
| `go_router` | Declarative URL-based routing |
| `fl_chart` | Charts (line, bar, pie) |
| `google_fonts` | Inter typeface |
| `provider` | State management |
| `intl` | Internationalisation |

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
