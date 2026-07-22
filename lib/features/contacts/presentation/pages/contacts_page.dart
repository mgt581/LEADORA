import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/cards/app_card.dart';
import '../../../crm/data/crm_repository.dart';

class ContactsPage extends ConsumerWidget {
  const ContactsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final contacts = ref.watch(crmRepositoryProvider).contacts
        .map((contact) => _Contact(contact.name, contact.title, contact.company, contact.email, contact.phone, contact.active ? 'Active' : 'Inactive'))
        .toList();
    return SingleChildScrollView(
      padding: const EdgeInsets.all(28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: SectionHeader(
                  title: 'Contacts',
                  subtitle: 'Manage your contact database.',
                ),
              ),
              PrimaryButton(
                label: 'Add Contact',
                icon: Icons.person_add_rounded,
                onPressed: () => _showAddContactDialog(context, ref),
              ),
            ],
          ),

          const SizedBox(height: 4),

          // Stats row
          Row(
            children: const [
              _ContactStatCard(label: 'Total Contacts', value: '1,284', icon: Icons.contacts_rounded),
              SizedBox(width: 16),
              _ContactStatCard(label: 'Active', value: '1,098', icon: Icons.check_circle_outline_rounded),
              SizedBox(width: 16),
              _ContactStatCard(label: 'New This Month', value: '47', icon: Icons.person_add_outlined),
              SizedBox(width: 16),
              _ContactStatCard(label: 'Companies', value: '312', icon: Icons.business_outlined),
            ],
          ),

          const SizedBox(height: 24),

          AppCard(
            child: Column(
              children: [
                // Toolbar
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      const SearchField(hint: 'Search contacts...'),
                      const Spacer(),
                      SecondaryButton(
                        label: 'Filter',
                        icon: Icons.tune_rounded,
                        onPressed: () {},
                        small: true,
                      ),
                      const SizedBox(width: 8),
                      SecondaryButton(
                        label: 'Export',
                        icon: Icons.download_rounded,
                        onPressed: () {},
                        small: true,
                      ),
                    ],
                  ),
                ),

                const Divider(height: 1),

                // Header
                _buildHeader(),

                const Divider(height: 1),

                // Rows
                ...contacts.asMap().entries.map((e) => Column(
                      children: [
                        _ContactRow(contact: e.value),
                        if (e.key < contacts.length - 1) const Divider(height: 1),
                      ],
                    )),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showAddContactDialog(BuildContext context, WidgetRef ref) async {
    final name = TextEditingController();
    final email = TextEditingController();
    final company = TextEditingController();
    try {
      final shouldAdd = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
        title: const Text('Add contact'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: name, decoration: const InputDecoration(labelText: 'Name')),
            TextField(controller: email, decoration: const InputDecoration(labelText: 'Email')),
            TextField(controller: company, decoration: const InputDecoration(labelText: 'Company')),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(onPressed: () => Navigator.pop(context, true), child: const Text('Add contact')),
        ],
        ),
      );
      if (shouldAdd == true && name.text.trim().isNotEmpty && email.text.trim().isNotEmpty) {
        ref.read(crmRepositoryProvider).addContact(name: name.text.trim(), email: email.text.trim(), company: company.text.trim());
      }
    } finally {
      name.dispose();
      email.dispose();
      company.dispose();
    }
  }

  Widget _buildHeader() {
    return Container(
      color: AppColors.contentBg,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: const [
          Expanded(flex: 3, child: _H('Name')),
          Expanded(flex: 2, child: _H('Title')),
          Expanded(flex: 2, child: _H('Company')),
          Expanded(flex: 3, child: _H('Email')),
          Expanded(flex: 2, child: _H('Phone')),
          Expanded(flex: 1, child: _H('Status')),
        ],
      ),
    );
  }
}

class _H extends StatelessWidget {
  final String text;
  const _H(this.text);
  @override
  Widget build(BuildContext context) => Text(
        text.toUpperCase(),
        style: const TextStyle(
          fontFamily: 'Inter',
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: AppColors.textSecondary,
          letterSpacing: 0.5,
        ),
      );
}

class _ContactStatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  const _ContactStatCard({required this.label, required this.value, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: AppCard(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppColors.goldSurface,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, size: 18, color: AppColors.gold),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  label,
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
  }
}

class _ContactRow extends StatefulWidget {
  final _Contact contact;
  const _ContactRow({required this.contact});

  @override
  State<_ContactRow> createState() => _ContactRowState();
}

class _ContactRowState extends State<_ContactRow> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final c = widget.contact;
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        color: _hovered ? AppColors.contentBg : Colors.transparent,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Expanded(
              flex: 3,
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 16,
                    backgroundColor: AppColors.infoSurface,
                    child: Text(
                      c.name[0],
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AppColors.info,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    c.name,
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              flex: 2,
              child: Text(c.title, style: const TextStyle(fontFamily: 'Inter', fontSize: 13, color: AppColors.textSecondary)),
            ),
            Expanded(
              flex: 2,
              child: Text(c.company, style: const TextStyle(fontFamily: 'Inter', fontSize: 13, color: AppColors.textPrimary)),
            ),
            Expanded(
              flex: 3,
              child: Text(c.email, style: const TextStyle(fontFamily: 'Inter', fontSize: 12, color: AppColors.textSecondary)),
            ),
            Expanded(
              flex: 2,
              child: Text(c.phone, style: const TextStyle(fontFamily: 'Inter', fontSize: 12, color: AppColors.textSecondary)),
            ),
            Expanded(
              flex: 1,
              child: StatusBadge.fromStatus(c.status),
            ),
          ],
        ),
      ),
    );
  }
}

class _Contact {
  final String name;
  final String title;
  final String company;
  final String email;
  final String phone;
  final String status;
  const _Contact(this.name, this.title, this.company, this.email, this.phone, this.status);
}
