import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/widgets/app_shell.dart';
import '../../../../core/widgets/app_widgets.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  int _selectedSection = 0;

  final List<_SettingsSection> _sections = [
    _SettingsSection('Profile', Icons.person_outline),
    _SettingsSection('Team', Icons.group_outlined),
    _SettingsSection('Billing', Icons.credit_card_outlined),
    _SettingsSection('Gifting', Icons.card_giftcard_outlined),
    _SettingsSection('Preferences', Icons.tune_outlined),
    _SettingsSection('Security', Icons.lock_outline),
  ];

  @override
  Widget build(BuildContext context) {
    return AppShell(
      currentRoute: '/settings',
      pageTitle: 'Settings',
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.contentPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: _sections.asMap().entries.map((e) {
                final isActive = _selectedSection == e.key;
                return GestureDetector(
                  onTap: () => setState(() => _selectedSection = e.key),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    margin: const EdgeInsets.only(right: 4),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: isActive
                          ? AppColors.sidebarBg
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          e.value.icon,
                          size: 15,
                          color: isActive
                              ? AppColors.white
                              : AppColors.textSecondary,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          e.value.label,
                          style: AppTypography.labelMedium.copyWith(
                            color: isActive
                                ? AppColors.white
                                : AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: AppSpacing.lg),
            Expanded(
              child: _selectedSection == 5
                  ? _SecuritySettings()
                  : _selectedSection == 0
                      ? _ProfileSettings()
                      : _selectedSection == 2
                          ? _BillingSettings()
                          : _PlaceholderSettings(
                              section: _sections[_selectedSection].label),
            ),
          ],
        ),
      ),
    );
  }
}

class _SettingsSection {
  final String label;
  final IconData icon;

  const _SettingsSection(this.label, this.icon);
}

