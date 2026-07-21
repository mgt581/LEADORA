import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../theme/app_colors.dart';
import 'sidebar_item.dart';

class AppShell extends StatefulWidget {
  final Widget child;
  const AppShell({super.key, required this.child});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  bool _sidebarCollapsed = false;

  static const double _expandedWidth = 220;
  static const double _collapsedWidth = 64;

  static const List<_NavItem> _navItems = [
    _NavItem('Dashboard', Icons.grid_view_rounded, '/dashboard'),
    _NavItem('Leads', Icons.person_search_rounded, '/leads'),
    _NavItem('Contacts', Icons.contacts_rounded, '/contacts'),
    _NavItem('Companies', Icons.business_rounded, '/companies'),
    _NavItem('Deals', Icons.handshake_rounded, '/deals'),
    _NavItem('Pipelines', Icons.account_tree_rounded, '/pipelines'),
    _NavItem('Email Outreach', Icons.mark_email_read_rounded, '/email-outreach'),
    _NavItem('Website Audits', Icons.manage_search_rounded, '/website-audits'),
    _NavItem('AI Agents', Icons.smart_toy_rounded, '/ai-agents'),
    _NavItem('Automations', Icons.bolt_rounded, '/automations'),
    _NavItem('Analytics', Icons.bar_chart_rounded, '/analytics'),
    _NavItem('Reports', Icons.assessment_rounded, '/reports'),
    _NavItem('Settings', Icons.settings_rounded, '/settings'),
  ];

