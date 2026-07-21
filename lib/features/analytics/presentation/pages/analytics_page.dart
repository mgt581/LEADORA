import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/cards/app_card.dart';
import '../../../../core/widgets/charts/chart_widgets.dart';

class AnalyticsPage extends StatelessWidget {
  const AnalyticsPage({super.key});

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
                  title: 'Analytics',
                  subtitle: 'Deep insights into your pipeline and performance.',
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
                    Text('Jul 14 – Jul 21, 2024', style: TextStyle(fontFamily: 'Inter', fontSize: 13, color: AppColors.textSecondary)),
                    SizedBox(width: 4),
                    Icon(Icons.keyboard_arrow_down_rounded, size: 14, color: AppColors.textSecondary),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 4),

          // KPI row
          Row(
            children: const [
              Expanded(child: StatCard(
                title: 'Total Leads',
                value: '248',
                delta: '+16% vs last period',
                deltaPositive: true,
                icon: Icons.person_search_rounded,
                iconColor: AppColors.info,
                iconBackground: AppColors.infoSurface,
              )),
              SizedBox(width: 16),
              Expanded(child: StatCard(
                title: 'Conversions',
                value: '23',
                delta: '+9% vs last period',
                deltaPositive: true,
                icon: Icons.trending_up_rounded,
                iconColor: AppColors.success,
                iconBackground: AppColors.successSurface,
              )),
              SizedBox(width: 16),
              Expanded(child: StatCard(
                title: 'Conversion Rate',
                value: '9.3%',
                delta: '+2.1% vs last period',
                deltaPositive: true,
                icon: Icons.percent_rounded,
                iconColor: AppColors.gold,
                iconBackground: AppColors.goldSurface,
              )),
              SizedBox(width: 16),
              Expanded(child: StatCard(
                title: 'Revenue',
                value: '£12,540',
                delta: '+22% vs last period',
                deltaPositive: true,
                icon: Icons.attach_money_rounded,
              )),
            ],
          ),

          const SizedBox(height: 24),

          // Main charts
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

          const SizedBox(height: 20),

          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: BarChartCard(
                  title: 'Monthly Revenue (£k)',
                  values: [42, 38, 55, 61, 48, 72, 84, 67, 91, 78, 95, 88],
                  labels: ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'],
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: BarChartCard(
                  title: 'Emails Sent by Day',
                  values: [120, 185, 148, 224, 196, 85, 62, 178, 215, 189, 241, 167, 198, 221],
                  labels: ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'],
                  barColor: AppColors.info,
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Conversion funnel
          FunnelCard(
            title: 'Conversion Funnel',
            stages: const [
              FunnelStage(label: 'Visitors', count: 8420, color: AppColors.badgeNew),
              FunnelStage(label: 'Leads', count: 248, color: AppColors.badgeContacted),
              FunnelStage(label: 'Qualified', count: 89, color: AppColors.badgeQualified),
              FunnelStage(label: 'Proposal', count: 43, color: AppColors.badgeProposal),
              FunnelStage(label: 'Customers', count: 23, color: AppColors.badgeWon),
            ],
          ),
        ],
      ),
    );
  }
}
