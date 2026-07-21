import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/cards/app_card.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tab;

  static const List<String> _tabs = [
    'Profile', 'Team', 'Billing', 'Integrations', 'Preferences', 'Security',
  ];

  bool _twoFactor = true;
  bool _emailNotifications = true;
  bool _desktopNotifications = false;
  bool _weeklyDigest = true;

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: _tabs.length, vsync: this);
  }

  @override
  void dispose() {
    _tab.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(
            title: 'Settings',
            subtitle: 'Manage your account and preferences.',
          ),

          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  child: TabBar(
                    controller: _tab,
                    isScrollable: true,
                    tabAlignment: TabAlignment.start,
                    tabs: _tabs.map((t) => Tab(text: t)).toList(),
                  ),
                ),
                const Divider(height: 1),
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: TabBarView(
                    controller: _tab,
                    children: [
                      _ProfileTab(),
                      _TeamTab(),
                      _BillingTab(),
                      _IntegrationsTab(),
                      _PreferencesTab(
                        emailNotifications: _emailNotifications,
                        desktopNotifications: _desktopNotifications,
                        weeklyDigest: _weeklyDigest,
                        onEmailChanged: (v) => setState(() => _emailNotifications = v),
                        onDesktopChanged: (v) => setState(() => _desktopNotifications = v),
                        onDigestChanged: (v) => setState(() => _weeklyDigest = v),
                      ),
                      _SecurityTab(
                        twoFactor: _twoFactor,
                        onTwoFactorChanged: (v) => setState(() => _twoFactor = v),
                      ),
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

// ─── Profile tab ─────────────────────────────────────────────────────────────

class _ProfileTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Avatar
        Row(
          children: [
            CircleAvatar(
              radius: 40,
              backgroundColor: AppColors.gold.withValues(alpha: 0.2),
              child: const Text(
                'AB',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: AppColors.gold,
                ),
              ),
            ),
            const SizedBox(width: 20),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Alex Bryant',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const Text(
                  'admin@leadora.io',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 8),
                SecondaryButton(label: 'Change Photo', onPressed: () {}, small: true),
              ],
            ),
          ],
        ),

        const SizedBox(height: 28),
        const Divider(),
        const SizedBox(height: 20),

        // Form fields
        Row(
          children: [
            Expanded(child: _SettingsField(label: 'First Name', value: 'Alex')),
            const SizedBox(width: 20),
            Expanded(child: _SettingsField(label: 'Last Name', value: 'Bryant')),
          ],
        ),
        const SizedBox(height: 16),
        _SettingsField(label: 'Email Address', value: 'admin@leadora.io'),
        const SizedBox(height: 16),
        _SettingsField(label: 'Job Title', value: 'Founder & CEO'),
        const SizedBox(height: 16),
        _SettingsField(label: 'Phone', value: '+44 7700 900000'),
        const SizedBox(height: 24),
        PrimaryButton(label: 'Save Changes', onPressed: () {}),
      ],
    );
  }
}

// ─── Team tab ─────────────────────────────────────────────────────────────────

class _TeamTab extends StatelessWidget {
  static const List<_Member> _members = [
    _Member('Alex Bryant', 'admin@leadora.io', 'Admin', 'Active'),
    _Member('Sarah Johnson', 'sarah@designco.com', 'Member', 'Active'),
    _Member('David Williams', 'david@techflow.com', 'Member', 'Active'),
    _Member('James Brown', 'james@marketplus.com', 'Viewer', 'Invited'),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text(
              'Team Members',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const Spacer(),
            PrimaryButton(
              label: 'Invite Member',
              icon: Icons.person_add_rounded,
              onPressed: () {},
              small: true,
            ),
          ],
        ),
        const SizedBox(height: 16),
        ..._members.map((m) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.contentBg,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.cardBorder),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 18,
                      backgroundColor: AppColors.goldSurface,
                      child: Text(
                        m.name[0],
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppColors.gold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            m.name,
                            style: const TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          Text(
                            m.email,
                            style: const TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 11,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppColors.contentBg,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: AppColors.cardBorder),
                      ),
                      child: Text(
                        m.role,
                        style: const TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 11,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    StatusBadge.fromStatus(m.status),
                  ],
                ),
              ),
            )),
      ],
    );
  }
}

// ─── Billing tab ─────────────────────────────────────────────────────────────

