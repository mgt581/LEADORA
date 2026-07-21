import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/widgets/app_shell.dart';
import '../../../../core/widgets/app_widgets.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return AppShell(
      currentRoute: '/',
      pageTitle: 'Dashboard',
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.contentPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _WelcomeHeader(),
            const SizedBox(height: AppSpacing.lg),
            _StatsRow(),
            const SizedBox(height: AppSpacing.lg),
            _MiddleRow(),
            const SizedBox(height: AppSpacing.lg),
            _BottomRow(),
          ],
        ),
      ),
    );
  }
}

class _WelcomeHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text('Good morning, Alex ', style: AppTypography.headlineLarge),
                const Text('👋', style: TextStyle(fontSize: 24)),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              "Here's what's happening with your business today.",
              style: AppTypography.bodySmall,
            ),
          ],
        ),
        const Spacer(),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              const Icon(Icons.calendar_today_outlined,
                  size: 14, color: AppColors.textSecondary),
              const SizedBox(width: 6),
              Text(
                'Jul 14 – 21, 2024',
                style: AppTypography.labelMedium,
              ),
              const SizedBox(width: 6),
              const Icon(Icons.keyboard_arrow_down,
                  size: 16, color: AppColors.textSecondary),
            ],
          ),
        ),
      ],
    );
  }
}

class _StatsRow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final crossCount = constraints.maxWidth > 800 ? 4 : 2;
        return GridView.count(
          crossAxisCount: crossCount,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: AppSpacing.md,
          mainAxisSpacing: AppSpacing.md,
          childAspectRatio: constraints.maxWidth > 800 ? 1.8 : 1.5,
          children: const [
            StatCard(
              title: 'New Leads',
              value: '248',
              change: '18% vs last 7 days',
              isPositive: true,
              icon: Icons.person_add_outlined,
              iconColor: AppColors.gold,
              iconBgColor: AppColors.goldSurface,
            ),
            StatCard(
              title: 'Open Deals',
              value: '67',
              change: '12% vs last 7 days',
              isPositive: true,
              icon: Icons.handshake_outlined,
              iconColor: AppColors.info,
              iconBgColor: AppColors.infoLight,
            ),
            StatCard(
              title: 'Conversions',
              value: '23',
              change: '8% vs last 7 days',
              isPositive: true,
              icon: Icons.swap_horiz_outlined,
              iconColor: AppColors.success,
              iconBgColor: AppColors.successLight,
            ),
            StatCard(
              title: 'Revenue',
              value: '£12,540',
              change: '22% vs last 7 days',
              isPositive: true,
              icon: Icons.currency_pound_outlined,
              iconColor: AppColors.gold,
              iconBgColor: AppColors.goldSurface,
            ),
          ],
        );
      },
    );
  }
}

class _MiddleRow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth > 800) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(flex: 3, child: _LeadsOverviewChart()),
              const SizedBox(width: AppSpacing.md),
              Expanded(flex: 2, child: _RecentActivity()),
            ],
          );
        }
        return Column(
          children: [
            _LeadsOverviewChart(),
            const SizedBox(height: AppSpacing.md),
            _RecentActivity(),
          ],
        );
      },
    );
  }
}

class _BottomRow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth > 900) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(flex: 2, child: _TopCampaigns()),
              const SizedBox(width: AppSpacing.md),
              Expanded(flex: 2, child: _PipelineOverview()),
              const SizedBox(width: AppSpacing.md),
              Expanded(flex: 2, child: _TasksDueToday()),
            ],
          );
        }
        return Column(
          children: [
            _TopCampaigns(),
            const SizedBox(height: AppSpacing.md),
            _PipelineOverview(),
            const SizedBox(height: AppSpacing.md),
            _TasksDueToday(),
          ],
        );
      },
    );
  }
}

class _LeadsOverviewChart extends StatelessWidget {
  final List<FlSpot> spots = const [
    FlSpot(0, 40),
    FlSpot(1, 55),
    FlSpot(2, 48),
    FlSpot(3, 72),
    FlSpot(4, 65),
    FlSpot(5, 85),
    FlSpot(6, 78),
    FlSpot(7, 95),
    FlSpot(8, 88),
    FlSpot(9, 110),
    FlSpot(10, 102),
    FlSpot(11, 120),
    FlSpot(12, 115),
    FlSpot(13, 130),
  ];

