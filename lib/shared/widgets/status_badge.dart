import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

enum BadgeType { published, draft, inTransit, delivered, cancelled, matched }

class StatusBadge extends StatelessWidget {
  final String label;
  final BadgeType type;

  const StatusBadge({super.key, required this.label, required this.type});

  @override
  Widget build(BuildContext context) {
    final (bg, fg) = switch (type) {
      BadgeType.published => (AppColors.badgeGreen, AppColors.badgeGreenText),
      BadgeType.draft => (AppColors.badgeGray, AppColors.badgeGrayText),
      BadgeType.inTransit => (AppColors.badgeBlue, AppColors.badgeBlueText),
      BadgeType.delivered => (AppColors.badgeGreen, AppColors.badgeGreenText),
      BadgeType.cancelled => (AppColors.badgeRed, AppColors.badgeRedText),
      BadgeType.matched => (AppColors.badgeBlue, AppColors.badgeBlueText),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: fg,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
