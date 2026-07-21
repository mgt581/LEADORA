import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/cards/app_card.dart';

class AutomationsPage extends StatelessWidget {
  const AutomationsPage({super.key});

  static const List<_Automation> _automations = [
    _Automation(
      'New Lead Welcome',
      'When a new lead is created',
      124,
      '88%',
      true,
      Icons.person_add_rounded,
      AppColors.info,
    ),
    _Automation(
      'Follow Up Sequence',
      'Follow up with leads',
      98,
      '72%',
      true,
      Icons.replay_rounded,
      AppColors.gold,
    ),
    _Automation(
      'Re-engagement Campaign',
      'Win back inactive leads',
      64,
      '45%',
      false,
      Icons.refresh_rounded,
      AppColors.warning,
    ),
    _Automation(
      'Deal Won Celebration',
      'Celebrate new customers',
      23,
      '100%',
      true,
      Icons.celebration_rounded,
      AppColors.success,
    ),
    _Automation(
      'Proposal Follow-up',
      'After proposal is sent',
      47,
      '61%',
      true,
      Icons.description_rounded,
      AppColors.badgeNew,
    ),
    _Automation(
      'Onboarding Sequence',
      'New customer onboarding',
      88,
      '94%',
      true,
      Icons.rocket_launch_rounded,
      AppColors.success,
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
                  title: 'Automations',
                  subtitle: 'Create workflows that work for you.',
                ),
              ),
              PrimaryButton(
                label: 'New Automation',
                icon: Icons.add_rounded,
                onPressed: () {},
              ),
            ],
          ),

          const SizedBox(height: 4),

          Row(
            children: const [
              _AutoStatCard(label: 'Active Automations', value: '12', icon: Icons.bolt_rounded, color: AppColors.gold),
              SizedBox(width: 16),
              _AutoStatCard(label: 'Actions This Week', value: '2,847', icon: Icons.play_circle_outlined, color: AppColors.info),
              SizedBox(width: 16),
              _AutoStatCard(label: 'Hours Saved', value: '146h', icon: Icons.schedule_outlined, color: AppColors.success),
              SizedBox(width: 16),
              _AutoStatCard(label: 'Success Rate', value: '94.2%', icon: Icons.check_circle_outline_rounded, color: AppColors.badgeQualified),
            ],
          ),

          const SizedBox(height: 24),

          AppCard(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      const SearchField(hint: 'Search automations...'),
                      const Spacer(),
                      SecondaryButton(
                        label: 'Filter',
                        icon: Icons.tune_rounded,
                        onPressed: () {},
                        small: true,
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1),
                ..._automations.asMap().entries.map((e) => Column(
                      children: [
                        _AutomationRow(automation: e.value),
                        if (e.key < _automations.length - 1) const Divider(height: 1),
                      ],
                    )),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AutoStatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  const _AutoStatCard({required this.label, required this.value, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: AppCard(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, size: 20, color: color),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(value, style: const TextStyle(fontFamily: 'Inter', fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                Text(label, style: const TextStyle(fontFamily: 'Inter', fontSize: 11, color: AppColors.textSecondary)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _AutomationRow extends StatefulWidget {
  final _Automation automation;
  const _AutomationRow({required this.automation});

  @override
  State<_AutomationRow> createState() => _AutomationRowState();
}

class _AutomationRowState extends State<_AutomationRow> {
  late bool _enabled;

  @override
  void initState() {
    super.initState();
    _enabled = widget.automation.enabled;
  }

  @override
  Widget build(BuildContext context) {
    final a = widget.automation;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: a.color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(a.icon, size: 20, color: a.color),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  a.name,
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  a.trigger,
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 24),
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                a.runs.toString(),
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const Text(
                'Active',
                style: TextStyle(fontFamily: 'Inter', fontSize: 10, color: AppColors.textTertiary),
              ),
            ],
          ),
          const SizedBox(width: 24),
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                a.openRate,
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const Text(
                'Open Rate',
                style: TextStyle(fontFamily: 'Inter', fontSize: 10, color: AppColors.textTertiary),
              ),
            ],
          ),
          const SizedBox(width: 24),
          Switch(
            value: _enabled,
            onChanged: (v) => setState(() => _enabled = v),
          ),
        ],
      ),
    );
  }
}

class _Automation {
  final String name;
  final String trigger;
  final int runs;
  final String openRate;
  final bool enabled;
  final IconData icon;
  final Color color;
  const _Automation(this.name, this.trigger, this.runs, this.openRate, this.enabled, this.icon, this.color);
}
