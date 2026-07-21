import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/cards/app_card.dart';

class EmailOutreachPage extends StatefulWidget {
  const EmailOutreachPage({super.key});

  @override
  State<EmailOutreachPage> createState() => _EmailOutreachPageState();
}

class _EmailOutreachPageState extends State<EmailOutreachPage>
    with SingleTickerProviderStateMixin {
  late TabController _tab;

  static const List<_Campaign> _campaigns = [
    _Campaign('Summer Promotion', 'Active', '1,248', '64.2%', '28.7%', '4.1%'),
    _Campaign('Welcome Series', 'Active', '847', '71.5%', '34.2%', '2.8%'),
    _Campaign('Re-engagement', 'Paused', '523', '42.1%', '18.6%', '1.2%'),
    _Campaign('Product Launch', 'Active', '2,104', '58.9%', '31.4%', '5.7%'),
    _Campaign('Win-back', 'Paused', '312', '38.4%', '14.2%', '0.9%'),
  ];

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 3, vsync: this);
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
          Row(
            children: [
              const Expanded(
                child: SectionHeader(
                  title: 'Email Outreach',
                  subtitle: 'Create and manage email campaigns.',
                ),
              ),
              PrimaryButton(
                label: 'New Campaign',
                icon: Icons.add_rounded,
                onPressed: () {},
              ),
            ],
          ),

          const SizedBox(height: 4),

          // Stats
          Row(
            children: const [
              Expanded(child: _EmailStatCard(label: 'Emails Sent', value: '24,853', icon: Icons.send_outlined, color: AppColors.info)),
              SizedBox(width: 16),
              Expanded(child: _EmailStatCard(label: 'Open Rate', value: '61.4%', icon: Icons.mail_open_outlined, color: AppColors.success)),
              SizedBox(width: 16),
              Expanded(child: _EmailStatCard(label: 'Click Rate', value: '27.8%', icon: Icons.touch_app_outlined, color: AppColors.gold)),
              SizedBox(width: 16),
              Expanded(child: _EmailStatCard(label: 'Conversions', value: '3.2%', icon: Icons.trending_up_rounded, color: AppColors.badgeQualified)),
            ],
          ),

          const SizedBox(height: 24),

          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Tabs
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  child: TabBar(
                    controller: _tab,
                    isScrollable: true,
                    tabAlignment: TabAlignment.start,
                    tabs: const [
                      Tab(text: 'Campaigns'),
                      Tab(text: 'Templates'),
                      Tab(text: 'Sequences'),
                    ],
                  ),
                ),

                const Divider(height: 1),

                // Search bar
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      const Expanded(child: SearchField(hint: 'Search campaigns...')),
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

                // Table header
                _buildHeader(),

                const Divider(height: 1),

                // Rows
                ..._campaigns.asMap().entries.map((e) => Column(
                      children: [
                        _CampaignRow(campaign: e.value),
                        if (e.key < _campaigns.length - 1) const Divider(height: 1),
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
          Expanded(flex: 3, child: _H('Campaign')),
          Expanded(flex: 1, child: _H('Status')),
          Expanded(flex: 2, child: _H('Sent')),
          Expanded(flex: 2, child: _H('Open Rate')),
          Expanded(flex: 2, child: _H('Click Rate')),
          Expanded(flex: 2, child: _H('Conversion')),
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

class _EmailStatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  const _EmailStatCard({required this.label, required this.value, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return AppCard(
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
              Text(
                value,
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 22,
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
    );
  }
}

class _CampaignRow extends StatefulWidget {
  final _Campaign campaign;
  const _CampaignRow({required this.campaign});

  @override
  State<_CampaignRow> createState() => _CampaignRowState();
}

class _CampaignRowState extends State<_CampaignRow> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final c = widget.campaign;
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
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: AppColors.goldSurface,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.email_rounded, size: 16, color: AppColors.gold),
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
            Expanded(flex: 1, child: StatusBadge.fromStatus(c.status)),
            _MetricCell(value: c.sent, flex: 2),
            _RateCell(rate: c.openRate, flex: 2),
            _RateCell(rate: c.clickRate, flex: 2),
            _RateCell(rate: c.conversion, flex: 2),
          ],
        ),
      ),
    );
  }
}

class _MetricCell extends StatelessWidget {
  final String value;
  final int flex;
  const _MetricCell({required this.value, required this.flex});

  @override
  Widget build(BuildContext context) => Expanded(
        flex: flex,
        child: Text(
          value,
          style: const TextStyle(
            fontFamily: 'Inter',
            fontSize: 13,
            color: AppColors.textPrimary,
          ),
        ),
      );
}

class _RateCell extends StatelessWidget {
  final String rate;
  final int flex;
  const _RateCell({required this.rate, required this.flex});

  @override
  Widget build(BuildContext context) {
    final value = double.tryParse(rate.replaceAll('%', '')) ?? 0;
    return Expanded(
      flex: flex,
      child: Row(
        children: [
          SizedBox(
            width: 48,
            child: LinearProgressIndicator(
              value: value / 100,
              backgroundColor: AppColors.contentBg,
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.gold),
              minHeight: 4,
              borderRadius: BorderRadius.circular(100),
            ),
          ),
          const SizedBox(width: 6),
          Text(
            rate,
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _Campaign {
  final String name;
  final String status;
  final String sent;
  final String openRate;
  final String clickRate;
  final String conversion;
  const _Campaign(this.name, this.status, this.sent, this.openRate, this.clickRate, this.conversion);
}