  const _LeadsOverviewChart();

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeader(
            title: 'Leads Overview',
            trailing: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.contentBg,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('This Week', style: AppTypography.labelMedium),
                  const SizedBox(width: 4),
                  const Icon(Icons.keyboard_arrow_down,
                      size: 14, color: AppColors.textSecondary),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          SizedBox(
            height: 200,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: 25,
                  getDrawingHorizontalLine: (value) => FlLine(
                    color: AppColors.border,
                    strokeWidth: 1,
                    dashArray: [4, 4],
                  ),
                ),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: 25,
                      reservedSize: 36,
                      getTitlesWidget: (value, meta) => Text(
                        value.toInt().toString(),
                        style: AppTypography.caption,
                      ),
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: 2,
                      getTitlesWidget: (value, meta) {
                        const labels = [
                          'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'
                        ];
                        final idx = (value / 2).round();
                        if (idx < 0 || idx >= labels.length) {
                          return const SizedBox.shrink();
                        }
                        return Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Text(labels[idx],
                              style: AppTypography.caption),
                        );
                      },
                    ),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                ),
                borderData: FlBorderData(show: false),
                minX: 0,
                maxX: 13,
                minY: 0,
                maxY: 140,
                lineBarsData: [
                  LineChartBarData(
                    spots: spots,
                    isCurved: true,
                    gradient: const LinearGradient(
                      colors: [AppColors.goldDark, AppColors.gold],
                    ),
                    barWidth: 2.5,
                    isStrokeCapRound: true,
                    dotData: const FlDotData(show: false),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          AppColors.gold.withOpacity(0.15),
                          AppColors.gold.withOpacity(0.01),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RecentActivity extends StatelessWidget {
  final List<_ActivityItem> items = const [
    _ActivityItem(
      icon: Icons.person_add_outlined,
      text: 'New lead: Sarah Johnson',
      time: '2 min ago',
      color: AppColors.gold,
    ),
    _ActivityItem(
      icon: Icons.email_outlined,
      text: 'Email opened: Proposal Follow-up',
      time: '12 min ago',
      color: AppColors.info,
    ),
    _ActivityItem(
      icon: Icons.handshake_outlined,
      text: 'Deal won: ACME Solutions',
      time: '1 h ago',
      color: AppColors.success,
    ),
    _ActivityItem(
      icon: Icons.task_alt_outlined,
      text: 'Task completed: Call with James',
      time: '2 h ago',
      color: AppColors.success,
    ),
    _ActivityItem(
      icon: Icons.person_add_outlined,
      text: 'New lead: David Williams',
      time: '3 h ago',
      color: AppColors.gold,
    ),
  ];

  const _RecentActivity();

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeader(
            title: 'Recent Activity',
            trailing: TextButton(
              onPressed: () {},
              child: Text(
                'View all',
                style: AppTypography.labelMedium
                    .copyWith(color: AppColors.gold),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          ...items.map((item) => _ActivityTile(item: item)),
        ],
      ),
    );
  }
}

class _ActivityItem {
  final IconData icon;
  final String text;
  final String time;
  final Color color;

  const _ActivityItem({
    required this.icon,
    required this.text,
    required this.time,
    required this.color,
  });
}

class _ActivityTile extends StatelessWidget {
  final _ActivityItem item;

  const _ActivityTile({required this.item});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: item.color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(item.icon, size: 16, color: item.color),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(item.text, style: AppTypography.bodySmall),
          ),
          Text(item.time, style: AppTypography.caption),
        ],
      ),
    );
  }
}

class _TopCampaigns extends StatelessWidget {
  final List<_CampaignItem> campaigns = const [
    _CampaignItem(
        name: 'Summer Promotion', leads: '128 leads', change: '+24%'),
    _CampaignItem(
        name: 'Email Outreach', leads: '96 leads', change: '+18%'),
    _CampaignItem(
        name: 'Social Media Ads', leads: '74 leads', change: '+12%'),
  ];

