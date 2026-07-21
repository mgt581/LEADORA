import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/cards/app_card.dart';

class DealsPage extends StatelessWidget {
  const DealsPage({super.key});

  static const List<_Deal> _deals = [
    _Deal('ACME Solutions', 'Sarah Johnson', '£45,000', 'Proposal', 80, 'Jul 30, 2024'),
    _Deal('TechFlow Enterprise', 'David Williams', '£128,000', 'Qualified', 60, 'Aug 15, 2024'),
    _Deal('MarketPlus Retainer', 'James Brown', '£24,000', 'Won', 100, 'Jul 21, 2024'),
    _Deal('Pioneer Analytics', 'Amanda Lee', '£67,500', 'New', 20, 'Sep 1, 2024'),
    _Deal('Bright Idea Audit', 'Emily Davis', '£8,900', 'Contacted', 40, 'Aug 5, 2024'),
    _Deal('FusionTech Platform', 'Robert Martinez', '£93,200', 'Won', 100, 'Jul 18, 2024'),
    _Deal('NextGen Setup', 'Michael Wilson', '£31,700', 'Proposal', 75, 'Aug 22, 2024'),
    _Deal('Creative Lab Branding', 'Jessica Taylor', '£19,400', 'Qualified', 55, 'Aug 10, 2024'),
  ];

  @override
  Widget build(BuildContext context) {
    final totalValue = _deals.fold<double>(0, (sum, d) {
      final val = double.tryParse(d.value.replaceAll(RegExp(r'[£,]'), '')) ?? 0;
      return sum + val;
    });

    return SingleChildScrollView(
      padding: const EdgeInsets.all(28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: SectionHeader(
                  title: 'Deals',
                  subtitle: 'Track your deal pipeline and revenue.',
                ),
              ),
              PrimaryButton(
                label: 'New Deal',
                icon: Icons.add_rounded,
                onPressed: () {},
              ),
            ],
          ),

          const SizedBox(height: 4),

          // Summary cards
          Row(
            children: [
              Expanded(
                child: StatCard(
                  title: 'Total Deal Value',
                  value: '£${(totalValue / 1000).toStringAsFixed(0)}k',
                  delta: '+18% vs last month',
                  deltaPositive: true,
                  icon: Icons.monetization_on_outlined,
                ),
              ),
              const SizedBox(width: 16),
              const Expanded(
                child: StatCard(
                  title: 'Open Deals',
                  value: '67',
                  delta: '+8 this week',
                  deltaPositive: true,
                  icon: Icons.pending_actions_outlined,
                  iconColor: AppColors.badgeProposal,
                  iconBackground: AppColors.warningSurface,
                ),
              ),
              const SizedBox(width: 16),
              const Expanded(
                child: StatCard(
                  title: 'Deals Won',
                  value: '23',
                  delta: '+5 this month',
                  deltaPositive: true,
                  icon: Icons.emoji_events_outlined,
                  iconColor: AppColors.success,
                  iconBackground: AppColors.successSurface,
                ),
              ),
              const SizedBox(width: 16),
              const Expanded(
                child: StatCard(
                  title: 'Avg. Deal Size',
                  value: '£54,337',
                  delta: '+12% vs last month',
                  deltaPositive: true,
                  icon: Icons.analytics_outlined,
                  iconColor: AppColors.info,
                  iconBackground: AppColors.infoSurface,
                ),
              ),
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
                      const SearchField(hint: 'Search deals...'),
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
                _buildHeader(),
                const Divider(height: 1),
                ..._deals.asMap().entries.map((e) => Column(
                      children: [
                        _DealRow(deal: e.value),
                        if (e.key < _deals.length - 1) const Divider(height: 1),
                      ],
                    )),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      color: AppColors.contentBg,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: const [
          Expanded(flex: 3, child: _H('Deal')),
          Expanded(flex: 2, child: _H('Contact')),
          Expanded(flex: 2, child: _H('Value')),
          Expanded(flex: 2, child: _H('Stage')),
          Expanded(flex: 3, child: _H('Probability')),
          Expanded(flex: 2, child: _H('Close Date')),
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

class _DealRow extends StatefulWidget {
  final _Deal deal;
  const _DealRow({required this.deal});

  @override
  State<_DealRow> createState() => _DealRowState();
}

class _DealRowState extends State<_DealRow> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final d = widget.deal;
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
              child: Text(
                d.name,
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            Expanded(
              flex: 2,
              child: Text(d.contact,
                  style: const TextStyle(fontFamily: 'Inter', fontSize: 13, color: AppColors.textSecondary)),
            ),
            Expanded(
              flex: 2,
              child: Text(
                d.value,
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            Expanded(flex: 2, child: StatusBadge.fromStatus(d.stage)),
            Expanded(
              flex: 3,
              child: Row(
                children: [
                  Expanded(
                    child: LinearProgressIndicator(
                      value: d.probability / 100,
                      backgroundColor: AppColors.contentBg,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        d.probability == 100 ? AppColors.success : AppColors.gold,
                      ),
                      minHeight: 6,
                      borderRadius: BorderRadius.circular(100),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${d.probability}%',
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              flex: 2,
              child: Text(d.closeDate,
                  style: const TextStyle(fontFamily: 'Inter', fontSize: 12, color: AppColors.textTertiary)),
            ),
          ],
        ),
      ),
    );
  }
}

class _Deal {
  final String name;
  final String contact;
  final String value;
  final String stage;
  final int probability;
  final String closeDate;
  const _Deal(this.name, this.contact, this.value, this.stage, this.probability, this.closeDate);
}
