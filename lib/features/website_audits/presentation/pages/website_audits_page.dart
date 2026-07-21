import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/cards/app_card.dart';

class WebsiteAuditsPage extends StatelessWidget {
  const WebsiteAuditsPage({super.key});

  static const List<_Audit> _audits = [
    _Audit('designco.com', 84, 91, 78, 96, 'Jul 21, 2024', 'Completed'),
    _Audit('techflow.io', 72, 85, 64, 88, 'Jul 20, 2024', 'Completed'),
    _Audit('marketplus.co', 61, 74, 55, 82, 'Jul 19, 2024', 'Completed'),
    _Audit('brightidea.com', 93, 97, 89, 99, 'Jul 18, 2024', 'Completed'),
    _Audit('nextgen.dev', 45, 62, 38, 71, 'Jul 17, 2024', 'Failed'),
    _Audit('creativelab.studio', 78, 88, 72, 91, 'Pending', 'Running'),
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
                  title: 'Website Audits',
                  subtitle: 'SEO and performance analysis for your clients.',
                ),
              ),
              PrimaryButton(
                label: 'New Audit',
                icon: Icons.add_rounded,
                onPressed: () {},
              ),
            ],
          ),

          const SizedBox(height: 4),

          Row(
            children: const [
              _AuditStatCard(label: 'Audits Run', value: '142', icon: Icons.search_rounded, color: AppColors.info),
              SizedBox(width: 16),
              _AuditStatCard(label: 'Avg. SEO Score', value: '76', icon: Icons.search_off_rounded, color: AppColors.success),
              SizedBox(width: 16),
              _AuditStatCard(label: 'Critical Issues', value: '38', icon: Icons.warning_amber_rounded, color: AppColors.error),
              SizedBox(width: 16),
              _AuditStatCard(label: 'Sites Monitored', value: '24', icon: Icons.monitor_heart_outlined, color: AppColors.gold),
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
                      const SearchField(hint: 'Search audits...'),
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
                ..._audits.asMap().entries.map((e) => Column(
                      children: [
                        _AuditRow(audit: e.value),
                        if (e.key < _audits.length - 1) const Divider(height: 1),
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
          Expanded(flex: 3, child: _H('Domain')),
          Expanded(flex: 2, child: _H('SEO Score')),
          Expanded(flex: 2, child: _H('Performance')),
          Expanded(flex: 2, child: _H('Accessibility')),
          Expanded(flex: 2, child: _H('Best Practices')),
          Expanded(flex: 2, child: _H('Date')),
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
        style: const TextStyle(fontFamily: 'Inter', fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.textSecondary, letterSpacing: 0.5),
      );
}

class _AuditStatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  const _AuditStatCard({required this.label, required this.value, required this.icon, required this.color});

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
                Text(value, style: const TextStyle(fontFamily: 'Inter', fontSize: 22, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                Text(label, style: const TextStyle(fontFamily: 'Inter', fontSize: 11, color: AppColors.textSecondary)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _AuditRow extends StatefulWidget {
  final _Audit audit;
  const _AuditRow({required this.audit});

  @override
  State<_AuditRow> createState() => _AuditRowState();
}

class _AuditRowState extends State<_AuditRow> {
  bool _hovered = false;

  Color _scoreColor(int score) {
    if (score >= 90) return AppColors.success;
    if (score >= 70) return AppColors.warning;
    return AppColors.error;
  }

  @override
  Widget build(BuildContext context) {
    final a = widget.audit;
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
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: AppColors.contentBg,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: AppColors.cardBorder),
                    ),
                    child: const Icon(Icons.language_rounded, size: 14, color: AppColors.textSecondary),
                  ),
                  const SizedBox(width: 10),
                  Text(a.domain, style: const TextStyle(fontFamily: 'Inter', fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.textPrimary)),
                ],
              ),
            ),
            Expanded(flex: 2, child: _ScorePill(score: a.seo, color: _scoreColor(a.seo))),
            Expanded(flex: 2, child: _ScorePill(score: a.performance, color: _scoreColor(a.performance))),
            Expanded(flex: 2, child: _ScorePill(score: a.accessibility, color: _scoreColor(a.accessibility))),
            Expanded(flex: 2, child: _ScorePill(score: a.bestPractices, color: _scoreColor(a.bestPractices))),
            Expanded(flex: 2, child: Text(a.date, style: const TextStyle(fontFamily: 'Inter', fontSize: 12, color: AppColors.textTertiary))),
            Expanded(flex: 1, child: StatusBadge.fromStatus(a.status)),
          ],
        ),
      ),
    );
  }
}

class _ScorePill extends StatelessWidget {
  final int score;
  final Color color;
  const _ScorePill({required this.score, required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(100),
          ),
          child: Text(
            score.toString(),
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ),
      ],
    );
  }
}

class _Audit {
  final String domain;
  final int seo;
  final int performance;
  final int accessibility;
  final int bestPractices;
  final String date;
  final String status;
  const _Audit(this.domain, this.seo, this.performance, this.accessibility, this.bestPractices, this.date, this.status);
}
