import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/widgets/app_shell.dart';
import '../../../../core/widgets/app_widgets.dart';

class DealsPage extends StatelessWidget {
  const DealsPage({super.key});

  static const List<_Deal> _deals = [
    _Deal(name: 'ACME Solutions', value: '£45,000', stage: 'Proposal', owner: 'Alex Bryant', closeDate: 'Aug 15', probability: 75),
    _Deal(name: 'TechFlow Enterprise', value: '£128,000', stage: 'Qualified', owner: 'Sarah Chen', closeDate: 'Sep 01', probability: 60),
    _Deal(name: 'Design Co. Annual', value: '£22,500', stage: 'Won', owner: 'Alex Bryant', closeDate: 'Jul 30', probability: 100),
    _Deal(name: 'MarketPlus Starter', value: '£8,400', stage: 'New', owner: 'James Reid', closeDate: 'Aug 30', probability: 30),
    _Deal(name: 'NextGen Platform', value: '£96,000', stage: 'Proposal', owner: 'Alex Bryant', closeDate: 'Sep 15', probability: 65),
    _Deal(name: 'Bright Idea Suite', value: '£18,000', stage: 'Contacted', owner: 'Sarah Chen', closeDate: 'Oct 01', probability: 45),
    _Deal(name: 'Scale.io Growth', value: '£34,500', stage: 'Qualified', owner: 'James Reid', closeDate: 'Aug 20', probability: 55),
    _Deal(name: 'Synergy CRM', value: '£62,000', stage: 'Won', owner: 'Alex Bryant', closeDate: 'Jul 21', probability: 100),
  ];

  @override
  Widget build(BuildContext context) {
    final totalValue = _deals.fold<double>(
      0,
      (sum, d) =>
          sum +
          double.parse(d.value
              .replaceAll('£', '')
              .replaceAll(',', '')),
    );

    return AppShell(
      currentRoute: '/deals',
      pageTitle: 'Deals',
      topBarActions: [
        GoldButton(
          label: 'New Deal',
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
              children: [
                const StatCard(
                  title: 'Total Deals',
                  value: '67',
                  icon: Icons.handshake_outlined,
                ),
                StatCard(
                  title: 'Pipeline Value',
                  value: '£${(totalValue / 1000).toStringAsFixed(0)}K',
                  change: '+22% this month',
                  isPositive: true,
                  icon: Icons.currency_pound_outlined,
                ),
                const StatCard(
                  title: 'Avg. Deal Size',
                  value: '£54K',
                  icon: Icons.analytics_outlined,
                  iconColor: AppColors.info,
                  iconBgColor: AppColors.infoLight,
                ),
                const StatCard(
                  title: 'Win Rate',
                  value: '34%',
                  change: '+4% vs last month',
                  isPositive: true,
                  icon: Icons.emoji_events_outlined,
                  iconColor: AppColors.success,
                  iconBgColor: AppColors.successLight,
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            Expanded(
              child: AppCard(
                padding: EdgeInsets.zero,
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(AppSpacing.cardPadding),
                      child: Row(
                        children: [
                          Text('All Deals', style: AppTypography.titleMedium),
                          const Spacer(),
                          OutlinedButton.icon(
                            onPressed: () {},
                            icon: const Icon(Icons.filter_list_outlined,
                                size: 14),
                            label: const Text('Filter'),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 8),
                              textStyle: AppTypography.labelMedium,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Divider(height: 1),
                    Expanded(
                      child: AppDataTable(
                        headers: const [
                          'Deal Name',
                          'Value',
                          'Stage',
                          'Owner',
                          'Close Date',
                          'Probability',
                        ],
                        columnWidths: const [180, 120, 110, 140, 120, 100],
                        rows: _deals
                            .map((d) => [
                                  Text(d.name,
                                      style: AppTypography.titleSmall,
                                      overflow: TextOverflow.ellipsis),
                                  Text(d.value,
                                      style: AppTypography.titleSmall),
                                  StatusBadge.fromStatus(d.stage),
                                  Text(d.owner,
                                      style: AppTypography.bodySmall),
                                  Text(d.closeDate,
                                      style: AppTypography.bodySmall),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(4),
                                          child: LinearProgressIndicator(
                                            value: d.probability / 100,
                                            backgroundColor:
                                                AppColors.borderLight,
                                            valueColor:
                                                AlwaysStoppedAnimation<Color>(
                                              d.probability == 100
                                                  ? AppColors.success
                                                  : AppColors.gold,
                                            ),
                                            minHeight: 6,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        '${d.probability}%',
                                        style: AppTypography.caption,
                                      ),
                                    ],
                                  ),
                                ])
                            .toList(),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Deal {
  final String name;
  final String value;
  final String stage;
  final String owner;
  final String closeDate;
  final int probability;

  const _Deal({
    required this.name,
    required this.value,
    required this.stage,
    required this.owner,
    required this.closeDate,
    required this.probability,
  });
}
