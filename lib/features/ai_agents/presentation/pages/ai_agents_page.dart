import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/widgets/app_shell.dart';
import '../../../../core/widgets/app_widgets.dart';

class AiAgentsPage extends StatelessWidget {
  const AiAgentsPage({super.key});

  static const List<_Agent> _agents = [
    _Agent(
      name: 'Lead Qualifier',
      description: 'Automatically qualifies incoming leads based on ICP criteria',
      status: 'Active',
      runs: 1248,
      successRate: 94,
      icon: Icons.person_search_outlined,
    ),
    _Agent(
      name: 'Email Writer',
      description: 'Generates personalised outreach emails using prospect data',
      status: 'Active',
      runs: 862,
      successRate: 88,
      icon: Icons.edit_note_outlined,
    ),
    _Agent(
      name: 'Meeting Scheduler',
      description: 'Books discovery calls based on lead engagement signals',
      status: 'Active',
      runs: 324,
      successRate: 91,
      icon: Icons.calendar_month_outlined,
    ),
    _Agent(
      name: 'Follow-up Agent',
      description: 'Sends timely follow-ups to unresponsive prospects',
      status: 'Paused',
      runs: 540,
      successRate: 76,
      icon: Icons.replay_outlined,
    ),
    _Agent(
      name: 'CRM Enrichment',
      description: 'Enriches contact records with public data sources',
      status: 'Active',
      runs: 2840,
      successRate: 97,
      icon: Icons.auto_fix_high_outlined,
    ),
    _Agent(
      name: 'Churn Predictor',
      description: 'Flags at-risk accounts before they churn',
      status: 'Draft',
      runs: 0,
      successRate: 0,
      icon: Icons.warning_amber_outlined,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return AppShell(
      currentRoute: '/ai-agents',
      pageTitle: 'AI Agents',
      topBarActions: [
        GoldButton(
          label: 'New Agent',
          icon: Icons.add,
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
            GridView.count(
              crossAxisCount: 4,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: AppSpacing.md,
              mainAxisSpacing: AppSpacing.md,
              childAspectRatio: 2.2,
              children: const [
                StatCard(
                  title: 'Active Agents',
                  value: '4',
                  icon: Icons.smart_toy_outlined,
                ),
                StatCard(
                  title: 'Total Runs',
                  value: '5,814',
                  change: '+24% this week',
                  isPositive: true,
                  icon: Icons.play_circle_outline,
                  iconColor: AppColors.info,
                  iconBgColor: AppColors.infoLight,
                ),
                StatCard(
                  title: 'Avg. Success Rate',
                  value: '89%',
                  change: '+3% vs last week',
                  isPositive: true,
                  icon: Icons.check_circle_outline,
                  iconColor: AppColors.success,
                  iconBgColor: AppColors.successLight,
                ),
                StatCard(
                  title: 'Time Saved',
                  value: '48h',
                  change: 'This week',
                  isPositive: true,
                  icon: Icons.timer_outlined,
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            Text('Your Agents', style: AppTypography.titleLarge),
            const SizedBox(height: AppSpacing.md),
            GridView.count(
              crossAxisCount: 3,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: AppSpacing.md,
              mainAxisSpacing: AppSpacing.md,
              childAspectRatio: 2.2,
              children:
                  _agents.map((a) => _AgentCard(agent: a)).toList(),
            ),
          ],
        ),
      ),
    );
  }
}

class _Agent {
  final String name;
  final String description;
  final String status;
  final int runs;
  final int successRate;
  final IconData icon;

  const _Agent({
    required this.name,
    required this.description,
    required this.status,
    required this.runs,
    required this.successRate,
    required this.icon,
  });
}

class _AgentCard extends StatefulWidget {
  final _Agent agent;

  const _AgentCard({required this.agent});

  @override
  State<_AgentCard> createState() => _AgentCardState();
}

class _AgentCardState extends State<_AgentCard> {
  bool _enabled = true;

  @override
  Widget build(BuildContext context) {
    final a = widget.agent;
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppColors.goldSurface,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(a.icon, size: 18, color: AppColors.gold),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(a.name, style: AppTypography.titleSmall),
                    StatusBadge(
                      label: a.status,
                      color: a.status == 'Active'
                          ? AppColors.success
                          : a.status == 'Paused'
                              ? AppColors.warning
                              : AppColors.textTertiary,
                      bgColor: a.status == 'Active'
                          ? AppColors.successLight
                          : a.status == 'Paused'
                              ? AppColors.warningLight
                              : AppColors.borderLight,
                    ),
                  ],
                ),
              ),
              if (a.status != 'Draft')
                Switch(
                  value: _enabled && a.status == 'Active',
                  onChanged: (v) => setState(() => _enabled = v),
                  activeColor: AppColors.gold,
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            a.description,
            style: AppTypography.caption,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          if (a.runs > 0) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                _AgentStat(label: '${a.runs}', sublabel: 'Runs'),
                const SizedBox(width: 16),
                _AgentStat(
                    label: '${a.successRate}%', sublabel: 'Success'),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _AgentStat extends StatelessWidget {
  final String label;
  final String sublabel;

  const _AgentStat({required this.label, required this.sublabel});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: AppTypography.titleSmall.copyWith(color: AppColors.gold)),
        Text(sublabel, style: AppTypography.caption),
      ],
    );
  }
}
