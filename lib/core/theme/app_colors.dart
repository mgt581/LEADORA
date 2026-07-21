import 'package:flutter/material.dart';

/// Leadora brand colours
class AppColors {
  AppColors._();

  // --- Gold accent ---
  static const Color gold = Color(0xFFC9A84C);
  static const Color goldLight = Color(0xFFDDBD6A);
  static const Color goldDark = Color(0xFFA8863A);
  static const Color goldSurface = Color(0xFFFBF6EA);

  // --- Sidebar (dark) ---
  static const Color sidebarBg = Color(0xFF0D0D0D);
  static const Color sidebarHover = Color(0xFF1A1A1A);
  static const Color sidebarActive = Color(0xFF1F1F1F);
  static const Color sidebarText = Color(0xFFB0B0B0);
  static const Color sidebarTextActive = Color(0xFFFFFFFF);
  static const Color sidebarDivider = Color(0xFF2A2A2A);

  // --- Content area ---
  static const Color contentBg = Color(0xFFF4F5F7);
  static const Color cardBg = Color(0xFFFFFFFF);
  static const Color cardBorder = Color(0xFFEEEEEE);

  // --- Text ---
  static const Color textPrimary = Color(0xFF0D0D0D);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color textTertiary = Color(0xFF9CA3AF);
  static const Color textHint = Color(0xFFD1D5DB);

  // --- Status ---
  static const Color success = Color(0xFF10B981);
  static const Color successSurface = Color(0xFFECFDF5);
  static const Color warning = Color(0xFFF59E0B);
  static const Color warningSurface = Color(0xFFFFFBEB);
  static const Color error = Color(0xFFEF4444);
  static const Color errorSurface = Color(0xFFFEF2F2);
  static const Color info = Color(0xFF3B82F6);
  static const Color infoSurface = Color(0xFFEFF6FF);

  // --- Lead status badges ---
  static const Color badgeNew = Color(0xFF6366F1);
  static const Color badgeNewSurface = Color(0xFFEEF2FF);
  static const Color badgeContacted = Color(0xFF3B82F6);
  static const Color badgeContactedSurface = Color(0xFFEFF6FF);
  static const Color badgeQualified = Color(0xFF10B981);
  static const Color badgeQualifiedSurface = Color(0xFFECFDF5);
  static const Color badgeProposal = Color(0xFFF59E0B);
  static const Color badgeProposalSurface = Color(0xFFFFFBEB);
  static const Color badgeWon = Color(0xFF059669);
  static const Color badgeWonSurface = Color(0xFFD1FAE5);
  static const Color badgeLost = Color(0xFFEF4444);
  static const Color badgeLostSurface = Color(0xFFFEE2E2);

  // --- Chart palette ---
  static const List<Color> chartPalette = [
    gold,
    Color(0xFF6366F1),
    Color(0xFF10B981),
    Color(0xFF3B82F6),
    Color(0xFFF59E0B),
    Color(0xFF8B5CF6),
  ];

  // --- Shadow ---
  static const List<BoxShadow> cardShadow = [
    BoxShadow(
      color: Color(0x0A000000),
      blurRadius: 8,
      offset: Offset(0, 2),
    ),
    BoxShadow(
      color: Color(0x06000000),
      blurRadius: 24,
      offset: Offset(0, 8),
    ),
  ];

  static const List<BoxShadow> elevatedShadow = [
    BoxShadow(
      color: Color(0x14000000),
      blurRadius: 16,
      offset: Offset(0, 4),
    ),
    BoxShadow(
      color: Color(0x08000000),
      blurRadius: 40,
      offset: Offset(0, 16),
    ),
  ];
}
