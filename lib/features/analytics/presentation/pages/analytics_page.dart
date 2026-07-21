import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/widgets/app_shell.dart';
import '../../../../core/widgets/app_widgets.dart';

class AnalyticsPage extends StatelessWidget {
  const AnalyticsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return AppShell(
      currentRoute: '/analytics',
      pageTitle: 'Analytics',
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.contentPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text('Analytics Overview',
                    style: AppTypography.headlineSmall),
                const Spacer(),
                _DateRangePicker(),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            GridView.count(
              crossAxisCount: 4,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: AppSpacing.md,
              mainAxisSpacing: AppSpacing.md,
              childAspectRatio: 2.2,
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
                      Expanded(flex: 3, child: _LeadsOverTimeChart()),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(flex: 2, child: _LeadsBySourceChart()),
                    ],
                  );
                }
                return Column(
                  children: [
                    _LeadsOverTimeChart(),
                    const SizedBox(height: AppSpacing.md),
                    _LeadsBySourceChart(),
                  ],
                );
              },
            ),
            const SizedBox(height: AppSpacing.lg),
            LayoutBuilder(
              builder: (context, constraints) {
                if (constraints.maxWidth > 700) {
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: _ChannelPerformance()),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(child: _ConversionFunnel()),
                    ],
                  );
                }
                return Column(
                  children: [
                    _ChannelPerformance(),
                    const SizedBox(height: AppSpacing.md),
                    _ConversionFunnel(),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _DateRangePicker extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
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
    );
  }
}

class _LeadsOverTimeChart extends StatelessWidget {
  final List<BarChartGroupData> _bars = List.generate(7, (i) {
    final values = [40, 55, 48, 72, 65, 85, 78];
    final prev = [35, 48, 55, 60, 70, 75, 65];
    return BarChartGroupData(
      x: i,
      barRods: [
        BarChartRodData(
          toY: values[i].toDouble(),
          color: AppColors.gold,
          width: 14,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
        ),
        BarChartRodData(
          toY: prev[i].toDouble(),
          color: AppColors.chartGoldLight,
          width: 14,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
        ),
      ],
      barsSpace: 4,
    );
  });

  const _LeadsOverTimeChart();

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('Leads Over Time', style: AppTypography.titleMedium),
              const Spacer(),
              _LegendDot(color: AppColors.gold, label: 'Last 7 days'),
              const SizedBox(width: 12),
              _LegendDot(
                  color: AppColors.chartGoldLight, label: 'Previous 7 days'),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          SizedBox(
            height: 200,
            child: BarChart(
              BarChartData(
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
                        return Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Text(days[value.toInt()],
                              style: AppTypography.caption),
                        );
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 36,
                      getTitlesWidget: (value, meta) => Text(
                        value.toInt().toString(),
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
                barGroups: _bars,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LegendDot extends StatelessWidget {
  final Color color;
  final String label;

  const _LegendDot({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(label, style: AppTypography.caption),
      ],
    );
  }
}

class _LeadsBySourceChart extends StatelessWidget {
  const _LeadsBySourceChart();

  @override
  Widget build(BuildContext context) {
    const sections = [
      _PieSection('Website', 42, AppColors.gold),
      _PieSection('LinkedIn', 28, AppColors.chart1),
      _PieSection('Referral', 15, AppColors.chart2),
      _PieSection('Ads', 10, AppColors.chart3),
      _PieSection('Other', 5, AppColors.textTertiary),
    ];

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Leads by Source', style: AppTypography.titleMedium),
          const SizedBox(height: AppSpacing.lg),
          SizedBox(
            height: 200,
            child: Row(
              children: [
                Expanded(
                  child: PieChart(
                    PieChartData(
                      sections: sections
                          .map((s) => PieChartSectionData(
                                value: s.percent.toDouble(),
                                color: s.color,
                                radius: 70,
                                title: '',
                                showTitle: false,
                              ))
                          .toList(),
                      sectionsSpace: 2,
                      centerSpaceRadius: 30,
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: sections
                      .map((s) => Padding(
                            padding: const EdgeInsets.symmetric(vertical: 3),
                            child: Row(
                              children: [
                                Container(
                                  width: 10,
                                  height: 10,
                                  decoration: BoxDecoration(
                                    color: s.color,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(s.label,
                                    style: AppTypography.bodySmall),
                                const SizedBox(width: 8),
                                Text('${s.percent}%',
                                    style: AppTypography.titleSmall
                                        .copyWith(color: s.color)),
                              ],
                            ),
                          ))
                      .toList(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PieSection {
  final String label;
  final int percent;
  final Color color;

  const _PieSection(this.label, this.percent, this.color);
}

class _ChannelPerformance extends StatelessWidget {
  final List<_Channel> _channels = const [
    _Channel('Website', 104, 18.2),
    _Channel('LinkedIn', 69, 12.8),
    _Channel('Referral', 37, 28.4),
    _Channel('Google Ads', 25, 8.6),
    _Channel('Cold Email', 13, 6.2),
  ];

  const _ChannelPerformance();

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Channel Performance', style: AppTypography.titleMedium),
          const SizedBox(height: AppSpacing.md),
          ...(_channels.map((c) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  children: [
                    SizedBox(
                      width: 100,
                      child: Text(c.name, style: AppTypography.bodySmall),
                    ),
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: c.leads / 104,
                          backgroundColor: AppColors.borderLight,
                          valueColor: const AlwaysStoppedAnimation<Color>(
                              AppColors.gold),
                          minHeight: 8,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    SizedBox(
                      width: 30,
                      child: Text('${c.leads}',
                          style: AppTypography.titleSmall),
                    ),
                    SizedBox(
                      width: 50,
                      child: Text(
                        '${c.convRate}%',
                        style: AppTypography.caption
                            .copyWith(color: AppColors.success),
                        textAlign: TextAlign.right,
                      ),
                    ),
                  ],
                ),
              ))),
        ],
      ),
    );
  }
}

class _Channel {
  final String name;
  final int leads;
  final double convRate;

  const _Channel(this.name, this.leads, this.convRate);
}

class _ConversionFunnel extends StatelessWidget {
  const _ConversionFunnel();

  @override
  Widget build(BuildContext context) {
    final stages = [
      _FunnelStage('Visitors', 5200, 1.0, AppColors.chart1),
      _FunnelStage('Leads', 248, 248 / 5200, AppColors.gold),
      _FunnelStage('Qualified', 89, 89 / 5200, AppColors.chart2),
      _FunnelStage('Proposals', 43, 43 / 5200, AppColors.warning),
      _FunnelStage('Customers', 23, 23 / 5200, AppColors.success),
    ];

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Conversion Funnel', style: AppTypography.titleMedium),
          const SizedBox(height: AppSpacing.md),
          ...stages.map((s) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(s.label, style: AppTypography.bodySmall),
                        Text(
                          s.count.toString(),
                          style: AppTypography.titleSmall,
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: s.ratio,
                        backgroundColor: AppColors.borderLight,
                        valueColor:
                            AlwaysStoppedAnimation<Color>(s.color),
                        minHeight: 10,
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }
}

class _FunnelStage {
  final String label;
  final int count;
  final double ratio;
  final Color color;

  const _FunnelStage(this.label, this.count, this.ratio, this.color);
}
