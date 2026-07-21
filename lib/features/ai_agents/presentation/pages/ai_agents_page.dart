import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/cards/app_card.dart';

class AiAgentsPage extends StatelessWidget {
  const AiAgentsPage({super.key});

  static const List<_Agent> _agents = [
    _Agent(
      'Lead Qualifier',
      'Automatically scores and qualifies new leads based on fit criteria.',
      Icons.person_search_rounded,
      AppColors.info,
      'Active',
      '1,284 leads processed',
      '94.2% accuracy',
    ),
    _Agent(
      'Email Personaliser',
      'Generates hyper-personalised email content for each prospect.',
      Icons.auto_fix_high_rounded,
      AppColors.gold,
      'Active',
      '8,472 emails written',
      '67.4% open rate',
    ),
    _Agent(
      'Meeting Scheduler',
      'Books meetings automatically based on prospect intent signals.',
      Icons.calendar_today_rounded,
      AppColors.success,
      'Active',
      '312 meetings booked',
      '78.1% show rate',
    ),
    _Agent(
      'Deal Forecaster',
      'Predicts deal close probability using historical data patterns.',
      Icons.analytics_rounded,
      AppColors.badgeProposal,
      'Active',
      '523 deals scored',
      '±8% margin of error',
    ),
    _Agent(
      'Churn Detector',
      'Identifies at-risk accounts and triggers retention workflows.',
      Icons.warning_amber_rounded,
      AppColors.error,
      'Paused',
      '89 accounts flagged',
      '88.6% precision',
    ),
    _Agent(
      'Content Generator',
      'Creates blog posts, case studies and social content at scale.',
      Icons.edit_note_rounded,
      AppColors.badgeNew,
      'Active',
      '214 pieces created',
      '4.2 min avg.',
    ),
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
                  title: 'AI Agents',
                  subtitle: 'Deploy autonomous AI agents to automate your sales process.',
                ),
              ),
              PrimaryButton(
                label: 'Deploy Agent',
                icon: Icons.add_rounded,
                onPressed: () {},
              ),
            ],
          ),

          const SizedBox(height: 4),

          // Promo banner
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF0D0D0D), Color(0xFF1A1A1A)],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppColors.gold.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.smart_toy_rounded, size: 24, color: AppColors.gold),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        'Your AI agents are running 24/7',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Automated 2,483 tasks this week — saving 146 hours of manual work.',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 13,
                          color: AppColors.sidebarText,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 20),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Text(
                      '146h',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                        color: AppColors.gold,
                      ),
                    ),
                    const Text(
                      'saved this week',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 11,
                        color: AppColors.sidebarText,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          LayoutBuilder(builder: (context, constraints) {
            final cardWidth = (constraints.maxWidth - 20) / 2;
            return Wrap(
              spacing: 20,
              runSpacing: 20,
              children: _agents.map((a) => SizedBox(
                width: cardWidth,
                child: _AgentCard(agent: a),
              )).toList(),
            );
          }),
        ],
      ),
    );
  }
}

class _AgentCard extends StatefulWidget {
  final _Agent agent;
  const _AgentCard({required this.agent});

  @override
  State<_AgentCard> createState() => _AgentCardState();
}

class _AgentCardState extends State<_AgentCard> {
  bool _active = true;

  @override
  void initState() {
    super.initState();
    _active = widget.agent.status == 'Active';
  }

  @override
  Widget build(BuildContext context) {
    final a = widget.agent;
    return AppCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: a.color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(a.icon, size: 22, color: a.color),
              ),
              const Spacer(),
              Switch(
                value: _active,
                onChanged: (v) => setState(() => _active = v),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            a.name,
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            a.description,
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 12,
              color: AppColors.textSecondary,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 16),
          const Divider(height: 1),
          const SizedBox(height: 12),
          Row(
            children: [
              _Metric(label: a.metric1),
              const SizedBox(width: 16),
              _Metric(label: a.metric2),
            ],
          ),
        ],
      ),
    );
  }
}

class _Metric extends StatelessWidget {
  final String label;
  const _Metric({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.contentBg,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontFamily: 'Inter',
          fontSize: 11,
          fontWeight: FontWeight.w500,
          color: AppColors.textSecondary,
        ),
      ),
    );
  }
}

class _Agent {
  final String name;
  final String description;
  final IconData icon;
  final Color color;
  final String status;
  final String metric1;
  final String metric2;
  const _Agent(this.name, this.description, this.icon, this.color, this.status, this.metric1, this.metric2);
}