class _BillingTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Current plan
        Container(
          padding: const EdgeInsets.all(20),
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
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Pro Plan',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      '£79/month · Renews Aug 1, 2024',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 13,
                        color: AppColors.sidebarText,
                      ),
                    ),
                  ],
                ),
              ),
              OutlinedButton(
                onPressed: () {},
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white,
                  side: const BorderSide(color: Colors.white30),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: const Text(
                  'Upgrade',
                  style: TextStyle(fontFamily: 'Inter', fontSize: 13, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 24),

        const Text(
          'Payment Method',
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.contentBg,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.cardBorder),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.info,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text(
                  'VISA',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    letterSpacing: 1,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                '•••• •••• •••• 4242',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 13,
                  color: AppColors.textPrimary,
                ),
              ),
              const Spacer(),
              TextButton(
                onPressed: () {},
                child: const Text('Update', style: TextStyle(color: AppColors.gold)),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ─── Integrations tab ────────────────────────────────────────────────────────

class _IntegrationsTab extends StatelessWidget {
  static const List<_Integration> _items = [
    _Integration('Slack', 'Send notifications to Slack channels', Icons.message_rounded, true),
    _Integration('HubSpot', 'Sync contacts with HubSpot CRM', Icons.hub_rounded, false),
    _Integration('Zapier', 'Connect with 5,000+ apps', Icons.bolt_rounded, true),
    _Integration('Google Analytics', 'Track website conversions', Icons.analytics_rounded, false),
    _Integration('Stripe', 'Process payments and subscriptions', Icons.payment_rounded, true),
    _Integration('Calendly', 'Book meetings automatically', Icons.calendar_today_rounded, false),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Available Integrations',
          style: TextStyle(fontFamily: 'Inter', fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
        ),
        const SizedBox(height: 16),
        LayoutBuilder(builder: (context, constraints) {
          final cardWidth = (constraints.maxWidth - 16) / 2;
          return Wrap(
            spacing: 16,
            runSpacing: 12,
            children: _items.map((item) => SizedBox(
                  width: cardWidth,
                  child: _IntegrationCard(item: item),
                )).toList(),
          );
        }),
      ],
    );
  }
}

class _IntegrationCard extends StatefulWidget {
  final _Integration item;
  const _IntegrationCard({required this.item});

  @override
  State<_IntegrationCard> createState() => _IntegrationCardState();
}

class _IntegrationCardState extends State<_IntegrationCard> {
  late bool _connected;

  @override
  void initState() {
    super.initState();
    _connected = widget.item.connected;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.contentBg,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.cardBg,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.cardBorder),
            ),
            child: Icon(widget.item.icon, size: 18, color: AppColors.gold),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.item.name,
                  style: const TextStyle(fontFamily: 'Inter', fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                ),
                Text(
                  widget.item.description,
                  style: const TextStyle(fontFamily: 'Inter', fontSize: 10, color: AppColors.textSecondary),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Switch(value: _connected, onChanged: (v) => setState(() => _connected = v)),
        ],
      ),
    );
  }
}

// ─── Preferences tab ─────────────────────────────────────────────────────────

class _PreferencesTab extends StatelessWidget {
  final bool emailNotifications;
  final bool desktopNotifications;
  final bool weeklyDigest;
  final ValueChanged<bool> onEmailChanged;
  final ValueChanged<bool> onDesktopChanged;
  final ValueChanged<bool> onDigestChanged;

  const _PreferencesTab({
    required this.emailNotifications,
    required this.desktopNotifications,
    required this.weeklyDigest,
    required this.onEmailChanged,
    required this.onDesktopChanged,
    required this.onDigestChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Notifications',
          style: TextStyle(fontFamily: 'Inter', fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
        ),
        const SizedBox(height: 12),
        _ToggleSetting(
          label: 'Email Notifications',
          subtitle: 'Receive updates and alerts via email',
          value: emailNotifications,
          onChanged: onEmailChanged,
        ),
        const SizedBox(height: 8),
        _ToggleSetting(
          label: 'Desktop Notifications',
          subtitle: 'Show browser push notifications',
          value: desktopNotifications,
          onChanged: onDesktopChanged,
        ),
        const SizedBox(height: 8),
        _ToggleSetting(
          label: 'Weekly Digest',
          subtitle: 'Summary of your weekly performance',
          value: weeklyDigest,
          onChanged: onDigestChanged,
        ),
        const SizedBox(height: 24),
        const Text(
          'Appearance',
          style: TextStyle(fontFamily: 'Inter', fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            _ThemeOption(label: 'Light', icon: Icons.light_mode_rounded, selected: true),
            const SizedBox(width: 12),
            _ThemeOption(label: 'Dark', icon: Icons.dark_mode_rounded, selected: false),
            const SizedBox(width: 12),
            _ThemeOption(label: 'System', icon: Icons.computer_rounded, selected: false),
          ],
        ),
      ],
    );
  }
}