class _ProfileSettings extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Profile Information',
                      style: AppTypography.headlineSmall),
                  const SizedBox(height: AppSpacing.lg),
                  Center(
                    child: Column(
                      children: [
                        CircleAvatar(
                          radius: 40,
                          backgroundColor: AppColors.gold,
                          child: const Text(
                            'AB',
                            style: TextStyle(
                              color: AppColors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextButton.icon(
                          onPressed: () {},
                          icon: const Icon(Icons.upload_outlined, size: 14),
                          label: const Text('Change Photo'),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  _SettingsField(label: 'First Name', value: 'Alex'),
                  const SizedBox(height: AppSpacing.md),
                  _SettingsField(label: 'Last Name', value: 'Bryant'),
                  const SizedBox(height: AppSpacing.md),
                  _SettingsField(
                      label: 'Email', value: 'alex@leadora.com'),
                  const SizedBox(height: AppSpacing.md),
                  _SettingsField(
                      label: 'Role', value: 'Admin'),
                  const SizedBox(height: AppSpacing.lg),
                  GoldButton(
                      label: 'Save Changes', onTap: () {}),
                ],
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              children: [
                AppCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Account',
                          style: AppTypography.headlineSmall),
                      const SizedBox(height: AppSpacing.md),
                      _SettingRow(
                          label: 'Plan', value: 'Professional'),
                      const SizedBox(height: 8),
                      _SettingRow(
                          label: 'Status', value: 'Active'),
                      const SizedBox(height: 8),
                      _SettingRow(
                          label: 'Member since',
                          value: 'Jan 2024'),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                AppCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Notifications',
                          style: AppTypography.headlineSmall),
                      const SizedBox(height: AppSpacing.md),
                      _NotificationRow(label: 'New leads', enabled: true),
                      const SizedBox(height: 8),
                      _NotificationRow(
                          label: 'Deal updates', enabled: true),
                      const SizedBox(height: 8),
                      _NotificationRow(
                          label: 'Email replies', enabled: false),
                      const SizedBox(height: 8),
                      _NotificationRow(
                          label: 'Weekly digest', enabled: true),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SecuritySettings extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Change Password',
                      style: AppTypography.headlineSmall),
                  const SizedBox(height: AppSpacing.lg),
                  const _SettingsField(
                      label: 'Current Password',
                      value: '••••••••',
                      obscure: true),
                  const SizedBox(height: AppSpacing.md),
                  const _SettingsField(
                      label: 'New Password',
                      value: '',
                      obscure: true),
                  const SizedBox(height: AppSpacing.md),
                  const _SettingsField(
                      label: 'Confirm New Password',
                      value: '',
                      obscure: true),
                  const SizedBox(height: AppSpacing.lg),
                  GoldButton(
                      label: 'Update Password', onTap: () {}),
                ],
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              children: [
                AppCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Two-Factor Authentication',
                              style: AppTypography.headlineSmall),
                          StatusBadge(
                            label: 'Enabled',
                            color: AppColors.success,
                            bgColor: AppColors.successLight,
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        'Add an extra layer of security to your account. Enabled.',
                        style: AppTypography.bodySmall,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                AppCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Active Sessions',
                              style: AppTypography.headlineSmall),
                          TextButton(
                            onPressed: () {},
                            child: Text(
                              'Manage Sessions',
                              style: AppTypography.labelMedium
                                  .copyWith(color: AppColors.gold),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        'Manage your active sessions across devices.',
                        style: AppTypography.bodySmall,
                      ),
                      const SizedBox(height: AppSpacing.md),
                      _SessionRow(
                          device: 'Chrome — macOS',
                          location: 'London, UK',
                          isCurrent: true),
                      const SizedBox(height: 8),
                      _SessionRow(
                          device: 'Safari — iPhone',
                          location: 'London, UK',
                          isCurrent: false),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _BillingSettings extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GridView.count(
            crossAxisCount: 3,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: AppSpacing.md,
            mainAxisSpacing: AppSpacing.md,
            childAspectRatio: 3.0,
            children: const [
              StatCard(
                  title: 'Current Plan',
                  value: 'Professional',
                  icon: Icons.star_outline),
              StatCard(
                  title: 'Next Billing',
                  value: 'Aug 1, 2024',
                  icon: Icons.calendar_today_outlined,
                  iconColor: AppColors.info,
                  iconBgColor: AppColors.infoLight),
              StatCard(
                  title: 'Monthly Cost',
                  value: '£149/mo',
                  icon: Icons.currency_pound_outlined),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          AppCard(
            padding: EdgeInsets.zero,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(AppSpacing.cardPadding),
                  child: Row(
                    children: [
                      Text('Billing History',
                          style: AppTypography.titleMedium),
                      const Spacer(),
                      OutlinedButton.icon(
                        onPressed: () {},
                        icon: const Icon(Icons.download_outlined, size: 14),
                        label: const Text('Download All'),
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
                AppDataTable(
                  headers: const ['Date', 'Description', 'Amount', 'Status'],
                  columnWidths: const [140, 280, 120, 100],
                  rows: const [
                    [
                      Text('Jul 1, 2024'),
                      Text('Professional Plan — Monthly'),
                      Text('£149.00'),
                      StatusBadge(
                          label: 'Paid',
                          color: AppColors.success,
                          bgColor: AppColors.successLight),
                    ],
                    [
                      Text('Jun 1, 2024'),
                      Text('Professional Plan — Monthly'),
                      Text('£149.00'),
                      StatusBadge(
                          label: 'Paid',
                          color: AppColors.success,
                          bgColor: AppColors.successLight),
                    ],
                    [
                      Text('May 1, 2024'),
                      Text('Professional Plan — Monthly'),
                      Text('£149.00'),
                      StatusBadge(
                          label: 'Paid',
                          color: AppColors.success,
                          bgColor: AppColors.successLight),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PlaceholderSettings extends StatelessWidget {
  final String section;

  const _PlaceholderSettings({required this.section});

  @override
  Widget build(BuildContext context) {
    return EmptyState(
      icon: Icons.settings_outlined,
      title: '$section Settings',
      subtitle: 'This section is coming soon.',
    );
  }
}

class _SettingsField extends StatelessWidget {
  final String label;
  final String value;
  final bool obscure;

  const _SettingsField({
    required this.label,
    required this.value,
    this.obscure = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTypography.labelMedium),
        const SizedBox(height: 6),
        TextFormField(
          initialValue: value,
          obscureText: obscure,
          style: AppTypography.bodyMedium,
          decoration: InputDecoration(
            filled: true,
            fillColor: AppColors.contentBg,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide:
                  const BorderSide(color: AppColors.gold, width: 1.5),
            ),
            contentPadding: const EdgeInsets.symmetric(
                horizontal: 14, vertical: 12),
          ),
        ),
      ],
    );
  }
}

class _SettingRow extends StatelessWidget {
  final String label;
  final String value;

  const _SettingRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: AppTypography.bodySmall),
        Text(value, style: AppTypography.titleSmall),
      ],
    );
  }
}

class _NotificationRow extends StatefulWidget {
  final String label;
  final bool enabled;

  const _NotificationRow({required this.label, required this.enabled});

  @override
  State<_NotificationRow> createState() => _NotificationRowState();
}

class _NotificationRowState extends State<_NotificationRow> {
  late bool _enabled;

  @override
  void initState() {
    super.initState();
    _enabled = widget.enabled;
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: AppTypography.bodySmall),
        Switch(
          value: _enabled,
          onChanged: (v) => setState(() => _enabled = v),
          activeColor: AppColors.gold,
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
      ],
    );
  }

  String get label => widget.label;
}

class _SessionRow extends StatelessWidget {
  final String device;
  final String location;
  final bool isCurrent;

  const _SessionRow({
    required this.device,
    required this.location,
    required this.isCurrent,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: AppColors.contentBg,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.border),
          ),
          child: const Icon(Icons.devices_outlined,
              size: 16, color: AppColors.textSecondary),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(device, style: AppTypography.titleSmall),
              Text(location, style: AppTypography.caption),
            ],
          ),
        ),
        if (isCurrent)
          StatusBadge(
            label: 'Current',
            color: AppColors.success,
            bgColor: AppColors.successLight,
          )
        else
          TextButton(
            onPressed: () {},
            child: Text('Revoke',
                style: AppTypography.labelMedium
                    .copyWith(color: AppColors.error)),
          ),
      ],
    );
  }
}
