import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/cards/app_card.dart';
import '../../../../core/widgets/charts/chart_widgets.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  static const List<double> _weeklyLeads = [
    42, 58, 35, 72, 89, 64, 95, 48, 76, 83, 67, 91, 55, 78,
  ];
  static const List<String> _weekDays = [
    'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun',
    'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun',
  ];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _GreetingHeader(),
          const SizedBox(height: 24),
          _StatsRow(),
          const SizedBox(height: 24),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 3,
                child: TrendLineChart(
                  title: 'Leads Overview',
                  values: _weeklyLeads,
                  labels: _weekDays,
                  period: 'This Week',
                ),
              ),
              const SizedBox(width: 20),
              const Expanded(
                flex: 2,
                child: _RecentActivity(),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Expanded(child: _TopCampaigns()),
              SizedBox(width: 20),
              Expanded(
                child: FunnelCard(
                  title: 'Pipeline Overview',
                  stages: [
                    FunnelStage(label: 'New Leads', count: 248, color: AppColors.badgeNew),
                    FunnelStage(label: 'Contacted', count: 166, color: AppColors.badgeContacted),
                    FunnelStage(label: 'Qualified', count: 89, color: AppColors.badgeQualified),
                    FunnelStage(label: 'Proposal', count: 43, color: AppColors.badgeProposal),
                    FunnelStage(label: 'Won', count: 23, color: AppColors.badgeWon),
                  ],
                ),
              ),
              SizedBox(width: 20),
              Expanded(child: _TasksDueToday()),
            ],
          ),
          const SizedBox(height: 28),
        ],
      ),
    );
  }
}

// ─── Greeting header ──────────────────────────────────────────────────────────

class _GreetingHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Good morning, Alex 👋',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 26,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                "Here's what's happening with your business today.",
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.cardBg,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.cardBorder),
          ),
          child: const Row(
            children: [
              Icon(Icons.calendar_today_outlined, size: 14, color: AppColors.textSecondary),
              SizedBox(width: 6),
              Text(
                'Jul 14 – 21, 2024',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 13,
                  color: AppColors.textSecondary,
                ),
              ),
              SizedBox(width: 4),
              Icon(Icons.keyboard_arrow_down_rounded, size: 14, color: AppColors.textSecondary),
            ],
          ),
        ),
      ],
    );
  }
}

// ─── Stats row ────────────────────────────────────────────────────────────────

class _StatsRow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      final isWide = constraints.maxWidth > 800;
      final cards = [
        StatCard(
          title: 'New Leads',
          value: '248',
          delta: '18% vs last 7 days',
          deltaPositive: true,
          icon: Icons.person_add_outlined,
          iconColor: AppColors.badgeNew,
          iconBackground: AppColors.badgeNewSurface,
        ),
        StatCard(
          title: 'Open Deals',
          value: '67',
          delta: '12% vs last 7 days',
          deltaPositive: true,
          icon: Icons.handshake_outlined,
          iconColor: AppColors.gold,
          iconBackground: AppColors.goldSurface,
        ),
        StatCard(
          title: 'Conversions',
          value: '23',
          delta: '8% vs last 7 days',
          deltaPositive: false,
          icon: Icons.trending_up_rounded,
          iconColor: AppColors.success,
          iconBackground: AppColors.successSurface,
        ),
        StatCard(
          title: 'Revenue',
          value: '£12,540',
          delta: '22% vs last 7 days',
          deltaPositive: true,
          icon: Icons.attach_money_rounded,
          iconColor: AppColors.gold,
          iconBackground: AppColors.goldSurface,
        ),
      ];

      if (isWide) {
        return Row(
          children: cards
              .map((c) => Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(right: 16),
                      child: c,
                    ),
                  ))
              .toList()
            ..last = Expanded(child: cards.last),
        );
      }
      return GridView.count(
        crossAxisCount: 2,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.4,
        children: cards,
      );
    });
  }
}

// ─── Recent activity ──────────────────────────────────────────────────────────

class _RecentActivity extends StatelessWidget {
  const _RecentActivity();

