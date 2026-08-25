import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/status_badge.dart';
import '../bloc/shipments_bloc.dart';
import '../data/models/shipment_models.dart';

class ShipmentsScreen extends StatefulWidget {
  const ShipmentsScreen({super.key});

  @override
  State<ShipmentsScreen> createState() => _ShipmentsScreenState();
}

class _ShipmentsScreenState extends State<ShipmentsScreen> {
  @override
  void initState() {
    super.initState();
    final bloc = context.read<ShipmentsBloc>();
    if (bloc.state is ShipmentsInitial) {
      bloc.add(const ShipmentsFetchRequested());
    }
  }

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
      ),
      body: BlocBuilder<ShipmentsBloc, ShipmentsState>(
        builder: (context, state) {
          if (state is ShipmentsLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is ShipmentsError) {
            return _buildError(state.message);
          }
          if (state is ShipmentsLoaded) {
            if (state.shipments.isEmpty) return _buildEmpty();
            return _buildList(state.shipments);
          }
          // ShipmentsInitial — hali yuklanmagan, "bo'sh" degani emas.
          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }

  Widget _buildList(List<ShipmentResponse> shipments) {
    return RefreshIndicator(
      onRefresh: () async {
        final bloc = context.read<ShipmentsBloc>();
        bloc.add(const ShipmentsFetchRequested());
        await bloc.stream.firstWhere(
          (s) => s is ShipmentsLoaded || s is ShipmentsError,
        );
      },
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: shipments.length,
        itemBuilder: (context, index) {
          final s = shipments[index];
          return _ShipmentCard(
            shipment: s,
            onTap: () => context.push('/shipments/${s.shipmentId}'),
          );
        },
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.local_shipping_outlined,
              size: 64, color: AppColors.textMuted),
          const SizedBox(height: 16),
          const Text(
            'Hozircha yetkazishlar yo\'q',
            style: TextStyle(fontSize: 16, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: () => context
                .read<ShipmentsBloc>()
                .add(const ShipmentsFetchRequested()),
            child: const Text('Yangilash'),
          ),
        ],
      ),
    );
  }

  Widget _buildError(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 48, color: AppColors.error),
          const SizedBox(height: 16),
          Text(message, style: const TextStyle(color: AppColors.textSecondary)),
          const SizedBox(height: 8),
          TextButton(
            onPressed: () => context
                .read<ShipmentsBloc>()
                .add(const ShipmentsFetchRequested()),
            child: const Text('Qayta urinish'),
          ),
        ],
      ),
    );
  }
}

class _ShipmentCard extends StatelessWidget {
  final ShipmentResponse shipment;
  final VoidCallback onTap;

  const _ShipmentCard({required this.shipment, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final badgeType = switch (shipment.status) {
      'IN_TRANSIT' || 'HEADING_TO_PICKUP' || 'AT_PICKUP' || 'LOADED' =>
        BadgeType.inTransit,
      'DELIVERED' || 'COMPLETED' => BadgeType.delivered,
      'CANCELLED' => BadgeType.cancelled,
      _ => BadgeType.draft,
    };

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      shipment.formattedAmount,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                  StatusBadge(
                    label: shipment.statusLabel,
                    type: badgeType,
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                'ID: ${shipment.shipmentId.substring(0, 8)}...',
                style: const TextStyle(
                    fontSize: 13, color: AppColors.textSecondary),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
