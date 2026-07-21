import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/widgets/app_shell.dart';
import '../../../../core/widgets/app_widgets.dart';

class AutomationsPage extends StatelessWidget {
  const AutomationsPage({super.key});

  static const List<_Automation> _automations = [
    _Automation(
      name: 'New Lead Welcome',
      trigger: 'When a new lead is created',
      status: 'Active',
      runs: 124,
      openRate: 88,
      icon: Icons.waving_hand_outlined,
      color: AppColors.gold,
    ),
    _Automation(
      name: 'Follow Up Sequence',
      trigger: 'Follow up with leads',
      status: 'Active',
      runs: 98,
      openRate: 72,
      icon: Icons.replay_outlined,
      color: AppColors.info,
    ),
    _Automation(
      name: 'Re-engagement Campaign',
      trigger: 'Win back inactive leads',
      status: 'Active',
      runs: 64,
      openRate: 45,
      icon: Icons.refresh_outlined,
      color: AppColors.success,
    ),
    _Automation(
      name: 'Deal Won Celebration',
      trigger: 'Celebrate new customers',
      status: 'Active',
      runs: 23,
      openRate: 100,
      icon: Icons.celebration_outlined,
      color: AppColors.warning,
    ),
    _Automation(
      name: 'Onboarding Drip',
      trigger: 'New customer signs up',
      status: 'Draft',
      runs: 0,
      openRate: 0,
      icon: Icons.start_outlined,
      color: AppColors.chart1,
    ),
    _Automation(
      name: 'Churned Account Alert',
      trigger: 'Account inactive for 30 days',
      status: 'Paused',
      runs: 12,
      openRate: 34,
      icon: Icons.notifications_outlined,
      color: AppColors.error,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return AppShell(
      currentRoute: '/automations',
      pageTitle: 'Automations',
      topBarActions: [
        GoldButton(
          label: 'New Automation',
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
            Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Automations', style: AppTypography.headlineSmall),
                    Text('Create workflows that work for you.',
                        style: AppTypography.bodySmall),
                  ],
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            Expanded(
              child: AppCard(
                padding: EdgeInsets.zero,
                child: AppDataTable(
                  headers: const [
                    'Automation',
                    'Status',
                    'Runs',
                    'Open Rate',
                    '',
                  ],
                  columnWidths: const [240, 100, 100, 200, 80],
                  rows: _automations
                      .map((a) => [
                            Row(
                              children: [
                                Container(
                                  width: 36,
                                  height: 36,
                                  decoration: BoxDecoration(
                                    color: a.color.withOpacity(0.12),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Icon(a.icon,
                                      size: 18, color: a.color),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(a.name,
                                          style: AppTypography.titleSmall,
                                          overflow: TextOverflow.ellipsis),
                                      Text(a.trigger,
                                          style: AppTypography.caption,
                                          overflow: TextOverflow.ellipsis),
                                    ],
                                  ),
                                ),
                              ],
                            ),
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
                            Text(
                              a.runs == 0 ? '-' : '${a.runs}',
                              style: AppTypography.bodySmall,
                            ),
                            a.openRate == 0
                                ? Text('-',
                                    style: AppTypography.bodySmall)
                                : Row(
                                    children: [
                                      Expanded(
                                        child: ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(4),
                                          child: LinearProgressIndicator(
                                            value: a.openRate / 100,
                                            backgroundColor:
                                                AppColors.borderLight,
                                            valueColor:
                                                AlwaysStoppedAnimation<
                                                    Color>(a.color),
                                            minHeight: 6,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Text('${a.openRate}%',
                                          style: AppTypography.caption),
                                    ],
                                  ),
                            _ToggleSwitch(
                              enabled: a.status == 'Active',
                              color: a.color,
                            ),
                          ])
                      .toList(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Automation {
  final String name;
  final String trigger;
  final String status;
  final int runs;
  final int openRate;
  final IconData icon;
  final Color color;

  const _Automation({
    required this.name,
    required this.trigger,
    required this.status,
    required this.runs,
    required this.openRate,
    required this.icon,
    required this.color,
  });
}

class _ToggleSwitch extends StatefulWidget {
  final bool enabled;
  final Color color;

  const _ToggleSwitch({required this.enabled, required this.color});

  @override
  State<_ToggleSwitch> createState() => _ToggleSwitchState();
}

class _ToggleSwitchState extends State<_ToggleSwitch> {
  late bool _value;

  @override
  void initState() {
    super.initState();
    _value = widget.enabled;
  }

  @override
  Widget build(BuildContext context) {
    return Switch(
      value: _value,
      onChanged: (v) => setState(() => _value = v),
      activeColor: widget.color,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }
}
