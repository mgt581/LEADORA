import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/widgets/app_shell.dart';
import '../../../../core/widgets/app_widgets.dart';

class WebsiteAuditsPage extends StatelessWidget {
  const WebsiteAuditsPage({super.key});

  static const List<_Audit> _audits = [
    _Audit(url: 'designco.com', score: 94, seo: 96, performance: 91, accessibility: 98, issues: 3),
    _Audit(url: 'techflow.io', score: 78, seo: 82, performance: 71, accessibility: 88, issues: 12),
    _Audit(url: 'marketplus.net', score: 65, seo: 70, performance: 58, accessibility: 74, issues: 21),
    _Audit(url: 'brightidea.co.uk', score: 88, seo: 90, performance: 86, accessibility: 92, issues: 6),
    _Audit(url: 'nextgensolutions.com', score: 72, seo: 68, performance: 76, accessibility: 80, issues: 15),
  ];

  @override
  Widget build(BuildContext context) {
    return AppShell(
      currentRoute: '/website-audits',
      pageTitle: 'Website Audits',
      topBarActions: [
        GoldButton(
          label: 'New Audit',
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
                  title: 'Audits Run',
                  value: '48',
                  change: '+8 this month',
                  isPositive: true,
                  icon: Icons.web_outlined,
                ),
                StatCard(
                  title: 'Avg. Score',
                  value: '79',
                  icon: Icons.analytics_outlined,
                  iconColor: AppColors.info,
                  iconBgColor: AppColors.infoLight,
                ),
                StatCard(
                  title: 'Critical Issues',
                  value: '14',
                  change: '-3 resolved',
                  isPositive: true,
                  icon: Icons.warning_outlined,
                  iconColor: AppColors.error,
                  iconBgColor: AppColors.errorLight,
                ),
                StatCard(
                  title: 'Sites Monitored',
                  value: '23',
                  icon: Icons.monitor_outlined,
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
                          Text('Recent Audits',
                              style: AppTypography.titleMedium),
                          const Spacer(),
                          OutlinedButton.icon(
                            onPressed: () {},
                            icon: const Icon(Icons.refresh_outlined, size: 14),
                            label: const Text('Refresh All'),
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
                          'Website',
                          'Overall Score',
                          'SEO',
                          'Performance',
                          'Accessibility',
                          'Issues',
                        ],
                        columnWidths: const [200, 160, 100, 130, 130, 80],
                        rows: _audits
                            .map((a) => [
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
                                        child: const Icon(Icons.web_outlined,
                                            size: 14,
                                            color: AppColors.gold),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(a.url,
                                          style: AppTypography.titleSmall),
                                    ],
                                  ),
                                  _ScoreBar(score: a.score),
                                  Text('${a.seo}',
                                      style: AppTypography.bodySmall),
                                  Text('${a.performance}',
                                      style: AppTypography.bodySmall),
                                  Text('${a.accessibility}',
                                      style: AppTypography.bodySmall),
                                  StatusBadge(
                                    label: '${a.issues} issues',
                                    color: a.issues > 10
                                        ? AppColors.error
                                        : a.issues > 5
                                            ? AppColors.warning
                                            : AppColors.success,
                                    bgColor: a.issues > 10
                                        ? AppColors.errorLight
                                        : a.issues > 5
                                            ? AppColors.warningLight
                                            : AppColors.successLight,
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

class _Audit {
  final String url;
  final int score;
  final int seo;
  final int performance;
  final int accessibility;
  final int issues;

  const _Audit({
    required this.url,
    required this.score,
    required this.seo,
    required this.performance,
    required this.accessibility,
    required this.issues,
  });
}

class _ScoreBar extends StatelessWidget {
  final int score;

  const _ScoreBar({required this.score});

  Color get _color {
    if (score >= 90) return AppColors.success;
    if (score >= 70) return AppColors.gold;
    return AppColors.error;
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: score / 100,
              backgroundColor: AppColors.borderLight,
              valueColor: AlwaysStoppedAnimation<Color>(_color),
              minHeight: 6,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          '$score',
          style: AppTypography.titleSmall.copyWith(color: _color),
        ),
      ],
    );
  }
}
