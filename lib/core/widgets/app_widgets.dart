import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_spacing.dart';
import '../constants/app_typography.dart';

class AppCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final Color? color;
  final double? width;
  final double? height;
  final VoidCallback? onTap;

  const AppCard({
    super.key,
    required this.child,
    this.padding,
    this.color,
    this.width,
    this.height,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: width,
        height: height,
        padding: padding ?? const EdgeInsets.all(AppSpacing.cardPadding),
        decoration: BoxDecoration(
          color: color ?? AppColors.cardBg,
          borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
          border: Border.all(color: AppColors.border),
          boxShadow: const [
            BoxShadow(
              color: AppColors.shadowColor,
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: child,
      ),
    );
  }
}

class StatCard extends StatelessWidget {
  final String title;
  final String value;
  final String? change;
  final bool? isPositive;
  final IconData icon;
  final Color? iconColor;
  final Color? iconBgColor;

  const StatCard({
    super.key,
    required this.title,
    required this.value,
    this.change,
    this.isPositive,
    required this.icon,
    this.iconColor,
    this.iconBgColor,
  });

  @override
  Widget build(BuildContext context) {
    final positive = isPositive ?? true;
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: AppTypography.labelMedium),
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: iconBgColor ?? AppColors.goldSurface,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  size: 18,
                  color: iconColor ?? AppColors.gold,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(value, style: AppTypography.statNumber),
          if (change != null) ...[
            const SizedBox(height: AppSpacing.xs),
            Row(
              children: [
                Icon(
                  positive ? Icons.trending_up : Icons.trending_down,
                  size: 14,
                  color: positive ? AppColors.success : AppColors.error,
                ),
                const SizedBox(width: 4),
                Text(
                  change!,
                  style: AppTypography.caption.copyWith(
                    color: positive ? AppColors.success : AppColors.error,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class SectionHeader extends StatelessWidget {
  final String title;
  final Widget? trailing;
  final EdgeInsetsGeometry? padding;

  const SectionHeader({
    super.key,
    required this.title,
    this.trailing,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding ?? EdgeInsets.zero,
      child: Row(
        children: [
          Text(title, style: AppTypography.titleMedium),
          const Spacer(),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}

class StatusBadge extends StatelessWidget {
  final String label;
  final Color color;
  final Color bgColor;

  const StatusBadge({
    super.key,
    required this.label,
    required this.color,
    required this.bgColor,
  });

  factory StatusBadge.fromStatus(String status) {
    switch (status.toLowerCase()) {
      case 'new':
        return StatusBadge(
          label: status,
          color: AppColors.statusNew,
          bgColor: AppColors.statusNewLight,
        );
      case 'contacted':
        return StatusBadge(
          label: status,
          color: AppColors.statusContacted,
          bgColor: AppColors.statusContactedLight,
        );
      case 'qualified':
        return StatusBadge(
          label: status,
          color: AppColors.statusQualified,
          bgColor: AppColors.statusQualifiedLight,
        );
      case 'proposal':
        return StatusBadge(
          label: status,
          color: AppColors.statusProposal,
          bgColor: AppColors.statusProposalLight,
        );
      case 'won':
        return StatusBadge(
          label: status,
          color: AppColors.statusWon,
          bgColor: AppColors.statusWonLight,
        );
      case 'lost':
        return StatusBadge(
          label: status,
          color: AppColors.statusLost,
          bgColor: AppColors.statusLostLight,
        );
      default:
        return StatusBadge(
          label: status,
          color: AppColors.textSecondary,
          bgColor: AppColors.borderLight,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(AppSpacing.chipRadius),
      ),
      child: Text(
        label,
        style: AppTypography.labelSmall.copyWith(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class GoldButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final IconData? icon;
  final bool small;

  const GoldButton({
    super.key,
    required this.label,
    required this.onTap,
    this.icon,
    this.small = false,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.gold,
        foregroundColor: AppColors.white,
        elevation: 0,
        padding: EdgeInsets.symmetric(
          horizontal: small ? 14 : 20,
          vertical: small ? 8 : 11,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        textStyle: TextStyle(
          fontSize: small ? 12 : 13,
          fontWeight: FontWeight.w600,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: small ? 14 : 16),
            const SizedBox(width: 6),
          ],
          Text(label),
        ],
      ),
    );
  }
}

class AppDataTable extends StatelessWidget {
  final List<String> headers;
  final List<List<Widget>> rows;
  final List<double>? columnWidths;

  const AppDataTable({
    super.key,
    required this.headers,
    required this.rows,
    this.columnWidths,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Header
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.cardPadding,
            vertical: AppSpacing.sm,
          ),
          decoration: const BoxDecoration(
            color: AppColors.contentBg,
            border: Border(bottom: BorderSide(color: AppColors.border)),
          ),
          child: Row(
            children: headers.asMap().entries.map((e) {
              final width = columnWidths != null ? columnWidths![e.key] : null;
              return SizedBox(
                width: width,
                child: Text(
                  e.value,
                  style: AppTypography.labelSmall.copyWith(
                    color: AppColors.textTertiary,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                ),
              );
            }).toList(),
          ),
        ),
        // Rows
        ...rows.asMap().entries.map(
              (rowEntry) => _TableRow(
                cells: rowEntry.value,
                columnWidths: columnWidths,
                isEven: rowEntry.key.isEven,
              ),
            ),
      ],
    );
  }
}

class _TableRow extends StatefulWidget {
  final List<Widget> cells;
  final List<double>? columnWidths;
  final bool isEven;

  const _TableRow({
    required this.cells,
    required this.columnWidths,
    required this.isEven,
  });

  @override
  State<_TableRow> createState() => _TableRowState();
}

class _TableRowState extends State<_TableRow> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.cardPadding,
          vertical: AppSpacing.sm + 4,
        ),
        decoration: BoxDecoration(
          color: _hovered
              ? AppColors.goldSurface
              : widget.isEven
                  ? AppColors.white
                  : AppColors.white,
          border: const Border(
            bottom: BorderSide(color: AppColors.borderLight),
          ),
        ),
        child: Row(
          children: widget.cells.asMap().entries.map((e) {
            final width = widget.columnWidths != null
                ? widget.columnWidths![e.key]
                : null;
            return SizedBox(width: width, child: e.value);
          }).toList(),
        ),
      ),
    );
  }
}

class EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Widget? action;

  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.action,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: const BoxDecoration(
              color: AppColors.goldSurface,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 32, color: AppColors.gold),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(title, style: AppTypography.headlineSmall),
          const SizedBox(height: AppSpacing.xs),
          Text(subtitle, style: AppTypography.bodySmall),
          if (action != null) ...[
            const SizedBox(height: AppSpacing.lg),
            action!,
          ],
        ],
      ),
    );
  }
}
