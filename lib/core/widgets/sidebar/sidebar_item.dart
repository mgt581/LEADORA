import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';

class SidebarItem extends StatefulWidget {
  final IconData icon;
  final String label;
  final bool collapsed;
  final bool isActive;
  final VoidCallback onTap;

  const SidebarItem({
    super.key,
    required this.icon,
    required this.label,
    required this.collapsed,
    required this.isActive,
    required this.onTap,
  });

  @override
  State<SidebarItem> createState() => _SidebarItemState();
}

class _SidebarItemState extends State<SidebarItem> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final active = widget.isActive;
    final hovered = _hovered;

    return Padding(
      padding: const EdgeInsets.only(bottom: 2),
      child: MouseRegion(
        onEnter: (_) => setState(() => _hovered = true),
        onExit: (_) => setState(() => _hovered = false),
        child: GestureDetector(
          onTap: widget.onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            height: 38,
            decoration: BoxDecoration(
              color: active
                  ? AppColors.sidebarActive
                  : hovered
                      ? AppColors.sidebarHover
                      : Colors.transparent,
              borderRadius: BorderRadius.circular(8),
              border: active
                  ? Border.all(color: AppColors.gold.withValues(alpha: 0.15), width: 1)
                  : Border.all(color: Colors.transparent, width: 1),
            ),
            child: Row(
              children: [
                SizedBox(
                  width: widget.collapsed ? double.infinity : 38,
                  child: Center(
                    child: Icon(
                      widget.icon,
                      size: 18,
                      color: active
                          ? AppColors.gold
                          : hovered
                              ? AppColors.sidebarTextActive
                              : AppColors.sidebarText,
                    ),
                  ),
                ),
                if (!widget.collapsed) ...[
                  Expanded(
                    child: Text(
                      widget.label,
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 13,
                        fontWeight: active ? FontWeight.w600 : FontWeight.w400,
                        color: active
                            ? AppColors.sidebarTextActive
                            : hovered
                                ? AppColors.sidebarTextActive
                                : AppColors.sidebarText,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (active)
                    Container(
                      width: 4,
                      height: 4,
                      margin: const EdgeInsets.only(right: 12),
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.gold,
                      ),
                    ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
