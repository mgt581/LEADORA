import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/widgets/app_shell.dart';
import '../../../../core/widgets/app_widgets.dart';

class ContactsPage extends StatelessWidget {
  const ContactsPage({super.key});

  static const List<_Contact> _contacts = [
    _Contact(name: 'Sarah Johnson', email: 'sarah@designco.com', phone: '+44 7700 900113', company: 'Design Co.', role: 'CEO', added: '2 days ago'),
    _Contact(name: 'David Williams', email: 'david@techflow.com', phone: '+44 7700 900214', company: 'TechFlow', role: 'CTO', added: '3 days ago'),
    _Contact(name: 'James Brown', email: 'james@marketplus.com', phone: '+44 7700 900315', company: 'MarketPlus', role: 'Marketing Dir.', added: '5 days ago'),
    _Contact(name: 'Emily Davis', email: 'emily@brightidea.com', phone: '+44 7700 900416', company: 'Bright Idea', role: 'Founder', added: '1 week ago'),
    _Contact(name: 'Michael Wilson', email: 'michael@nextgen.com', phone: '+44 7700 900517', company: 'NextGen', role: 'VP Sales', added: '1 week ago'),
    _Contact(name: 'Jessica Taylor', email: 'jessica@creativlab.com', phone: '+44 7700 900618', company: 'Creative Lab', role: 'Designer', added: '2 weeks ago'),
    _Contact(name: 'Robert Martinez', email: 'robert@scale.io', phone: '+44 7700 900719', company: 'Scale.io', role: 'COO', added: '2 weeks ago'),
    _Contact(name: 'Amanda Chen', email: 'amanda@synergy.com', phone: '+44 7700 900820', company: 'Synergy Co.', role: 'CFO', added: '3 weeks ago'),
  ];

  @override
  Widget build(BuildContext context) {
    return AppShell(
      currentRoute: '/contacts',
      pageTitle: 'Contacts',
      topBarActions: [
        GoldButton(
          label: 'Add Contact',
          icon: Icons.add,
          onTap: () {},
          small: true,
        ),
        const SizedBox(width: AppSpacing.md),
      ],
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.contentPadding),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: AppCard(
                    child: Row(
                      children: [
                        const Icon(Icons.people_outline,
                            color: AppColors.gold, size: 20),
                        const SizedBox(width: 8),
                        Text('${_contacts.length} Contacts',
                            style: AppTypography.titleMedium),
                      ],
                    ),
                  ),
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
                          Expanded(
                            child: Container(
                              height: 38,
                              decoration: BoxDecoration(
                                color: AppColors.contentBg,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: AppColors.border),
                              ),
                              child: Row(
                                children: [
                                  const SizedBox(width: 10),
                                  const Icon(Icons.search,
                                      size: 16,
                                      color: AppColors.textTertiary),
                                  const SizedBox(width: 8),
                                  Text('Search contacts...',
                                      style: AppTypography.bodySmall.copyWith(
                                          color: AppColors.textTertiary)),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          OutlinedButton.icon(
                            onPressed: () {},
                            icon: const Icon(Icons.filter_list_outlined,
                                size: 14),
                            label: const Text('Filter'),
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
                          'Name',
                          'Email',
                          'Phone',
                          'Company',
                          'Role',
                          'Added',
                        ],
                        columnWidths: const [160, 200, 160, 140, 140, 100],
                        rows: _contacts
                            .map((c) => [
                                  Row(
                                    children: [
                                      CircleAvatar(
                                        radius: 14,
                                        backgroundColor: AppColors.goldSurface,
                                        child: Text(
                                          c.name[0],
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
                                          c.name,
                                          style: AppTypography.titleSmall,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Text(c.email,
                                      style: AppTypography.bodySmall,
                                      overflow: TextOverflow.ellipsis),
                                  Text(c.phone,
                                      style: AppTypography.bodySmall),
                                  Text(c.company,
                                      style: AppTypography.bodySmall,
                                      overflow: TextOverflow.ellipsis),
                                  Text(c.role,
                                      style: AppTypography.bodySmall),
                                  Text(c.added,
                                      style: AppTypography.caption),
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

class _Contact {
  final String name;
  final String email;
  final String phone;
  final String company;
  final String role;
  final String added;

  const _Contact({
    required this.name,
    required this.email,
    required this.phone,
    required this.company,
    required this.role,
    required this.added,
  });
}
