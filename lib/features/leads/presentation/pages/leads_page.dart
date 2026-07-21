import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/widgets/app_shell.dart';
import '../../../../core/widgets/app_widgets.dart';

class LeadsPage extends StatefulWidget {
  const LeadsPage({super.key});

  @override
  State<LeadsPage> createState() => _LeadsPageState();
}

class _LeadsPageState extends State<LeadsPage> {
  String _activeFilter = 'All Leads';
  final List<String> _filters = [
    'All Leads',
    'New',
    'Contacted',
    'Qualified',
    'Proposal',
    'Won',
    'Lost',
  ];

  final List<_Lead> _leads = const [
    _Lead(
      name: 'Sarah Johnson',
      email: 'sarah@designco.com',
      company: 'Design Co.',
      status: 'New',
      source: 'Website',
      created: '2 min ago',
    ),
    _Lead(
      name: 'David Williams',
      email: 'david@techflow.com',
      company: 'TechFlow',
      status: 'Contacted',
      source: 'LinkedIn',
      created: '1 h ago',
    ),
    _Lead(
      name: 'James Brown',
      email: 'james@marketplus.com',
      company: 'MarketPlus',
      status: 'Qualified',
      source: 'Referral',
      created: '1 h ago',
    ),
    _Lead(
      name: 'Emily Davis',
      email: 'emily@brightidea.com',
      company: 'Bright Idea',
      status: 'Proposal',
      source: 'Website',
      created: '5 h ago',
    ),
    _Lead(
      name: 'Michael Wilson',
      email: 'michael@nextgen.com',
      company: 'NextGen',
      status: 'New',
      source: 'Ads',
      created: '1 day ago',
    ),
    _Lead(
      name: 'Jessica Taylor',
      email: 'jessica@creativlab.com',
      company: 'Creative Lab',
      status: 'Contacted',
      source: 'LinkedIn',
      created: '1 day ago',
    ),
    _Lead(
      name: 'Robert Martinez',
      email: 'robert@scale.io',
      company: 'Scale.io',
      status: 'Won',
      source: 'Referral',
      created: '2 days ago',
    ),
    _Lead(
      name: 'Amanda Chen',
      email: 'amanda@synergy.com',
      company: 'Synergy Co.',
      status: 'Qualified',
      source: 'Website',
      created: '3 days ago',
    ),
  ];

  List<_Lead> get _filteredLeads {
    if (_activeFilter == 'All Leads') return _leads;
    return _leads
        .where((l) => l.status == _activeFilter)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return AppShell(
      currentRoute: '/leads',
      pageTitle: 'Leads',
      topBarActions: [
        GoldButton(
          label: 'Add Lead',
          icon: Icons.add,
          onTap: () {},
          small: true,
        ),
        const SizedBox(width: AppSpacing.md),
      ],
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.contentPadding),
        child: AppCard(
          padding: EdgeInsets.zero,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(AppSpacing.cardPadding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Leads', style: AppTypography.headlineSmall),
                    Text(
                      'Manage and track all your leads.',
                      style: AppTypography.bodySmall,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: _filters
                            .map((f) => _FilterChip(
                                  label: f,
                                  isActive: _activeFilter == f,
                                  onTap: () =>
                                      setState(() => _activeFilter = f),
                                ))
                            .toList(),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Row(
                      children: [
                        Expanded(
                          child: _SearchInput(
                            hint: 'Search leads...',
                            onChanged: (_) {},
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        _ActionButton(
                            icon: Icons.filter_list_outlined,
                            label: 'Filter'),
                        const SizedBox(width: AppSpacing.sm),
                        _ActionButton(
                            icon: Icons.sort_outlined,
                            label: 'Sort'),
                      ],
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              AppDataTable(
                headers: const [
                  'Name',
                  'Email',
                  'Company',
                  'Status',
                  'Source',
                  'Created',
                ],
                columnWidths: const [160, 200, 150, 110, 100, 100],
                rows: _filteredLeads
                    .map((lead) => [
                          Row(
                            children: [
                              CircleAvatar(
                                radius: 14,
                                backgroundColor: AppColors.goldSurface,
                                child: Text(
                                  lead.name[0],
                                  style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.gold,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  lead.name,
                                  style: AppTypography.titleSmall,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          Text(lead.email,
                              style: AppTypography.bodySmall,
                              overflow: TextOverflow.ellipsis),
                          Text(lead.company,
                              style: AppTypography.bodySmall,
                              overflow: TextOverflow.ellipsis),
                          StatusBadge.fromStatus(lead.status),
                          Text(lead.source,
                              style: AppTypography.bodySmall),
                          Text(lead.created,
                              style: AppTypography.caption),
                        ])
                    .toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Lead {
  final String name;
  final String email;
  final String company;
  final String status;
  final String source;
  final String created;

  const _Lead({
    required this.name,
    required this.email,
    required this.company,
    required this.status,
    required this.source,
    required this.created,
  });
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        margin: const EdgeInsets.only(right: 6),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: isActive ? AppColors.sidebarBg : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isActive ? AppColors.sidebarBg : AppColors.border,
          ),
        ),
        child: Text(
          label,
          style: AppTypography.labelMedium.copyWith(
            color:
                isActive ? AppColors.white : AppColors.textSecondary,
            fontWeight:
                isActive ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
      ),
    );
  }
}

class _SearchInput extends StatelessWidget {
  final String hint;
  final ValueChanged<String> onChanged;

  const _SearchInput({required this.hint, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 38,
      decoration: BoxDecoration(
        color: AppColors.contentBg,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          const SizedBox(width: 10),
          const Icon(Icons.search, size: 16, color: AppColors.textTertiary),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              onChanged: onChanged,
              style: AppTypography.bodySmall,
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: AppTypography.bodySmall
                    .copyWith(color: AppColors.textTertiary),
                border: InputBorder.none,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;

  const _ActionButton({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: () {},
      icon: Icon(icon, size: 14),
      label: Text(label),
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        textStyle: AppTypography.labelMedium,
      ),
    );
  }
}
