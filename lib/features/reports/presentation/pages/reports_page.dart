import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/cards/app_card.dart';
import '../../../../core/widgets/charts/chart_widgets.dart';

class ReportsPage extends StatelessWidget {
  const ReportsPage({super.key});

  static const List<_Report> _savedReports = [
    _Report('Weekly Performance', 'Sales', 'Jul 21, 2024', Icons.bar_chart_rounded),
    _Report('Lead Source Analysis', 'Marketing', 'Jul 20, 2024', Icons.pie_chart_rounded),
    _Report('Revenue Forecast Q3', 'Finance', 'Jul 18, 2024', Icons.trending_up_rounded),
    _Report('Email Campaign Results', 'Marketing', 'Jul 17, 2024', Icons.mark_email_read_rounded),
    _Report('Pipeline Health Check', 'Sales', 'Jul 15, 2024', Icons.account_tree_rounded),
    _Report('Customer Acquisition Cost', 'Finance', 'Jul 14, 2024', Icons.monetization_on_rounded),
  ];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: SectionHeader(
                  title: 'Reports',
                  subtitle: 'Track your performance and growth.',
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
                    Text('Jul 14 – Jul 21, 2024',
                        style: TextStyle(fontFamily: 'Inter', fontSize: 13, color: AppColors.textSecondary)),
                    SizedBox(width: 4),
                    Icon(Icons.keyboard_arrow_down_rounded, size: 14, color: AppColors.textSecondary),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              PrimaryButton(
                label: 'New Report',
                icon: Icons.add_rounded,
                onPressed: () {},
              ),
            ],
          ),

          const SizedBox(height: 4),

          // KPI metrics
          Row(
            children: const [
              Expanded(child: StatCard(
                title: 'Total Leads',
                value: '248',
                delta: '+16%',
                deltaPositive: true,
                icon: Icons.person_search_rounded,
                iconColor: AppColors.info,
                iconBackground: AppColors.infoSurface,
              )),
              SizedBox(width: 16),
              Expanded(child: StatCard(
                title: 'Conversions',
                value: '23',
                delta: '+9%',
                deltaPositive: true,
                icon: Icons.trending_up_rounded,
                iconColor: AppColors.success,
                iconBackground: AppColors.successSurface,
              )),
              SizedBox(width: 16),
              Expanded(child: StatCard(
                title: 'Conversion Rate',
                value: '9.3%',
                delta: '+2.1%',
                deltaPositive: true,
                icon: Icons.percent_rounded,
              )),
              SizedBox(width: 16),
              Expanded(child: StatCard(
                title: 'Revenue',
                value: '£12,540',
                delta: '+22%',
                deltaPositive: true,
                icon: Icons.attach_money_rounded,
              )),
            ],
          ),

          const SizedBox(height: 24),

          // Charts row
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 3,
                child: TrendLineChart(
                  title: 'Leads Over Time',
                  values: [42, 58, 35, 72, 89, 64, 95, 48, 76, 83, 67, 91, 55, 78],
                  labels: ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'],
                  period: 'Last 7 days',
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                flex: 2,
                child: DonutChartCard(
                  title: 'Leads by Source',
                  centerLabel: 'Total',
                  centerValue: '248',
                  sections: [
                    DonutSection(label: 'Website', value: 42, color: AppColors.gold),
                    DonutSection(label: 'LinkedIn', value: 28, color: AppColors.info),
                    DonutSection(label: 'Referral', value: 15, color: AppColors.success),
                    DonutSection(label: 'Ads', value: 10, color: AppColors.badgeProposal),
                    DonutSection(label: 'Other', value: 5, color: AppColors.textTertiary),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Saved reports
          const Text(
            'Saved Reports',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),

          LayoutBuilder(builder: (context, constraints) {
            final cardWidth = (constraints.maxWidth - 20) / 2;
            return Wrap(
              spacing: 20,
              runSpacing: 12,
              children: _savedReports.map((r) => SizedBox(
                width: cardWidth,
                child: _ReportCard(report: r),
              )).toList(),
            );
          }),
        ],
      ),
    );
  }
}

class _ReportCard extends StatelessWidget {
  final _Report report;
  const _ReportCard({required this.report});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(16),
      onTap: () {},
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.goldSurface,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(report.icon, size: 20, color: AppColors.gold),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  report.title,
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${report.category} · ${report.date}',
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 11,
                    color: AppColors.textTertiary,
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right_rounded, size: 18, color: AppColors.textTertiary),
        ],
      ),
    );
  }
}

class _Report {
  final String title;
  final String category;
  final String date;
  final IconData icon;
  const _Report(this.title, this.category, this.date, this.icon);
}
