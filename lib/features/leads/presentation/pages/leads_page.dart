import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/cards/app_card.dart';
import '../../../crm/data/crm_repository.dart';
import '../../../crm/domain/crm_models.dart';

class LeadsPage extends ConsumerStatefulWidget {
  const LeadsPage({super.key});

  @override
  State<LeadsPage> createState() => _LeadsPageState();
}

class _LeadsPageState extends ConsumerState<LeadsPage> {
  String _filter = 'All Leads';
  String _search = '';

  static const List<String> _tabs = [
    'All Leads', 'New', 'Contacted', 'Qualified', 'Proposal', 'Won', 'Lost',
  ];

  List<_Lead> get _leads {
    final now = DateTime.now();
    return ref.watch(crmRepositoryProvider).leads.map((lead) => _Lead(
        lead.name,
        lead.email,
        lead.company,
        lead.status.label,
        lead.source,
        _relativeDate(lead.createdAt, now),
        )).toList();
  }

  String _relativeDate(DateTime date, DateTime now) {
    final minutes = now.difference(date).inMinutes;
    if (minutes < 60) return '$minutes min ago';
    final hours = minutes ~/ 60;
    if (hours < 24) return '$hours h ago';
    return '${hours ~/ 24} d ago';
  }

  List<_Lead> get _filtered {
    return _leads.where((lead) {
      final matchesFilter = _filter == 'All Leads' || lead.status == _filter;
      final matchesSearch = _search.isEmpty ||
          lead.name.toLowerCase().contains(_search.toLowerCase()) ||
          lead.email.toLowerCase().contains(_search.toLowerCase()) ||
          lead.company.toLowerCase().contains(_search.toLowerCase());
      return matchesFilter && matchesSearch;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Leads',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Manage and track all your leads.',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 13,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              PrimaryButton(
                label: 'Add Lead',
                icon: Icons.add_rounded,
                onPressed: () => _showAddLeadDialog(context),
              ),
            ],
          ),

          const SizedBox(height: 24),

          AppCard(
            child: Column(
              children: [
                // Filter tabs + actions
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Row(
                    children: [
                      Expanded(
                        child: FilterChipRow(
                          options: _tabs,
                          selected: _filter,
                          onSelected: (v) => setState(() => _filter = v),
                        ),
                      ),
                      const SizedBox(width: 12),
                      SearchField(
                        hint: 'Search leads...',
                        onChanged: (v) => setState(() => _search = v),
                      ),
                      const SizedBox(width: 8),
                      SecondaryButton(
                        label: 'Filter',
                        icon: Icons.tune_rounded,
                        onPressed: () {},
                        small: true,
                      ),
                      const SizedBox(width: 8),
                      SecondaryButton(
                        label: 'Sort',
                        icon: Icons.sort_rounded,
                        onPressed: () {},
                        small: true,
                      ),
                    ],
                  ),
                ),

                const Divider(height: 1),

                // Table header
                _TableHeader(),

                const Divider(height: 1),

                // Rows
                ..._filtered.asMap().entries.map((entry) => Column(
                      children: [
                        _LeadRow(lead: entry.value, index: entry.key),
                        if (entry.key < _filtered.length - 1)
                          const Divider(height: 1),
                      ],
                    )),

                // Pagination
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Row(
                    children: [
                      Text(
                        'Showing ${_filtered.length} of ${_leads.length} leads',
                        style: const TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const Spacer(),
                      _PaginationButtons(),
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

  Future<void> _showAddLeadDialog(BuildContext context) async {
    final name = TextEditingController();
    final email = TextEditingController();
    final company = TextEditingController();
    try {
      final shouldAdd = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
        title: const Text('Add Lead'),
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
          ElevatedButton(onPressed: () => Navigator.pop(context, true), child: const Text('Add Lead')),
        ],
        ),
      );
      if (shouldAdd == true && name.text.trim().isNotEmpty && isValidEmail(email.text)) {
        ref.read(crmRepositoryProvider).addLead(name: name.text.trim(), email: email.text.trim(), company: company.text.trim());
      }
    } finally {
      name.dispose();
      email.dispose();
      company.dispose();
    }
  }
}

class _TableHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.contentBg,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: const [
          Expanded(flex: 3, child: _HeaderCell('Name')),
          Expanded(flex: 3, child: _HeaderCell('Email')),
          Expanded(flex: 2, child: _HeaderCell('Company')),
          Expanded(flex: 2, child: _HeaderCell('Status')),
          Expanded(flex: 2, child: _HeaderCell('Source')),
          Expanded(flex: 2, child: _HeaderCell('Created')),
        ],
      ),
    );
  }
}

class _HeaderCell extends StatelessWidget {
  final String text;
  const _HeaderCell(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
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
}

class _LeadRow extends StatefulWidget {
  final _Lead lead;
  final int index;
  const _LeadRow({required this.lead, required this.index});

  @override
  State<_LeadRow> createState() => _LeadRowState();
}

class _LeadRowState extends State<_LeadRow> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final lead = widget.lead;
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
                    backgroundColor: AppColors.goldSurface,
                    child: Text(
                      lead.name[0],
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.gold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    lead.name,
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
              flex: 3,
              child: Text(
                lead.email,
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 13,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
            Expanded(
              flex: 2,
              child: Text(
                lead.company,
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 13,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            Expanded(flex: 2, child: StatusBadge.fromStatus(lead.status)),
            Expanded(
              flex: 2,
              child: Row(
                children: [
                  const Icon(Icons.language_rounded, size: 12, color: AppColors.textTertiary),
                  const SizedBox(width: 4),
                  Text(
                    lead.source,
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              flex: 2,
              child: Text(
                lead.created,
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 12,
                  color: AppColors.textTertiary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PaginationButtons extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (final label in ['1', '2', '3', '...', '10'])
          Padding(
            padding: const EdgeInsets.only(right: 4),
            child: Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: label == '1' ? AppColors.gold : Colors.transparent,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: label == '1' ? AppColors.gold : AppColors.cardBorder,
                ),
              ),
              child: Center(
                child: Text(
                  label,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: label == '1' ? Colors.white : AppColors.textSecondary,
                  ),
                ),
              ),
            ),
          ),
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: AppColors.cardBorder),
          ),
          child: const Icon(Icons.chevron_right_rounded, size: 16, color: AppColors.textSecondary),
        ),
      ],
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
  const _Lead(this.name, this.email, this.company, this.status, this.source, this.created);
}
