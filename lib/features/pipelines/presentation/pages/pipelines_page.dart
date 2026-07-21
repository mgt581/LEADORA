import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/cards/app_card.dart';
import '../../../../core/widgets/charts/chart_widgets.dart';

class PipelinesPage extends StatelessWidget {
  const PipelinesPage({super.key});

  static const List<_PipelineStage> _stages = [
    _PipelineStage('New Leads', AppColors.badgeNew, AppColors.badgeNewSurface, [
      _PipelineCard('Pioneer Analytics', 'Amanda Lee', '£67,500', '20%'),
      _PipelineCard('Chris Anderson', 'VisionEx', '£14,000', '15%'),
    ]),
    _PipelineStage('Contacted', AppColors.badgeContacted, AppColors.badgeContactedSurface, [
      _PipelineCard('Bright Idea Audit', 'Emily Davis', '£8,900', '40%'),
      _PipelineCard('Jessica Taylor', 'Creative Lab', '£19,400', '35%'),
    ]),
    _PipelineStage('Qualified', AppColors.badgeQualified, AppColors.badgeQualifiedSurface, [
      _PipelineCard('TechFlow Enterprise', 'David Williams', '£128,000', '60%'),
      _PipelineCard('Amanda Lee', 'Pioneer Inc.', '£34,000', '55%'),
    ]),
    _PipelineStage('Proposal', AppColors.badgeProposal, AppColors.warningSurface, [
      _PipelineCard('ACME Solutions', 'Sarah Johnson', '£45,000', '80%'),
      _PipelineCard('NextGen Setup', 'Michael Wilson', '£31,700', '75%'),
    ]),
    _PipelineStage('Won', AppColors.badgeWon, AppColors.badgeWonSurface, [
      _PipelineCard('MarketPlus Retainer', 'James Brown', '£24,000', '100%'),
      _PipelineCard('FusionTech Platform', 'Robert Martinez', '£93,200', '100%'),
    ]),
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
                  title: 'Pipelines',
                  subtitle: 'Visual overview of your deal pipeline stages.',
                ),
              ),
              PrimaryButton(
                label: 'New Deal',
                icon: Icons.add_rounded,
                onPressed: () {},
              ),
            ],
          ),

          const SizedBox(height: 4),

          // Funnel overview
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 2,
                child: FunnelCard(
                  title: 'Pipeline Funnel',
                  stages: const [
                    FunnelStage(label: 'New Leads', count: 248, color: AppColors.badgeNew),
                    FunnelStage(label: 'Contacted', count: 166, color: AppColors.badgeContacted),
                    FunnelStage(label: 'Qualified', count: 89, color: AppColors.badgeQualified),
                    FunnelStage(label: 'Proposal', count: 43, color: AppColors.badgeProposal),
                    FunnelStage(label: 'Won', count: 23, color: AppColors.badgeWon),
                  ],
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                flex: 3,
                child: TrendLineChart(
                  title: 'Deal Velocity',
                  values: [12, 18, 15, 22, 19, 28, 24, 31, 27, 35, 30, 42, 38, 45],
                  labels: ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'],
                  period: 'This Week',
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Kanban board
          const Text(
            'Kanban Board',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),

          SizedBox(
            height: 480,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _stages.length,
              itemBuilder: (context, i) {
                final stage = _stages[i];
                return Container(
                  width: 240,
                  margin: EdgeInsets.only(right: i < _stages.length - 1 ? 16 : 0),
                  child: _KanbanColumn(stage: stage),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _KanbanColumn extends StatelessWidget {
  final _PipelineStage stage;
  const _KanbanColumn({required this.stage});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Column header
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: stage.surface,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(color: stage.color, shape: BoxShape.circle),
              ),
              const SizedBox(width: 8),
              Text(
                stage.label,
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: stage.color,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: stage.color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(100),
                ),
                child: Text(
                  stage.cards.length.toString(),
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: stage.color,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: ListView.builder(
            itemCount: stage.cards.length + 1,
            itemBuilder: (context, i) {
              if (i == stage.cards.length) {
                return Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: InkWell(
                    onTap: () {},
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      height: 36,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: AppColors.cardBorder,
                          style: BorderStyle.solid,
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(Icons.add_rounded, size: 14, color: AppColors.textTertiary),
                          SizedBox(width: 4),
                          Text(
                            'Add deal',
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 12,
                              color: AppColors.textTertiary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }
              final card = stage.cards[i];
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: AppCard(
                  padding: const EdgeInsets.all(14),
                  onTap: () {},
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        card.name,
                        style: const TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        card.contact,
                        style: const TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 11,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Text(
                            card.value,
                            style: const TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: AppColors.gold,
                            ),
                          ),
                          const Spacer(),
                          Text(
                            card.probability,
                            style: const TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 11,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _PipelineStage {
  final String label;
  final Color color;
  final Color surface;
  final List<_PipelineCard> cards;
  const _PipelineStage(this.label, this.color, this.surface, this.cards);
}

class _PipelineCard {
  final String name;
  final String contact;
  final String value;
  final String probability;
  const _PipelineCard(this.name, this.contact, this.value, this.probability);
}
