import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/widgets/app_shell.dart';
import '../../../../core/widgets/app_widgets.dart';

class PipelinesPage extends StatelessWidget {
  const PipelinesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return AppShell(
      currentRoute: '/pipelines',
      pageTitle: 'Pipelines',
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.contentPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text('Sales Pipeline', style: AppTypography.headlineSmall),
                const Spacer(),
                GoldButton(
                  label: 'Add Stage',
                  icon: Icons.add,
                  onTap: () {},
                  small: true,
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      _KanbanColumn(
                        title: 'New Leads',
                        count: 24,
                        color: AppColors.chart1,
                        deals: [
                          _KanbanDeal('ACME Corp', '£12,000', 'Sarah J.'),
                          _KanbanDeal('Tech Startup', '£8,500', 'David W.'),
                          _KanbanDeal('Media Group', '£22,000', 'James B.'),
                        ],
                      ),
                      SizedBox(width: AppSpacing.md),
                      _KanbanColumn(
                        title: 'Contacted',
                        count: 18,
                        color: AppColors.gold,
                        deals: [
                          _KanbanDeal('Design Agency', '£15,000', 'Emily D.'),
                          _KanbanDeal('Retail Chain', '£45,000', 'Michael W.'),
                          _KanbanDeal('FinTech Ltd', '£28,000', 'Jessica T.'),
                        ],
                      ),
                      SizedBox(width: AppSpacing.md),
                      _KanbanColumn(
                        title: 'Qualified',
                        count: 12,
                        color: AppColors.info,
                        deals: [
                          _KanbanDeal('Enterprise Co', '£96,000', 'Alex B.'),
                          _KanbanDeal('Scale.io', '£34,500', 'Robert M.'),
                        ],
                      ),
                      SizedBox(width: AppSpacing.md),
                      _KanbanColumn(
                        title: 'Proposal',
                        count: 8,
                        color: AppColors.warning,
                        deals: [
                          _KanbanDeal('NextGen', '£96,000', 'Alex B.'),
                          _KanbanDeal('ACME Solutions', '£45,000', 'Alex B.'),
                        ],
                      ),
                      SizedBox(width: AppSpacing.md),
                      _KanbanColumn(
                        title: 'Won',
                        count: 5,
                        color: AppColors.success,
                        deals: [
                          _KanbanDeal('Design Co.', '£22,500', 'Alex B.'),
                          _KanbanDeal('Synergy CRM', '£62,000', 'Alex B.'),
                        ],
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _KanbanDeal {
  final String name;
  final String value;
  final String owner;

  const _KanbanDeal(this.name, this.value, this.owner);
}

class _KanbanColumn extends StatelessWidget {
  final String title;
  final int count;
  final Color color;
  final List<_KanbanDeal> deals;

  const _KanbanColumn({
    required this.title,
    required this.count,
    required this.color,
    required this.deals,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                border: Border(bottom: BorderSide(color: AppColors.border)),
              ),
              child: Row(
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(title, style: AppTypography.titleSmall),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '$count',
                      style: AppTypography.labelSmall.copyWith(
                        color: color,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(AppSpacing.sm),
                children: [
                  ...deals.map((d) => _DealCard(deal: d, color: color)),
                  const SizedBox(height: 8),
                  DottedAddButton(onTap: () {}),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DealCard extends StatelessWidget {
  final _KanbanDeal deal;
  final Color color;

  const _DealCard({required this.deal, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadowColor,
            blurRadius: 4,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(deal.name, style: AppTypography.titleSmall),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(deal.value,
                  style: AppTypography.bodySmall
                      .copyWith(color: AppColors.gold, fontWeight: FontWeight.w600)),
              Text(deal.owner, style: AppTypography.caption),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(3),
            child: LinearProgressIndicator(
              value: 0.6,
              backgroundColor: AppColors.borderLight,
              valueColor: AlwaysStoppedAnimation<Color>(color),
              minHeight: 4,
            ),
          ),
        ],
      ),
    );
  }
}

class DottedAddButton extends StatelessWidget {
  final VoidCallback onTap;

  const DottedAddButton({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 40,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: AppColors.border,
            style: BorderStyle.solid,
          ),
        ),
        child: const Center(
          child: Icon(Icons.add, size: 18, color: AppColors.textTertiary),
        ),
      ),
    );
  }
}