  @override
  Widget build(BuildContext context) {
    final isNarrow = MediaQuery.sizeOf(context).width < 900;

    if (isNarrow) {
      return _MobileScaffold(child: widget.child, navItems: _navItems);
    }

    final sidebarWidth = _sidebarCollapsed ? _collapsedWidth : _expandedWidth;

    return Scaffold(
      body: Row(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeInOut,
            width: sidebarWidth,
            child: _Sidebar(
              collapsed: _sidebarCollapsed,
              navItems: _navItems,
              onToggle: () => setState(() => _sidebarCollapsed = !_sidebarCollapsed),
            ),
          ),
          Expanded(
            child: Column(
              children: [
                _TopBar(sidebarCollapsed: _sidebarCollapsed),
                Expanded(child: widget.child),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Sidebar ────────────────────────────────────────────────────────────────

class _Sidebar extends StatelessWidget {
  final bool collapsed;
  final List<_NavItem> navItems;
  final VoidCallback onToggle;

  const _Sidebar({
    required this.collapsed,
    required this.navItems,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();

    return Container(
      color: AppColors.sidebarBg,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Logo area
          Container(
            height: 64,
            padding: EdgeInsets.symmetric(
              horizontal: collapsed ? 16 : 20,
            ),
            child: Row(
              children: [
                _LogoMark(),
                if (!collapsed) ...[
                  const SizedBox(width: 10),
                  const Text(
                    'LEADORA',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: AppColors.goldLight,
                      letterSpacing: 2,
                    ),
                  ),
                ],
                if (!collapsed) const Spacer(),
                if (!collapsed)
                  _CollapseButton(onTap: onToggle, collapsed: collapsed),
              ],
            ),
          ),

          Container(height: 1, color: AppColors.sidebarDivider),
          const SizedBox(height: 8),

          // Nav items
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              itemCount: navItems.length,
              itemBuilder: (context, i) {
                final item = navItems[i];
                // Add divider before Settings
                final addDivider = i == navItems.length - 1;
                return Column(
                  children: [
                    if (addDivider) ...[
                      const SizedBox(height: 4),
                      Container(height: 1, color: AppColors.sidebarDivider, margin: const EdgeInsets.symmetric(horizontal: 4)),
                      const SizedBox(height: 8),
                    ],
                    SidebarItem(
                      icon: item.icon,
                      label: item.label,
                      collapsed: collapsed,
                      isActive: location.startsWith(item.route),
                      onTap: () => context.go(item.route),
                    ),
                  ],
                );
              },
            ),
          ),

          // Collapsed toggle
          if (collapsed)
            Padding(
              padding: const EdgeInsets.all(8),
              child: _CollapseButton(onTap: onToggle, collapsed: collapsed),
            ),

          Container(height: 1, color: AppColors.sidebarDivider),

          // User avatar
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: collapsed ? 12 : 16,
              vertical: 12,
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 16,
                  backgroundColor: AppColors.gold.withValues(alpha: 0.2),
                  child: const Text(
                    'AB',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: AppColors.gold,
                    ),
                  ),
                ),
                if (!collapsed) ...[
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          'Alex Bryant',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          'Admin',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 11,
                            color: AppColors.sidebarText,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Logo mark ──────────────────────────────────────────────────────────────

class _LogoMark extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: AppColors.gold,
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Center(
        child: Text(
          'L',
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}

// ─── Collapse button ─────────────────────────────────────────────────────────

class _CollapseButton extends StatelessWidget {
  final VoidCallback onTap;
  final bool collapsed;
  const _CollapseButton({required this.onTap, required this.collapsed});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(6),
        ),
        child: Icon(
          collapsed ? Icons.chevron_right_rounded : Icons.chevron_left_rounded,
          size: 18,
          color: AppColors.sidebarText,
        ),
      ),
    );
  }
}

// ─── Top bar ─────────────────────────────────────────────────────────────────

class _TopBar extends StatelessWidget {
  final bool sidebarCollapsed;
  const _TopBar({required this.sidebarCollapsed});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 64,
      decoration: const BoxDecoration(
        color: AppColors.cardBg,
        border: Border(
          bottom: BorderSide(color: AppColors.cardBorder, width: 1),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: [
          // Search
          Expanded(
            child: Container(
              height: 36,
              constraints: const BoxConstraints(maxWidth: 440),
              decoration: BoxDecoration(
                color: AppColors.contentBg,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.cardBorder),
              ),
              child: Row(
                children: const [
                  SizedBox(width: 10),
                  Icon(Icons.search_rounded, size: 16, color: AppColors.textTertiary),
                  SizedBox(width: 8),
                  Text(
                    'Search everything...',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 13,
                      color: AppColors.textTertiary,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const Spacer(),

          // Actions
          Row(
            children: [
              _TopBarIconButton(icon: Icons.add_rounded, onTap: () {}),
              const SizedBox(width: 4),
              _TopBarIconButton(
                icon: Icons.notifications_none_rounded,
                onTap: () {},
                badge: '3',
              ),
              const SizedBox(width: 8),
              CircleAvatar(
                radius: 16,
                backgroundColor: AppColors.gold.withValues(alpha: 0.15),
                child: const Text(
                  'AB',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: AppColors.gold,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _TopBarIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final String? badge;

  const _TopBarIconButton({
    required this.icon,
    required this.onTap,
    this.badge,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8),
          child: Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 20, color: AppColors.textSecondary),
          ),
        ),
        if (badge != null)
          Positioned(
            top: 4,
            right: 4,
            child: Container(
              width: 16,
              height: 16,
              decoration: BoxDecoration(
                color: AppColors.gold,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  badge!,
                  style: const TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

// ─── Mobile scaffold ─────────────────────────────────────────────────────────

class _MobileScaffold extends StatelessWidget {
  final Widget child;
  final List<_NavItem> navItems;

  const _MobileScaffold({required this.child, required this.navItems});

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.sidebarBg,
        leading: Padding(
          padding: const EdgeInsets.all(12),
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.gold,
              borderRadius: BorderRadius.circular(6),
            ),
            child: const Center(
              child: Text(
                'L',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
        title: const Text(
          'LEADORA',
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: AppColors.goldLight,
            letterSpacing: 2,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search_rounded, color: AppColors.sidebarText),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.notifications_none_rounded, color: AppColors.sidebarText),
            onPressed: () {},
          ),
          const SizedBox(width: 8),
        ],
      ),
      drawer: Drawer(
        backgroundColor: AppColors.sidebarBg,
        width: 220,
        child: ListView(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
          children: navItems
              .map((item) => SidebarItem(
                    icon: item.icon,
                    label: item.label,
                    collapsed: false,
                    isActive: location.startsWith(item.route),
                    onTap: () {
                      Navigator.pop(context);
                      context.go(item.route);
                    },
                  ))
              .toList(),
        ),
      ),
      body: child,
    );
  }
}

// ─── Data class ──────────────────────────────────────────────────────────────

class _NavItem {
  final String label;
  final IconData icon;
  final String route;
  const _NavItem(this.label, this.icon, this.route);
}
