import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';

/// Standard white card panel with soft shadow and rounded corners.
class AppCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final double borderRadius;
  final Color? backgroundColor;
  final Border? border;
  final List<BoxShadow>? boxShadow;
  final VoidCallback? onTap;
  final double? width;
  final double? height;

  const AppCard({
    super.key,
    required this.child,
    this.padding,
    this.borderRadius = 12,
    this.backgroundColor,
    this.border,
    this.boxShadow,
    this.onTap,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    Widget card = Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: backgroundColor ?? AppColors.cardBg,
        borderRadius: BorderRadius.circular(borderRadius),
        border: border ?? Border.all(color: AppColors.cardBorder, width: 1),
        boxShadow: boxShadow ?? AppColors.cardShadow,
      ),
      clipBehavior: Clip.antiAlias,
      child: padding != null
          ? Padding(padding: padding!, child: child)
          : child,
    );

    if (onTap != null) {
      card = InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(borderRadius),
        child: card,
      );
    }

    return card;
  }
}

/// Section header used above content panels.
class SectionHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget? trailing;

  const SectionHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: Theme.of(context).textTheme.titleLarge),
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    subtitle!,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ],
            ),
          ),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}

/// Page wrapper with standard padding and scroll.
class PageWrapper extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final bool scrollable;

  const PageWrapper({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(28),
    this.scrollable = true,
  });

  @override
  Widget build(BuildContext context) {
    final content = Padding(padding: padding, child: child);
    if (!scrollable) return content;
    return SingleChildScrollView(child: content);
  }
}

/// Gold primary button.
class PrimaryButton extends StatelessWidget {
  final String label;
  final IconData? icon;
  final VoidCallback? onPressed;
  final bool loading;
  final bool small;

  const PrimaryButton({
    super.key,
    required this.label,
    this.icon,
    this.onPressed,
    this.loading = false,
    this.small = false,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: loading ? null : onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.gold,
        foregroundColor: Colors.white,
        elevation: 0,
        padding: small
            ? const EdgeInsets.symmetric(horizontal: 14, vertical: 8)
            : const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      child: loading
          ? const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            )
          : Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (icon != null) ...[
                  Icon(icon, size: small ? 14 : 16),
                  const SizedBox(width: 6),
                ],
                Text(
                  label,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: small ? 12 : 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
    );
  }
}

/// Secondary outlined button.
class SecondaryButton extends StatelessWidget {
  final String label;
  final IconData? icon;
  final VoidCallback? onPressed;
  final bool small;

  const SecondaryButton({
    super.key,
    required this.label,
    this.icon,
    this.onPressed,
    this.small = false,
  });

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.textPrimary,
        side: const BorderSide(color: AppColors.cardBorder),
        padding: small
            ? const EdgeInsets.symmetric(horizontal: 14, vertical: 8)
            : const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: small ? 14 : 16),
            const SizedBox(width: 6),
          ],
          Text(
            label,
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: small ? 12 : 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

/// Status badge chip.
class StatusBadge extends StatelessWidget {
  final String label;
  final Color color;
  final Color surface;

  const StatusBadge({
    super.key,
    required this.label,
    required this.color,
    required this.surface,
  });

  factory StatusBadge.fromStatus(String status) {
    switch (status.toLowerCase()) {
      case 'new':
        return StatusBadge(label: status, color: AppColors.badgeNew, surface: AppColors.badgeNewSurface);
      case 'contacted':
        return StatusBadge(label: status, color: AppColors.badgeContacted, surface: AppColors.badgeContactedSurface);
      case 'qualified':
        return StatusBadge(label: status, color: AppColors.badgeQualified, surface: AppColors.badgeQualifiedSurface);
      case 'proposal':
        return StatusBadge(label: status, color: AppColors.badgeProposal, surface: AppColors.badgeProposalSurface);
      case 'won':
        return StatusBadge(label: status, color: AppColors.badgeWon, surface: AppColors.badgeWonSurface);
      case 'lost':
        return StatusBadge(label: status, color: AppColors.badgeLost, surface: AppColors.badgeLostSurface);
      case 'active':
        return StatusBadge(label: status, color: AppColors.success, surface: AppColors.successSurface);
      case 'paused':
        return StatusBadge(label: status, color: AppColors.warning, surface: AppColors.warningSurface);
      default:
        return StatusBadge(label: status, color: AppColors.textSecondary, surface: AppColors.contentBg);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(100),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontFamily: 'Inter',
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}

/// Metric delta chip (green/red).
class DeltaBadge extends StatelessWidget {
  final String value;
  final bool positive;

  const DeltaBadge({super.key, required this.value, required this.positive});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          positive ? Icons.arrow_upward_rounded : Icons.arrow_downward_rounded,
          size: 12,
          color: positive ? AppColors.success : AppColors.error,
        ),
        const SizedBox(width: 2),
        Text(
          value,
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: positive ? AppColors.success : AppColors.error,
          ),
        ),
      ],
    );
  }
}