class _ToggleSetting extends StatelessWidget {
  final String label;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _ToggleSetting({
    required this.label,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.contentBg,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(fontFamily: 'Inter', fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.textPrimary)),
                Text(subtitle, style: const TextStyle(fontFamily: 'Inter', fontSize: 11, color: AppColors.textSecondary)),
              ],
            ),
          ),
          Switch(value: value, onChanged: onChanged),
        ],
      ),
    );
  }
}

class _ThemeOption extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  const _ThemeOption({required this.label, required this.icon, required this.selected});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: selected ? AppColors.goldSurface : AppColors.contentBg,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: selected ? AppColors.gold.withValues(alpha: 0.5) : AppColors.cardBorder,
          width: selected ? 1.5 : 1,
        ),
      ),
      child: Row(
        children: [
          Icon(icon, size: 16, color: selected ? AppColors.gold : AppColors.textSecondary),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 13,
              fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
              color: selected ? AppColors.goldDark : AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Security tab ─────────────────────────────────────────────────────────────

class _SecurityTab extends StatelessWidget {
  final bool twoFactor;
  final ValueChanged<bool> onTwoFactorChanged;

  const _SecurityTab({required this.twoFactor, required this.onTwoFactorChanged});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Change password
        const Text(
          'Change Password',
          style: TextStyle(fontFamily: 'Inter', fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
        ),
        const SizedBox(height: 12),
        const _SettingsField(label: 'Current Password', value: '', isPassword: true),
        const SizedBox(height: 12),
        const _SettingsField(label: 'New Password', value: '', isPassword: true),
        const SizedBox(height: 12),
        const _SettingsField(label: 'Confirm New Password', value: '', isPassword: true),
        const SizedBox(height: 16),
        PrimaryButton(label: 'Update Password', onPressed: () {}),

        const SizedBox(height: 28),
        const Divider(),
        const SizedBox(height: 20),

        // Two-factor
        Row(
          children: [
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Two-Factor Authentication',
                    style: TextStyle(fontFamily: 'Inter', fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Add an extra layer of security to your account.',
                    style: TextStyle(fontFamily: 'Inter', fontSize: 12, color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),
            StatusBadge(
              label: twoFactor ? 'Enabled' : 'Disabled',
              color: twoFactor ? AppColors.success : AppColors.error,
              surface: twoFactor ? AppColors.successSurface : AppColors.errorSurface,
            ),
            const SizedBox(width: 12),
            Switch(value: twoFactor, onChanged: onTwoFactorChanged),
          ],
        ),

        const SizedBox(height: 24),

        // Active sessions
        const Text(
          'Active Sessions',
          style: TextStyle(fontFamily: 'Inter', fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
        ),
        const SizedBox(height: 4),
        const Text(
          'Manage your active sessions across devices.',
          style: TextStyle(fontFamily: 'Inter', fontSize: 12, color: AppColors.textSecondary),
        ),
        const SizedBox(height: 12),
        SecondaryButton(label: 'Manage Sessions', onPressed: () {}),
      ],
    );
  }
}

// ─── Shared widgets ───────────────────────────────────────────────────────────

class _SettingsField extends StatelessWidget {
  final String label;
  final String value;
  final bool isPassword;
  const _SettingsField({required this.label, required this.value, this.isPassword = false});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'Inter',
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          obscureText: isPassword,
          controller: value.isEmpty ? null : TextEditingController(text: value),
          style: const TextStyle(fontFamily: 'Inter', fontSize: 14, color: AppColors.textPrimary),
          decoration: InputDecoration(
            hintText: isPassword ? '••••••••' : null,
            filled: true,
            fillColor: AppColors.contentBg,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppColors.cardBorder),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppColors.cardBorder),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppColors.gold, width: 1.5),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          ),
        ),
      ],
    );
  }
}

class _Member {
  final String name;
  final String email;
  final String role;
  final String status;
  const _Member(this.name, this.email, this.role, this.status);
}

class _Integration {
  final String name;
  final String description;
  final IconData icon;
  final bool connected;
  const _Integration(this.name, this.description, this.icon, this.connected);
}
