import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../constants/app_colors.dart';
import '../constants/app_spacing.dart';
import '../constants/app_typography.dart';

class NavItem {
  final String label;
  final IconData icon;
  final String route;

  const NavItem({
    required this.label,
    required this.icon,
    required this.route,
  });
}

const List<NavItem> kNavItems = [
  NavItem(label: 'Dashboard', icon: Icons.dashboard_outlined, route: '/'),
  NavItem(label: 'Leads', icon: Icons.person_add_outlined, route: '/leads'),
  NavItem(
      label: 'Contacts', icon: Icons.contacts_outlined, route: '/contacts'),
  NavItem(
      label: 'Companies',
      icon: Icons.business_outlined,
      route: '/companies'),
  NavItem(label: 'Deals', icon: Icons.handshake_outlined, route: '/deals'),
  NavItem(
      label: 'Pipelines',
      icon: Icons.account_tree_outlined,
      route: '/pipelines'),
  NavItem(
      label: 'Email Outreach',
      icon: Icons.email_outlined,
      route: '/email-outreach'),
  NavItem(
      label: 'Website Audits',
      icon: Icons.web_outlined,
      route: '/website-audits'),
  NavItem(
      label: 'AI Agents',
      icon: Icons.smart_toy_outlined,
      route: '/ai-agents'),
  NavItem(
      label: 'Automations',
      icon: Icons.bolt_outlined,
      route: '/automations'),
  NavItem(
      label: 'Analytics',
      icon: Icons.bar_chart_outlined,
      route: '/analytics'),
  NavItem(
      label: 'Reports',
      icon: Icons.assessment_outlined,
      route: '/reports'),
  NavItem(label: 'Settings', icon: Icons.settings_outlined, route: '/settings'),
];

class AppSidebar extends StatelessWidget {
  final String currentRoute;

  const AppSidebar({super.key, required this.currentRoute});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: AppSpacing.sidebarWidth,
      color: AppColors.sidebarBg,
      child: Column(
        children: [
          _buildLogo(),
          const SizedBox(height: AppSpacing.sm),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.sm,
                vertical: AppSpacing.xs,
              ),
              children: kNavItems
                  .map((item) => _NavTile(
                        item: item,
                        isActive: _isActive(item.route),
                        onTap: () => context.go(item.route),
                      ))
                  .toList(),
            ),
          ),
          _buildUserProfile(),
        ],
      ),
    );
  }

  bool _isActive(String route) {
    if (route == '/' && currentRoute == '/') return true;
    if (route != '/' && currentRoute.startsWith(route)) return true;
    return false;
  }

  Widget _buildLogo() {
    return Container(
      height: AppSpacing.topbarHeight,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: AppColors.gold,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Center(
              child: Text(
                'LO',
                style: TextStyle(
                  color: AppColors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Text('LEADORA', style: AppTypography.logoText),
        ],
      ),
    );
  }

  Widget _buildUserProfile() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: AppColors.sidebarBorder)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: AppColors.gold,
            child: const Text(
              'AB',
              style: TextStyle(
                color: AppColors.white,
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Alex Bryant',
                  style: AppTypography.labelMedium.copyWith(
                    color: AppColors.white,
                    fontSize: 13,
                  ),
                ),
                Text(
                  'Admin',
                  style: AppTypography.caption.copyWith(
                    color: AppColors.textSidebarInactive,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _NavTile extends StatefulWidget {
  final NavItem item;
  final bool isActive;
  final VoidCallback onTap;

  const _NavTile({
    required this.item,
    required this.isActive,
    required this.onTap,
  });

  @override
  State<_NavTile> createState() => _NavTileState();
}

class _NavTileState extends State<_NavTile> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final active = widget.isActive;
    final hovered = _hovered;

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          margin: const EdgeInsets.symmetric(vertical: 1),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.sm + 4,
            vertical: AppSpacing.sm + 2,
          ),
          decoration: BoxDecoration(
            color: active
                ? AppColors.sidebarActive
                : hovered
                    ? AppColors.sidebarHover
                    : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Icon(
                widget.item.icon,
                size: 17,
                color: active
                    ? AppColors.gold
                    : AppColors.textSidebarInactive,
              ),
              const SizedBox(width: AppSpacing.sm + 2),
              Text(
                widget.item.label,
                style: AppTypography.bodySmall.copyWith(
                  color: active
                      ? AppColors.textSidebarActive
                      : AppColors.textSidebarInactive,
                  fontWeight:
                      active ? FontWeight.w500 : FontWeight.w400,
                  fontSize: 13,
                ),
              ),
              if (active) ...[
                const Spacer(),
                Container(
                  width: 3,
                  height: 3,
                  decoration: const BoxDecoration(
                    color: AppColors.gold,
                    shape: BoxShape.circle,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
