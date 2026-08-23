import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class LoadDetailScreen extends StatelessWidget {
  final String loadId;
  const LoadDetailScreen({super.key, required this.loadId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Yuk tafsilotlari'),
        actions: [
          IconButton(
            icon: const Icon(Icons.favorite_border),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildMap(),
            _buildRouteHeader(),
            _buildDetails(),
            _buildCtaButton(context),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildMap() {
    return Container(
      height: 220,
      color: AppColors.primarySurface,
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.map_outlined, size: 48, color: AppColors.primary),
            SizedBox(height: 8),
            Text(
              'Toshkent → Samarqand',
              style: TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRouteHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: AppColors.surface,
      child: Row(
        children: [
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Toshkent → Samarqand',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  '4 500 000 UZS',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.badgeGreen,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  '12 t',
                  style: TextStyle(
                    color: AppColors.badgeGreenText,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Takliflar: 7',
                style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDetails() {
    final details = [
      (Icons.local_shipping_outlined, 'Yuk turi', 'Tentli yuk'),
      (Icons.inventory_2_outlined, 'Yuk tavsifi', 'Qurilish materiallari'),
      (Icons.straighten, 'Yuk hajmi', '82 m³'),
      (Icons.fitness_center, 'Yuk og\'irligi', '12 000 kg'),
      (Icons.calendar_today_outlined, 'Yuklash sanasi', 'Bugun, 14:00'),
      (Icons.location_on_outlined, 'Yuklash manzili', 'Toshkent, Sergeli tumani'),
      (Icons.location_on, 'Tushirish manzili', 'Samarqand, Pastdarg\'om'),
      (Icons.credit_card_outlined, 'To\'lov turi', 'Naqd / Hisob-kitob'),
      (Icons.notes_outlined, 'Izoh', 'Orqa yuklash'),
    ];

    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.divider, width: 0.5),
      ),
      child: Column(
        children: details.asMap().entries.map((e) {
          final d = e.value;
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                child: Row(
                  children: [
                    Icon(d.$1, size: 20, color: AppColors.textSecondary),
                    const SizedBox(width: 12),
                    Text(
                      d.$2,
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const Spacer(),
                    Flexible(
                      child: Text(
                        d.$3,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textPrimary,
                        ),
                        textAlign: TextAlign.right,
                      ),
                    ),
                  ],
                ),
              ),
              if (e.key < details.length - 1)
                const Divider(height: 0, indent: 48),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildCtaButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ElevatedButton(
        onPressed: () {},
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.accent,
          foregroundColor: Colors.white,
        ),
        child: const Text('Taklif berish'),
      ),
    );
  }
}
