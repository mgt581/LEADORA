import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/widgets/app_shell.dart';
import '../../../../core/widgets/app_widgets.dart';

class ReportsPage extends StatelessWidget {
  const ReportsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return AppShell(
      currentRoute: '/reports',
      pageTitle: 'Reports',
      topBarActions: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.calendar_today_outlined,
                  size: 14, color: AppColors.textSecondary),
              const SizedBox(width: 6),
              Text('Jul 14 – 21, 2024', style: AppTypography.labelMedium),
              const SizedBox(width: 6),
              const Icon(Icons.keyboard_arrow_down,
                  size: 16, color: AppColors.textSecondary),
            ],
          ),
        ),
        const SizedBox(width: 8),
        GoldButton(
          label: 'Export',
          icon: Icons.download_outlined,
          onTap: () {},
          small: true,
        ),
        const SizedBox(width: AppSpacing.md),
      ],
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.contentPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text('Track your performance and growth.',
                    style: AppTypography.bodySmall),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            GridView.count(
              crossAxisCount: 4,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: AppSpacing.md,
              mainAxisSpacing: AppSpacing.md,
              childAspectRatio: 2.0,
              children: const [
                StatCard(
                  title: 'Total Leads',
                  value: '248',
                  change: '+18%',
                  isPositive: true,
                  icon: Icons.people_outline,
                ),
                StatCard(
                  title: 'Conversions',
                  value: '23',
                  change: '+9%',
                  isPositive: true,
                  icon: Icons.swap_horiz_outlined,
                  iconColor: AppColors.success,
                  iconBgColor: AppColors.successLight,
                ),
                StatCard(
                  title: 'Conversion Rate',
                  value: '9.3%',
                  change: '+2.1%',
                  isPositive: true,
                  icon: Icons.percent_outlined,
                  iconColor: AppColors.info,
                  iconBgColor: AppColors.infoLight,
                ),
                StatCard(
                  title: 'Revenue',
                  value: '£12,540',
                  change: '+22%',
                  isPositive: true,
                  icon: Icons.currency_pound_outlined,
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            LayoutBuilder(
              builder: (context, constraints) {
                if (constraints.maxWidth > 700) {
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(flex: 3, child: _RevenueChart()),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(flex: 2, child: _TopSalesReps()),
                    ],
                  );
                }
                return Column(
                  children: [
                    _RevenueChart(),
                    const SizedBox(height: AppSpacing.md),
                    _TopSalesReps(),
                  ],
                );
              },
            ),
            const SizedBox(height: AppSpacing.lg),
            _ReportsList(),
          ],
        ),
      ),
    );
  }
}

class _RevenueChart extends StatelessWidget {
  final List<FlSpot> _spots = const [
    FlSpot(0, 8400),
    FlSpot(1, 9200),
    FlSpot(2, 8800),
    FlSpot(3, 10500),
    FlSpot(4, 11200),
    FlSpot(5, 10800),
    FlSpot(6, 12540),
  ];

  const _RevenueChart();

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Revenue Over Time', style: AppTypography.titleMedium),
          const SizedBox(height: AppSpacing.lg),
          SizedBox(
            height: 200,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  getDrawingHorizontalLine: (value) => FlLine(
                    color: AppColors.border,
                    strokeWidth: 1,
                    dashArray: [4, 4],
                  ),
                ),
                titlesData: FlTitlesData(
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
                        final idx = value.toInt();
                        if (idx < 0 || idx >= days.length) {
                          return const SizedBox.shrink();
                        }
                        return Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Text(days[idx], style: AppTypography.caption),
                        );
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 52,
                      getTitlesWidget: (value, meta) => Text(
                        '£${(value / 1000).toStringAsFixed(0)}k',
                        style: AppTypography.caption,
                      ),
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
                maxX: 6,
                minY: 7000,
                maxY: 14000,
                lineBarsData: [
                  LineChartBarData(
                    spots: _spots,
                    isCurved: true,
                    gradient: const LinearGradient(
                      colors: [AppColors.goldDark, AppColors.gold],
                    ),
                    barWidth: 2.5,
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

class _TopSalesReps extends StatelessWidget {
  final List<_SalesRep> _reps = const [
    _SalesRep('Alex Bryant', '£4,820', 8, AppColors.gold),
    _SalesRep('Sarah Chen', '£3,240', 6, AppColors.chart1),
    _SalesRep('James Reid', '£2,680', 5, AppColors.chart2),
    _SalesRep('Emma Parker', '£1,800', 4, AppColors.chart3),
  ];

  const _TopSalesReps();

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Top Sales Reps', style: AppTypography.titleMedium),
          const SizedBox(height: AppSpacing.md),
          ..._reps.asMap().entries.map((e) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  children: [
                    Text(
                      '${e.key + 1}',
                      style: AppTypography.caption.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppColors.gold,
                      ),
                    ),
                    const SizedBox(width: 10),
                    CircleAvatar(
                      radius: 14,
                      backgroundColor: e.value.color.withOpacity(0.15),
                      child: Text(
                        e.value.name[0],
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: e.value.color,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(e.value.name,
                          style: AppTypography.titleSmall),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(e.value.revenue,
                            style: AppTypography.titleSmall),
                        Text('${e.value.deals} deals',
                            style: AppTypography.caption),
                      ],
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }
}

class _SalesRep {
  final String name;
  final String revenue;
  final int deals;
  final Color color;

  const _SalesRep(this.name, this.revenue, this.deals, this.color);
}

class _ReportsList extends StatelessWidget {
  final List<_Report> _reports = const [
    _Report('Lead Generation Report', 'Weekly summary of new leads and sources', Icons.people_outline, 'Jul 21, 2024'),
    _Report('Revenue Report', 'Monthly revenue breakdown by channel', Icons.currency_pound_outlined, 'Jul 21, 2024'),
    _Report('Pipeline Report', 'Current pipeline value and stage analysis', Icons.account_tree_outlined, 'Jul 20, 2024'),
    _Report('Email Performance', 'Campaign open, click, and reply rates', Icons.email_outlined, 'Jul 19, 2024'),
  ];

  const _ReportsList();

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(AppSpacing.cardPadding),
            child: Row(
              children: [
                Text('Recent Reports', style: AppTypography.titleMedium),
                const Spacer(),
                GoldButton(
                    label: 'Create Report',
                    icon: Icons.add,
                    onTap: () {},
                    small: true),
              ],
            ),
          ),
          const Divider(height: 1),
          AppDataTable(
            headers: const ['Report Name', 'Description', 'Generated'],
            columnWidths: const [220, 380, 140],
            rows: _reports
                .map((r) => [
                      Row(
                        children: [
                          Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: AppColors.goldSurface,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(r.icon,
                                size: 16, color: AppColors.gold),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(r.title,
                                style: AppTypography.titleSmall,
                                overflow: TextOverflow.ellipsis),
                          ),
                        ],
                      ),
                      Text(r.description,
                          style: AppTypography.bodySmall,
                          overflow: TextOverflow.ellipsis),
                      Text(r.generated, style: AppTypography.caption),
                    ])
                .toList(),
          ),
        ],
      ),
    );
  }
}

class _Report {
  final String title;
  final String description;
  final IconData icon;
  final String generated;

  const _Report(this.title, this.description, this.icon, this.generated);
}
