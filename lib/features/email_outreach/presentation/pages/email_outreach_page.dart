import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/widgets/app_shell.dart';
import '../../../../core/widgets/app_widgets.dart';

class EmailOutreachPage extends StatefulWidget {
  const EmailOutreachPage({super.key});

  @override
  State<EmailOutreachPage> createState() => _EmailOutreachPageState();
}

class _EmailOutreachPageState extends State<EmailOutreachPage> {
  int _selectedTab = 0;
  final List<String> _tabs = ['Campaigns', 'Templates', 'Analytics'];

  final List<_Campaign> _campaigns = const [
    _Campaign(name: 'Summer Promotion', status: 'Active', sent: 1240, opened: 487, clicked: 124, replied: 48),
    _Campaign(name: 'Follow-up Sequence', status: 'Active', sent: 860, opened: 301, clicked: 87, replied: 35),
    _Campaign(name: 'Re-engagement Campaign', status: 'Paused', sent: 540, opened: 162, clicked: 43, replied: 12),
    _Campaign(name: 'Deal Won Celebration', status: 'Active', sent: 124, opened: 124, clicked: 98, replied: 78),
    _Campaign(name: 'Onboarding Sequence', status: 'Draft', sent: 0, opened: 0, clicked: 0, replied: 0),
  ];

  @override
  Widget build(BuildContext context) {
    return AppShell(
      currentRoute: '/email-outreach',
      pageTitle: 'Email Outreach',
      topBarActions: [
        GoldButton(
          label: 'New Campaign',
          icon: Icons.add,
          onTap: () {},
          small: true,
        ),
        const SizedBox(width: AppSpacing.md),
      ],
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.contentPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GridView.count(
              crossAxisCount: 4,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: AppSpacing.md,
              mainAxisSpacing: AppSpacing.md,
              childAspectRatio: 2.2,
              children: const [
                StatCard(
                  title: 'Emails Sent',
                  value: '2,764',
                  change: '+18% this week',
                  isPositive: true,
                  icon: Icons.send_outlined,
                ),
                StatCard(
                  title: 'Open Rate',
                  value: '38.4%',
                  change: '+2.1% vs last week',
                  isPositive: true,
                  icon: Icons.mail_open_outlined,
                  iconColor: AppColors.info,
                  iconBgColor: AppColors.infoLight,
                ),
                StatCard(
                  title: 'Click Rate',
                  value: '12.6%',
                  icon: Icons.ads_click_outlined,
                  iconColor: AppColors.success,
                  iconBgColor: AppColors.successLight,
                ),
                StatCard(
                  title: 'Reply Rate',
                  value: '6.2%',
                  change: '+0.8% vs last week',
                  isPositive: true,
                  icon: Icons.reply_outlined,
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            AppCard(
              padding: EdgeInsets.zero,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(AppSpacing.cardPadding),
                    child: Row(
                      children: [
                        ..._tabs.asMap().entries.map(
                              (e) => GestureDetector(
                                onTap: () =>
                                    setState(() => _selectedTab = e.key),
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 150),
                                  margin: const EdgeInsets.only(right: 4),
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 14, vertical: 7),
                                  decoration: BoxDecoration(
                                    color: _selectedTab == e.key
                                        ? AppColors.sidebarBg
                                        : Colors.transparent,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    e.value,
                                    style: AppTypography.labelMedium.copyWith(
                                      color: _selectedTab == e.key
                                          ? AppColors.white
                                          : AppColors.textSecondary,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                      ],
                    ),
                  ),
                  const Divider(height: 1),
                  AppDataTable(
                    headers: const [
                      'Campaign',
                      'Status',
                      'Sent',
                      'Opened',
                      'Clicked',
                      'Replied',
                    ],
                    columnWidths: const [200, 100, 100, 100, 100, 100],
                    rows: _campaigns
                        .map((c) => [
                              Row(
                                children: [
                                  Container(
                                    width: 32,
                                    height: 32,
                                    decoration: BoxDecoration(
                                      color: AppColors.goldSurface,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const Icon(
                                      Icons.email_outlined,
                                      size: 16,
                                      color: AppColors.gold,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      c.name,
                                      style: AppTypography.titleSmall,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                              StatusBadge(
                                label: c.status,
                                color: c.status == 'Active'
                                    ? AppColors.success
                                    : c.status == 'Paused'
                                        ? AppColors.warning
                                        : AppColors.textTertiary,
                                bgColor: c.status == 'Active'
                                    ? AppColors.successLight
                                    : c.status == 'Paused'
                                        ? AppColors.warningLight
                                        : AppColors.borderLight,
                              ),
                              Text(c.sent == 0
                                  ? '-'
                                  : '${c.sent}'),
                              Text(c.opened == 0
                                  ? '-'
                                  : '${c.opened}'),
                              Text(c.clicked == 0
                                  ? '-'
                                  : '${c.clicked}'),
                              Text(c.replied == 0
                                  ? '-'
                                  : '${c.replied}'),
                            ])
                        .toList(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Campaign {
  final String name;
  final String status;
  final int sent;
  final int opened;
  final int clicked;
  final int replied;

  const _Campaign({
    required this.name,
    required this.status,
    required this.sent,
    required this.opened,
    required this.clicked,
    required this.replied,
  });
}
