import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../features/dashboard/presentation/pages/dashboard_page.dart';
import '../../features/leads/presentation/pages/leads_page.dart';
import '../../features/contacts/presentation/pages/contacts_page.dart';
import '../../features/companies/presentation/pages/companies_page.dart';
import '../../features/deals/presentation/pages/deals_page.dart';
import '../../features/pipelines/presentation/pages/pipelines_page.dart';
import '../../features/email_outreach/presentation/pages/email_outreach_page.dart';
import '../../features/website_audits/presentation/pages/website_audits_page.dart';
import '../../features/ai_agents/presentation/pages/ai_agents_page.dart';
import '../../features/automations/presentation/pages/automations_page.dart';
import '../../features/analytics/presentation/pages/analytics_page.dart';
import '../../features/reports/presentation/pages/reports_page.dart';
import '../../features/settings/presentation/pages/settings_page.dart';
import '../widgets/sidebar/app_shell.dart';

class AppRouter {
  AppRouter._();

  static final GoRouter router = GoRouter(
    initialLocation: '/dashboard',
    routes: [
      ShellRoute(
        builder: (context, state, child) => AppShell(child: child),
        routes: [
          GoRoute(
            path: '/dashboard',
            pageBuilder: (context, state) => _fade(state, const DashboardPage()),
          ),
          GoRoute(
            path: '/leads',
            pageBuilder: (context, state) => _fade(state, const LeadsPage()),
          ),
          GoRoute(
            path: '/contacts',
            pageBuilder: (context, state) => _fade(state, const ContactsPage()),
          ),
          GoRoute(
            path: '/companies',
            pageBuilder: (context, state) => _fade(state, const CompaniesPage()),
          ),
          GoRoute(
            path: '/deals',
            pageBuilder: (context, state) => _fade(state, const DealsPage()),
          ),
          GoRoute(
            path: '/pipelines',
            pageBuilder: (context, state) => _fade(state, const PipelinesPage()),
          ),
          GoRoute(
            path: '/email-outreach',
            pageBuilder: (context, state) => _fade(state, const EmailOutreachPage()),
          ),
          GoRoute(
            path: '/website-audits',
            pageBuilder: (context, state) => _fade(state, const WebsiteAuditsPage()),
          ),
          GoRoute(
            path: '/ai-agents',
            pageBuilder: (context, state) => _fade(state, const AiAgentsPage()),
          ),
          GoRoute(
            path: '/automations',
            pageBuilder: (context, state) => _fade(state, const AutomationsPage()),
          ),
          GoRoute(
            path: '/analytics',
            pageBuilder: (context, state) => _fade(state, const AnalyticsPage()),
          ),
          GoRoute(
            path: '/reports',
            pageBuilder: (context, state) => _fade(state, const ReportsPage()),
          ),
          GoRoute(
            path: '/settings',
            pageBuilder: (context, state) => _fade(state, const SettingsPage()),
          ),
        ],
      ),
    ],
  );

  static CustomTransitionPage<void> _fade(
    GoRouterState state,
    Widget child,
  ) {
    return CustomTransitionPage<void>(
      key: state.pageKey,
      child: child,
      transitionDuration: const Duration(milliseconds: 180),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(
          opacity: CurveTween(curve: Curves.easeInOut).animate(animation),
          child: child,
        );
      },
    );
  }
}
