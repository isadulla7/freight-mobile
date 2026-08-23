import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/di/service_locator.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/status_badge.dart';
import '../data/models/vehicle_models.dart';

class VehiclesScreen extends StatefulWidget {
  const VehiclesScreen({super.key});

  @override
  State<VehiclesScreen> createState() => _VehiclesScreenState();
}

class _VehiclesScreenState extends State<VehiclesScreen> {
  List<VehicleResponse> _vehicles = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final response = await sl.vehicleRepository.getMyVehicles();
      setState(() {
        _vehicles = response;
        _isLoading = false;
      });
    } catch (_) {
      setState(() {
        _error = 'Transportlarni yuklashda xatolik';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Transportlar')),
      body: _buildBody(),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await context.push('/vehicles/create');
          _load();
        },
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: AppColors.error),
            const SizedBox(height: 16),
            Text(_error!,
                style: const TextStyle(color: AppColors.textSecondary)),
            const SizedBox(height: 8),
            TextButton(onPressed: _load, child: const Text('Qayta urinish')),
          ],
        ),
      );
    }
    if (_vehicles.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.directions_car_outlined,
                size: 64, color: AppColors.textMuted),
            const SizedBox(height: 16),
            const Text(
              'Hozircha transportlar yo\'q',
              style: TextStyle(fontSize: 16, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () async {
                await context.push('/vehicles/create');
                _load();
              },
              icon: const Icon(Icons.add),
              label: const Text('Transport qo\'shish'),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _load,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _vehicles.length,
        itemBuilder: (context, index) => _VehicleCard(
          vehicle: _vehicles[index],
          onTap: () => _showVehicleDetail(_vehicles[index]),
        ),
      ),
    );
  }

  void _showVehicleDetail(VehicleResponse vehicle) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => _VehicleDetailSheet(
        vehicle: vehicle,
        onDelete: () async {
          Navigator.of(context).pop();
          try {
            await sl.vehicleRepository.deleteVehicle(vehicle.vehicleId);
            _load();
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Transport o\'chirildi')),
              );
            }
          } catch (_) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content: Text('Transport o\'chirishda xatolik')),
              );
            }
          }
        },
      ),
    );
  }
}

class _VehicleCard extends StatelessWidget {
  final VehicleResponse vehicle;
  final VoidCallback onTap;

  const _VehicleCard({required this.vehicle, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final badgeType = switch (vehicle.status) {
      'ACTIVE' => BadgeType.published,
      'DEACTIVATED' => BadgeType.cancelled,
      _ => BadgeType.draft,
    };
    final statusLabel = switch (vehicle.status) {
      'ACTIVE' => 'Faol',
      'DEACTIVATED' => 'O\'chirilgan',
      _ => vehicle.status,
    };

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.primarySurface,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.local_shipping,
                    color: AppColors.primary, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      vehicle.plateNumber,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    if (vehicle.formattedCapacity.isNotEmpty)
                      Text(
                        'Yuk ko\'tarish: ${vehicle.formattedCapacity}',
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                        ),
                      ),
                  ],
                ),
              ),
              StatusBadge(label: statusLabel, type: badgeType),
            ],
          ),
        ),
      ),
    );
  }
}

class _VehicleDetailSheet extends StatelessWidget {
  final VehicleResponse vehicle;
  final VoidCallback onDelete;

  const _VehicleDetailSheet({
    required this.vehicle,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.divider,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: AppColors.primarySurface,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(Icons.local_shipping,
                    color: AppColors.primary, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      vehicle.plateNumber,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    StatusBadge(
                      label: vehicle.status == 'ACTIVE'
                          ? 'Faol'
                          : 'O\'chirilgan',
                      type: vehicle.status == 'ACTIVE'
                          ? BadgeType.published
                          : BadgeType.cancelled,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                if (vehicle.formattedCapacity.isNotEmpty)
                  _detailRow(Icons.fitness_center, 'Yuk ko\'tarish',
                      vehicle.formattedCapacity),
                if (vehicle.volumeM3 != null)
                  _detailRow(
                      Icons.straighten, 'Hajm', '${vehicle.volumeM3} m³'),
                _detailRow(Icons.fingerprint, 'ID',
                    vehicle.vehicleId.substring(0, 8)),
              ],
            ),
          ),
          const SizedBox(height: 16),
          if (vehicle.status == 'ACTIVE')
            OutlinedButton.icon(
              onPressed: onDelete,
              icon: const Icon(Icons.delete_outline, color: AppColors.error),
              label: const Text('O\'chirish',
                  style: TextStyle(color: AppColors.error)),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppColors.error),
              ),
            ),
          SizedBox(height: MediaQuery.of(context).padding.bottom + 8),
        ],
      ),
    );
  }

  Widget _detailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppColors.textSecondary),
          const SizedBox(width: 12),
          Text(label,
              style: const TextStyle(
                  fontSize: 14, color: AppColors.textSecondary)),
          const Spacer(),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
