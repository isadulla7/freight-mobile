import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/di/service_locator.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/status_badge.dart';
import '../bloc/load_detail_bloc.dart';
import '../../loads/data/models/load_models.dart';
import '../../offers/data/models/offer_models.dart';
import '../../offers/presentation/create_offer_sheet.dart';

class LoadDetailScreen extends StatelessWidget {
  final String loadId;
  const LoadDetailScreen({super.key, required this.loadId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => LoadDetailBloc(sl.loadRepository, sl.offerRepository)
        ..add(LoadDetailFetchRequested(loadId)),
      child: _LoadDetailView(loadId: loadId),
    );
  }
}

class _LoadDetailView extends StatelessWidget {
  final String loadId;
  const _LoadDetailView({required this.loadId});

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
      body: BlocConsumer<LoadDetailBloc, LoadDetailState>(
        listener: (context, state) {
          if (state is LoadDetailOfferSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Taklif muvaffaqiyatli yuborildi')),
            );
            context.read<LoadDetailBloc>().add(LoadDetailFetchRequested(loadId));
          } else if (state is LoadDetailError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
        },
        builder: (context, state) {
          if (state is LoadDetailLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is LoadDetailLoaded) {
            return _buildContent(context, state.load, state.offers);
          }
          if (state is LoadDetailError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(state.message),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: () => context
                        .read<LoadDetailBloc>()
                        .add(LoadDetailFetchRequested(loadId)),
                    child: const Text('Qayta urinish'),
                  ),
                ],
              ),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    LoadResponse load,
    List<OfferResponse> offers,
  ) {
    return SingleChildScrollView(
      child: Column(
        children: [
          _buildMap(load),
          _buildRouteHeader(load),
          _buildDetails(load),
          if (offers.isNotEmpty) _buildOffersList(offers),
          if (load.status == 'PUBLISHED') _buildCtaButton(context),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildMap(LoadResponse load) {
    return Container(
      height: 200,
      color: AppColors.primarySurface,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.map_outlined, size: 48, color: AppColors.primary),
            const SizedBox(height: 8),
            Text(
              '${load.pickupCity} → ${load.deliveryCity}',
              style: const TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRouteHeader(LoadResponse load) {
    final statusBadge = switch (load.status) {
      'DRAFT' => BadgeType.draft,
      'PUBLISHED' => BadgeType.published,
      'MATCHED' => BadgeType.matched,
      'CANCELLED' => BadgeType.cancelled,
      _ => BadgeType.draft,
    };

    final statusLabel = switch (load.status) {
      'DRAFT' => 'Qoralama',
      'PUBLISHED' => 'Faol',
      'MATCHED' => 'Mos topildi',
      'CANCELLED' => 'Bekor',
      'EXPIRED' => 'Muddati tugadi',
      _ => load.status,
    };

    return Container(
      padding: const EdgeInsets.all(16),
      color: AppColors.surface,
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${load.pickupCity} → ${load.deliveryCity}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  load.formattedPrice,
                  style: const TextStyle(
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
              StatusBadge(label: statusLabel, type: statusBadge),
              if (load.formattedWeight.isNotEmpty) ...[
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.badgeGreen,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    load.formattedWeight,
                    style: const TextStyle(
                      color: AppColors.badgeGreenText,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDetails(LoadResponse load) {
    final details = <(IconData, String, String)>[
      if (load.cargoType != null)
        (Icons.category_outlined, 'Yuk turi', load.cargoType!),
      if (load.cargoDescription != null)
        (Icons.inventory_2_outlined, 'Yuk tavsifi', load.cargoDescription!),
      if (load.formattedVolume.isNotEmpty)
        (Icons.straighten, 'Yuk hajmi', load.formattedVolume),
      if (load.cargoWeightKg != null)
        (Icons.fitness_center, 'Yuk og\'irligi', '${load.cargoWeightKg} kg'),
      if (load.pricingMode != null)
        (Icons.payments_outlined, 'Narx turi',
            load.pricingMode == 'FIXED' ? 'Belgilangan' : 'Taklif asosida'),
      if (load.routeType != null)
        (Icons.route, 'Marshrut turi', load.routeType!),
    ];

    for (final stop in load.stops) {
      final label = switch (stop.stopType) {
        'PICKUP' => 'Yuklash manzili',
        'DELIVERY' => 'Tushirish manzili',
        _ => 'To\'xtash joyi',
      };
      final icon = stop.stopType == 'PICKUP'
          ? Icons.location_on_outlined
          : Icons.location_on;
      final value =
          [stop.city, stop.address].where((s) => s != null && s.isNotEmpty).join(', ');
      if (value.isNotEmpty) {
        details.add((icon, label, value));
      }
    }

    if (details.isEmpty) return const SizedBox.shrink();

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
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                child: Row(
                  children: [
                    Icon(d.$1, size: 20, color: AppColors.textSecondary),
                    const SizedBox(width: 12),
                    Text(
                      d.$2,
                      style: const TextStyle(
                          fontSize: 14, color: AppColors.textSecondary),
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

  Widget _buildOffersList(List<OfferResponse> offers) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.divider, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
            child: Text(
              'Takliflar (${offers.length})',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          ...offers.map((offer) => ListTile(
                leading: CircleAvatar(
                  backgroundColor: AppColors.primarySurface,
                  child: Text(
                    offer.formattedAmount.substring(0, 1),
                    style: const TextStyle(color: AppColors.primary),
                  ),
                ),
                title: Text(
                  offer.formattedAmount,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                subtitle: offer.message != null
                    ? Text(offer.message!,
                        maxLines: 1, overflow: TextOverflow.ellipsis)
                    : null,
                trailing: StatusBadge(
                  label: offer.statusLabel,
                  type: switch (offer.status) {
                    'PENDING' => BadgeType.draft,
                    'ACCEPTED' => BadgeType.published,
                    'REJECTED' => BadgeType.cancelled,
                    _ => BadgeType.draft,
                  },
                ),
              )),
        ],
      ),
    );
  }

  Widget _buildCtaButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: ElevatedButton(
        onPressed: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
            ),
            builder: (_) => BlocProvider.value(
              value: context.read<LoadDetailBloc>(),
              child: CreateOfferSheet(loadId: loadId),
            ),
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.accent,
          foregroundColor: Colors.white,
        ),
        child: const Text('Taklif berish'),
      ),
    );
  }
}
