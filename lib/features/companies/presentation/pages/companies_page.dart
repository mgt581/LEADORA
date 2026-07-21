import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/cards/app_card.dart';

class CompaniesPage extends StatelessWidget {
  const CompaniesPage({super.key});

  static const List<_Company> _companies = [
    _Company('Design Co.', 'Technology', '1-10', 'sarah@designco.com', '£12,500', 'Active', 3),
    _Company('TechFlow', 'Software', '11-50', 'info@techflow.com', '£28,000', 'Active', 7),
    _Company('MarketPlus', 'Marketing', '51-200', 'hello@marketplus.com', '£45,200', 'Active', 12),
    _Company('Bright Idea', 'Consulting', '1-10', 'emily@brightidea.com', '£8,900', 'Inactive', 2),
    _Company('NextGen', 'Technology', '11-50', 'michael@nextgen.com', '£31,700', 'Active', 5),
    _Company('Creative Lab', 'Design', '1-10', 'jessica@creativelab.com', '£19,400', 'Active', 4),
    _Company('FusionTech', 'Software', '51-200', 'robert@fusiontech.com', '£67,800', 'Active', 15),
    _Company('Pioneer Inc.', 'Retail', '200+', 'amanda@pioneer.com', '£93,200', 'Active', 22),
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
                  title: 'Companies',
                  subtitle: 'Track and manage your company relationships.',
                ),
              ),
              PrimaryButton(
                label: 'Add Company',
                icon: Icons.add_business_rounded,
                onPressed: () {},
              ),
            ],
          ),

          const SizedBox(height: 4),

          LayoutBuilder(builder: (context, c) {
            return Wrap(
              spacing: 16,
              runSpacing: 16,
              children: _companies.map((company) => SizedBox(
                width: (c.maxWidth - 48) / 4,
                child: _CompanyCard(company: company),
              )).toList(),
            );
          }),
        ],
      ),
    );
  }
}

class _CompanyCard extends StatelessWidget {
  final _Company company;
  const _CompanyCard({required this.company});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(20),
      onTap: () {},
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [AppColors.gold, AppColors.goldDark],
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Text(
                    company.name[0],
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const Spacer(),
              StatusBadge.fromStatus(company.status),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            company.name,
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            company.industry,
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 16),
          const Divider(height: 1),
          const SizedBox(height: 12),
          _CompanyMeta(icon: Icons.people_outline_rounded, label: '${company.size} employees'),
          const SizedBox(height: 6),
          _CompanyMeta(icon: Icons.attach_money_rounded, label: company.revenue),
          const SizedBox(height: 6),
          _CompanyMeta(icon: Icons.person_outline_rounded, label: '${company.contacts} contacts'),
        ],
      ),
    );
  }
}

class _CompanyMeta extends StatelessWidget {
  final IconData icon;
  final String label;
  const _CompanyMeta({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 13, color: AppColors.textTertiary),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'Inter',
            fontSize: 12,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}

class _Company {
  final String name;
  final String industry;
  final String size;
  final String email;
  final String revenue;
  final String status;
  final int contacts;
  const _Company(this.name, this.industry, this.size, this.email, this.revenue, this.status, this.contacts);
}