/// Empty state placeholder.
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
      child: Padding(
        padding: const EdgeInsets.all(48),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: AppColors.goldSurface,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 28, color: AppColors.gold),
            ),
            const SizedBox(height: 16),
            Text(title, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 6),
            Text(
              subtitle,
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
            if (action != null) ...[
              const SizedBox(height: 20),
              action!,
            ],
          ],
        ),
      ),
    );
  }
}

/// Data table with standard styling.
class AppDataTable extends StatelessWidget {
  final List<String> columns;
  final List<List<Widget>> rows;
  final List<double>? columnWidths;

  const AppDataTable({
    super.key,
    required this.columns,
    required this.rows,
    this.columnWidths,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Table(
        columnWidths: columnWidths != null
            ? {
                for (var i = 0; i < columnWidths!.length; i++)
                  i: FlexColumnWidth(columnWidths![i])
              }
            : null,
        children: [
          // Header
          TableRow(
            decoration: const BoxDecoration(color: AppColors.contentBg),
            children: columns
                .map((col) => Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      child: Text(
                        col,
                        style: const TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textSecondary,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ))
                .toList(),
          ),
          // Data rows
          ...rows.asMap().entries.map((entry) {
            return TableRow(
              decoration: BoxDecoration(
                color: entry.key.isEven ? AppColors.cardBg : AppColors.contentBg.withValues(alpha: 0.4),
                border: const Border(
                  bottom: BorderSide(color: AppColors.cardBorder, width: 1),
                ),
              ),
              children: entry.value
                  .map((cell) => Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        child: cell,
                      ))
                  .toList(),
            );
          }),
        ],
      ),
    );
  }
}

/// Search text field.
class SearchField extends StatelessWidget {
  final String hint;
  final ValueChanged<String>? onChanged;
  final TextEditingController? controller;

  const SearchField({
    super.key,
    this.hint = 'Search...',
    this.onChanged,
    this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 36,
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        style: const TextStyle(
          fontFamily: 'Inter',
          fontSize: 13,
          color: AppColors.textPrimary,
        ),
        decoration: InputDecoration(
          hintText: hint,
          prefixIcon: const Icon(Icons.search_rounded, size: 16, color: AppColors.textTertiary),
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
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
        ),
      ),
    );
  }
}

/// Stat metric card used in dashboards.
class StatCard extends StatelessWidget {
  final String title;
  final String value;
  final String delta;
  final bool deltaPositive;
  final IconData icon;
  final Color iconColor;
  final Color iconBackground;

  const StatCard({
    super.key,
    required this.title,
    required this.value,
    required this.delta,
    required this.deltaPositive,
    required this.icon,
    this.iconColor = AppColors.gold,
    this.iconBackground = AppColors.goldSurface,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: iconBackground,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, size: 18, color: iconColor),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 28,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
              height: 1,
            ),
          ),
          const SizedBox(height: 8),
          DeltaBadge(value: delta, positive: deltaPositive),
          const SizedBox(height: 2),
          const Text(
            'vs last 7 days',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 11,
              color: AppColors.textTertiary,
            ),
          ),
        ],
      ),
    );
  }
}

/// Filter chip row.
class FilterChipRow extends StatefulWidget {
  final List<String> options;
  final String? selected;
  final ValueChanged<String> onSelected;

  const FilterChipRow({
    super.key,
    required this.options,
    this.selected,
    required this.onSelected,
  });

  @override
  State<FilterChipRow> createState() => _FilterChipRowState();
}

class _FilterChipRowState extends State<FilterChipRow> {
  late String _selected;

  @override
  void initState() {
    super.initState();
    _selected = widget.selected ?? widget.options.first;
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: widget.options.map((option) {
          final active = option == _selected;
          return Padding(
            padding: const EdgeInsets.only(right: 6),
            child: InkWell(
              onTap: () {
                setState(() => _selected = option);
                widget.onSelected(option);
              },
              borderRadius: BorderRadius.circular(6),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: active ? AppColors.goldSurface : Colors.transparent,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: active ? AppColors.gold.withValues(alpha: 0.4) : AppColors.cardBorder,
                  ),
                ),
                child: Text(
                  option,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 12,
                    fontWeight: active ? FontWeight.w600 : FontWeight.w400,
                    color: active ? AppColors.goldDark : AppColors.textSecondary,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
