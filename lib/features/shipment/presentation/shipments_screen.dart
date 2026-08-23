import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/status_badge.dart';

class ShipmentsScreen extends StatelessWidget {
  const ShipmentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Yetkazish',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        centerTitle: false,
        actions: [
          IconButton(icon: const Icon(Icons.more_vert), onPressed: () {}),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildShipmentCard(
            status: "Yo'lda",
            badgeType: BadgeType.inTransit,
            origin: 'Toshkent',
            destination: 'Samarqand',
            code: 'FRG-2025-0521-7824',
          ),
          const SizedBox(height: 20),
          _buildTimeline(),
          const SizedBox(height: 20),
          _buildDriverCard(),
          const SizedBox(height: 16),
          OutlinedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.map_outlined),
            label: const Text("Yo'lni xaritada ko'rish"),
          ),
        ],
      ),
    );
  }

  Widget _buildShipmentCard({
    required String status,
    required BadgeType badgeType,
    required String origin,
    required String destination,
    required String code,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.divider, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '$origin → $destination',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              StatusBadge(label: status, type: badgeType),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'Yetkazish raqami: $code',
            style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeline() {
    final steps = [
      ('Yuk qabul qilindi', '21-may, 09:15', 'Toshkent, Sergeli tumani', _TimelineState.completed),
      ('Yuk yuklandi', '21-may, 10:30', 'Toshkent, Sergeli tumani', _TimelineState.completed),
      ("Yo'lda", '21-may, 11:45', "Jizzax viloyati, Zomin yo'li", _TimelineState.active),
      ('Tushirish manziliga yetib boradi', '21-may, 15:30 (taxminiy)', "Samarqand, Pastdarg'om", _TimelineState.pending),
      ('Yetkazib berildi', '21-may, 16:00 (taxminiy)', '', _TimelineState.pending),
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.divider, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Holat tarixi',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          ...steps.asMap().entries.map((e) {
            final s = e.value;
            final isLast = e.key == steps.length - 1;
            return _TimelineStep(
              title: s.$1,
              date: s.$2,
              location: s.$3,
              state: s.$4,
              isLast: isLast,
            );
          }),
        ],
      ),
    );
  }

  Widget _buildDriverCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.divider, width: 0.5),
      ),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 24,
            backgroundColor: AppColors.primarySurface,
            child: Text(
              'BE',
              style: TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Behzod Ergashev',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    const Icon(Icons.star, color: AppColors.warning, size: 14),
                    const SizedBox(width: 2),
                    const Text(
                      '4.8 (128)',
                      style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                    ),
                    const SizedBox(width: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        border: Border.all(color: AppColors.divider),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text(
                        '01 A 123 BB',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                const Text(
                  'MAN TGX 18.440',
                  style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.phone, color: AppColors.primary),
            style: IconButton.styleFrom(
              backgroundColor: AppColors.primarySurface,
            ),
          ),
        ],
      ),
    );
  }
}

enum _TimelineState { completed, active, pending }

class _TimelineStep extends StatelessWidget {
  final String title;
  final String date;
  final String location;
  final _TimelineState state;
  final bool isLast;

  const _TimelineStep({
    required this.title,
    required this.date,
    required this.location,
    required this.state,
    required this.isLast,
  });

  @override
  Widget build(BuildContext context) {
    final color = switch (state) {
      _TimelineState.completed => AppColors.success,
      _TimelineState.active => AppColors.primary,
      _TimelineState.pending => AppColors.textMuted,
    };

    final icon = switch (state) {
      _TimelineState.completed => Icons.check,
      _TimelineState.active => Icons.arrow_forward,
      _TimelineState.pending => Icons.circle_outlined,
    };

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: state == _TimelineState.pending
                      ? AppColors.background
                      : color.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 16, color: color),
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2,
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    color: state == _TimelineState.pending
                        ? AppColors.divider
                        : AppColors.primary.withValues(alpha: 0.3),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: state == _TimelineState.active
                          ? AppColors.primary
                          : state == _TimelineState.pending
                              ? AppColors.textMuted
                              : AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    date,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  if (location.isNotEmpty)
                    Text(
                      location,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