  const _TopCampaigns();

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeader(
            title: 'Top Performing Campaigns',
            trailing: TextButton(
              onPressed: () {},
              child: Text(
                'View all campaigns',
                style: AppTypography.labelMedium
                    .copyWith(color: AppColors.gold),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          ...campaigns.map((c) => _CampaignTile(item: c)),
        ],
      ),
    );
  }
}

class _CampaignItem {
  final String name;
  final String leads;
  final String change;

  const _CampaignItem({
    required this.name,
    required this.leads,
    required this.change,
  });
}

class _CampaignTile extends StatelessWidget {
  final _CampaignItem item;

  const _CampaignTile({required this.item});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.goldSurface,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.campaign_outlined,
                size: 18, color: AppColors.gold),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.name, style: AppTypography.titleSmall),
                Text(item.leads, style: AppTypography.caption),
              ],
            ),
          ),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: AppColors.successLight,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              item.change,
              style: AppTypography.labelSmall.copyWith(
                color: AppColors.success,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PipelineOverview extends StatelessWidget {
  const _PipelineOverview();

  @override
  Widget build(BuildContext context) {
    final stages = [
      _PipelineStage('New Leads', 248, AppColors.chart1, 1.0),
      _PipelineStage('Contacted', 166, AppColors.gold, 166 / 248),
      _PipelineStage('Qualified', 89, AppColors.chart2, 89 / 248),
      _PipelineStage('Proposal', 43, AppColors.warning, 43 / 248),
      _PipelineStage('Won', 23, AppColors.success, 23 / 248),
    ];

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Pipeline Overview',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
          const SizedBox(height: AppSpacing.md),
          ...stages.map((s) => _PipelineStageTile(stage: s)),
        ],
      ),
    );
  }
}

class _PipelineStage {
  final String label;
  final int count;
  final Color color;
  final double ratio;

  const _PipelineStage(this.label, this.count, this.color, this.ratio);
}

class _PipelineStageTile extends StatelessWidget {
  final _PipelineStage stage;

  const _PipelineStageTile({required this.stage});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              color: stage.color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(stage.label, style: AppTypography.bodySmall),
                    Text(
                      stage.count.toString(),
                      style: AppTypography.titleSmall,
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: stage.ratio,
                    backgroundColor: AppColors.borderLight,
                    valueColor:
                        AlwaysStoppedAnimation<Color>(stage.color),
                    minHeight: 6,
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

class _TasksDueToday extends StatelessWidget {
  final List<_Task> tasks = const [
    _Task('Follow up with Sarah Johnson', '9:00 AM'),
    _Task('Call David Williams', '11:00 AM'),
    _Task('Email proposal to ACME', '1:00 PM'),
    _Task('Team meeting', '3:00 PM'),
  ];

  const _TasksDueToday();

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeader(
            title: 'Tasks Due Today',
            trailing: TextButton(
              onPressed: () {},
              child: Text(
                'View all tasks',
                style: AppTypography.labelMedium
                    .copyWith(color: AppColors.gold),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          ...tasks.map((t) => _TaskTile(task: t)),
        ],
      ),
    );
  }
}

class _Task {
  final String title;
  final String time;

  const _Task(this.title, this.time);
}

class _TaskTile extends StatefulWidget {
  final _Task task;

  const _TaskTile({required this.task});

  @override
  State<_TaskTile> createState() => _TaskTileState();
}

class _TaskTileState extends State<_TaskTile> {
  bool _checked = false;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => setState(() => _checked = !_checked),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              width: 18,
              height: 18,
              decoration: BoxDecoration(
                color: _checked ? AppColors.gold : Colors.transparent,
                shape: BoxShape.circle,
                border: Border.all(
                  color:
                      _checked ? AppColors.gold : AppColors.textTertiary,
                  width: 1.5,
                ),
              ),
              child: _checked
                  ? const Icon(Icons.check, size: 10, color: AppColors.white)
                  : null,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              widget.task.title,
              style: AppTypography.bodySmall.copyWith(
                decoration:
                    _checked ? TextDecoration.lineThrough : null,
                color: _checked
                    ? AppColors.textTertiary
                    : AppColors.textPrimary,
              ),
            ),
          ),
          Text(
            widget.task.time,
            style: AppTypography.caption,
          ),
        ],
      ),
    );
  }
}
