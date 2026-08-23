import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class LoadCard extends StatelessWidget {
  final String origin;
  final String destination;
  final String weight;
  final String price;
  final String date;
  final String? vehicleType;
  final String? volume;
  final bool showHeart;
  final VoidCallback? onTap;
  final VoidCallback? onFavoriteTap;

  const LoadCard({
    super.key,
    required this.origin,
    required this.destination,
    required this.weight,
    required this.price,
    required this.date,
    this.vehicleType,
    this.volume,
    this.showHeart = false,
    this.onTap,
    this.onFavoriteTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const _RouteDot(color: AppColors.success),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '$origin → $destination',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.badgeGreen,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    weight,
                    style: const TextStyle(
                      color: AppColors.badgeGreenText,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              date,
              style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
            ),
            if (vehicleType != null) ...[
              const SizedBox(height: 2),
              Text(
                vehicleType!,
                style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
              ),
            ],
            const SizedBox(height: 6),
            Row(
              children: [
                if (volume != null)
                  Text(
                    'Yuk hajmi: $volume',
                    style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
                  ),
                const Spacer(),
                Text(
                  price,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
            if (showHeart)
              Align(
                alignment: Alignment.centerRight,
                child: IconButton(
                  icon: const Icon(Icons.favorite_border, size: 20),
                  color: AppColors.textMuted,
                  onPressed: onFavoriteTap,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _RouteDot extends StatelessWidget {
  final Color color;
  const _RouteDot({required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 10,
      height: 10,
      decoration: BoxDecoration(shape: BoxShape.circle, color: color),
    );
  }
}
