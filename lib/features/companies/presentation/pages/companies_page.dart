import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/widgets/app_shell.dart';
import '../../../../core/widgets/app_widgets.dart';

class CompaniesPage extends StatelessWidget {
  const CompaniesPage({super.key});

  static const List<_Company> _companies = [
    _Company(name: 'Design Co.', industry: 'Creative', employees: '12', revenue: '£450K', status: 'Active', location: 'London'),
    _Company(name: 'TechFlow', industry: 'Technology', employees: '85', revenue: '£2.1M', status: 'Active', location: 'Manchester'),
    _Company(name: 'MarketPlus', industry: 'Marketing', employees: '34', revenue: '£890K', status: 'Active', location: 'Birmingham'),
    _Company(name: 'Bright Idea', industry: 'Consulting', employees: '8', revenue: '£320K', status: 'Prospect', location: 'Bristol'),
    _Company(name: 'NextGen', industry: 'SaaS', employees: '120', revenue: '£5.4M', status: 'Active', location: 'London'),
    _Company(name: 'Creative Lab', industry: 'Design', employees: '22', revenue: '£670K', status: 'Active', location: 'Leeds'),
    _Company(name: 'Scale.io', industry: 'Technology', employees: '45', revenue: '£1.2M', status: 'Active', location: 'Edinburgh'),
    _Company(name: 'Synergy Co.', industry: 'Finance', employees: '67', revenue: '£3.2M', status: 'Prospect', location: 'London'),
  ];

  @override
  Widget build(BuildContext context) {
    return AppShell(
      currentRoute: '/companies',
      pageTitle: 'Companies',
      topBarActions: [
        GoldButton(
          label: 'Add Company',
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
                  title: 'Total Companies',
                  value: '284',
                  icon: Icons.business_outlined,
                ),
                StatCard(
                  title: 'Active Accounts',
                  value: '196',
                  change: '+12% this month',
                  isPositive: true,
                  icon: Icons.trending_up,
                  iconColor: AppColors.success,
                  iconBgColor: AppColors.successLight,
                ),
                StatCard(
                  title: 'Total Revenue',
                  value: '£14.2M',
                  change: '+8% vs last month',
                  isPositive: true,
                  icon: Icons.currency_pound_outlined,
                ),
                StatCard(
                  title: 'Avg. Deal Size',
                  value: '£48K',
                  icon: Icons.bar_chart_outlined,
                  iconColor: AppColors.info,
                  iconBgColor: AppColors.infoLight,
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
                          Text('All Companies',
                              style: AppTypography.titleMedium),
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
                          'Company',
                          'Industry',
                          'Employees',
                          'Revenue',
                          'Status',
                          'Location',
                        ],
                        columnWidths: const [180, 140, 100, 120, 110, 120],
                        rows: _companies
                            .map((c) => [
                                  Row(
                                    children: [
                                      Container(
                                        width: 28,
                                        height: 28,
                                        decoration: BoxDecoration(
                                          color: AppColors.goldSurface,
                                          borderRadius:
                                              BorderRadius.circular(6),
                                        ),
                                        child: Center(
                                          child: Text(
                                            c.name[0],
                                            style: const TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w700,
                                              color: AppColors.gold,
                                            ),
                                          ),
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
                                  Text(c.industry,
                                      style: AppTypography.bodySmall),
                                  Text(c.employees,
                                      style: AppTypography.bodySmall),
                                  Text(c.revenue,
                                      style: AppTypography.titleSmall),
                                  StatusBadge(
                                    label: c.status,
                                    color: c.status == 'Active'
                                        ? AppColors.success
                                        : AppColors.gold,
                                    bgColor: c.status == 'Active'
                                        ? AppColors.successLight
                                        : AppColors.goldSurface,
                                  ),
                                  Text(c.location,
                                      style: AppTypography.bodySmall),
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

class _Company {
  final String name;
  final String industry;
  final String employees;
  final String revenue;
  final String status;
  final String location;

  const _Company({
    required this.name,
    required this.industry,
    required this.employees,
    required this.revenue,
    required this.status,
    required this.location,
  });
}