  static const List<_ActivityItem> _items = [
    _ActivityItem(Icons.person_add_outlined, 'New lead: Sarah Johnson', '2 min ago', AppColors.badgeNew),
    _ActivityItem(Icons.mark_email_read_outlined, 'Email opened: Proposal Follow-up', '12 min ago', AppColors.badgeContacted),
    _ActivityItem(Icons.handshake_outlined, 'Deal won: ACME Solutions', '1 h ago', AppColors.success),
    _ActivityItem(Icons.task_alt_outlined, 'Task completed: Call with James', '2 h ago', AppColors.badgeQualified),
    _ActivityItem(Icons.person_add_outlined, 'New lead: David Williams', '3 h ago', AppColors.badgeNew),
  ];

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Recent Activity',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          ..._items.map((item) => _ActivityTile(item: item)),
          const SizedBox(height: 8),
          Center(
            child: TextButton(
              onPressed: () {},
              child: const Text('View all activity',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 12,
                    color: AppColors.gold,
                  )),
            ),
          ),
        ],
      ),
    );
  }
}

class _ActivityTile extends StatelessWidget {
  final _ActivityItem item;
  const _ActivityTile({required this.item});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: item.color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(item.icon, size: 14, color: item.color),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              item.label,
              style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 12,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          Text(
            item.time,
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 11,
              color: AppColors.textTertiary,
            ),
          ),
        ],
      ),
    );
  }
}

class _ActivityItem {
  final IconData icon;
  final String label;
  final String time;
  final Color color;
  const _ActivityItem(this.icon, this.label, this.time, this.color);
}

// ─── Top campaigns ────────────────────────────────────────────────────────────

class _TopCampaigns extends StatelessWidget {
  const _TopCampaigns();

  static const List<_CampaignItem> _items = [
    _CampaignItem('Summer Promotion', '126 leads', '+24%', true),
    _CampaignItem('Email Outreach', '96 leads', '+18%', true),
    _CampaignItem('Social Media Ads', '74 leads', '+12%', true),
  ];

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Top Performing Campaigns',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          ..._items.map((c) => _CampaignTile(campaign: c)),
          const SizedBox(height: 8),
          TextButton(
            onPressed: () {},
            child: const Text('View all campaigns',
                style: TextStyle(fontFamily: 'Inter', fontSize: 12, color: AppColors.gold)),
          ),
        ],
      ),
    );
  }
}

class _CampaignTile extends StatelessWidget {
  final _CampaignItem campaign;
  const _CampaignTile({required this.campaign});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.goldSurface,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.campaign_outlined, size: 16, color: AppColors.gold),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  campaign.name,
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  campaign.leads,
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 11,
                    color: AppColors.textTertiary,
                  ),
                ),
              ],
            ),
          ),
          DeltaBadge(value: campaign.delta, positive: campaign.positive),
        ],
      ),
    );
  }
}

class _CampaignItem {
  final String name;
  final String leads;
  final String delta;
  final bool positive;
  const _CampaignItem(this.name, this.leads, this.delta, this.positive);
}

// ─── Tasks due today ──────────────────────────────────────────────────────────

class _TasksDueToday extends StatefulWidget {
  const _TasksDueToday();

  @override
  State<_TasksDueToday> createState() => _TasksDueTodayState();
}

class _TasksDueTodayState extends State<_TasksDueToday> {
  final List<bool> _checked = [false, false, false, false];
  static const List<_TaskItem> _tasks = [
    _TaskItem('Follow up with Sarah Johnson', '9:00 AM'),
    _TaskItem('Call David Williams', '11:00 AM'),
    _TaskItem('Email proposal to ACME', '1:00 PM'),
    _TaskItem('Team meeting', '3:00 PM'),
  ];

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Tasks Due Today',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          ..._tasks.asMap().entries.map((entry) {
            final i = entry.key;
            final task = entry.value;
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                children: [
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: Checkbox(
                      value: _checked[i],
                      onChanged: (v) => setState(() => _checked[i] = v ?? false),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
                      side: const BorderSide(color: AppColors.cardBorder, width: 1.5),
                      activeColor: AppColors.gold,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      task.label,
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 12,
                        color: _checked[i]
                            ? AppColors.textTertiary
                            : AppColors.textPrimary,
                        decoration: _checked[i]
                            ? TextDecoration.lineThrough
                            : null,
                      ),
                    ),
                  ),
                  Text(
                    task.time,
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 11,
                      color: AppColors.textTertiary,
                    ),
                  ),
                ],
              ),
            );
          }),
          const SizedBox(height: 8),
          TextButton(
            onPressed: () {},
            child: const Text('View all tasks',
                style: TextStyle(fontFamily: 'Inter', fontSize: 12, color: AppColors.gold)),
          ),
        ],
      ),
    );
  }
}

class _TaskItem {
  final String label;
  final String time;
  const _TaskItem(this.label, this.time);
}
