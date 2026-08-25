import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/di/service_locator.dart';
import '../../../core/theme/app_colors.dart';
import '../../load_detail/bloc/load_detail_bloc.dart';
import '../../vehicles/data/models/vehicle_models.dart';
import '../data/models/offer_models.dart';

class CreateOfferSheet extends StatefulWidget {
  final String loadId;
  const CreateOfferSheet({super.key, required this.loadId});

  @override
  State<CreateOfferSheet> createState() => _CreateOfferSheetState();
}

class _CreateOfferSheetState extends State<CreateOfferSheet> {
  final _amountController = TextEditingController();
  final _messageController = TextEditingController();

  bool _isLoading = true;
  String? _driverProfileId;
  List<VehicleResponse> _vehicles = [];
  VehicleResponse? _selectedVehicle;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final eligibility = await sl.userRepository.getDriverEligibility();
      if (!eligibility.hasDriverProfile || eligibility.profileId == null) {
        setState(() {
          _error = 'Avval haydovchi profilini yarating';
          _isLoading = false;
        });
        return;
      }

      final vehicles = await sl.vehicleRepository.getMyVehicles();
      if (vehicles.isEmpty) {
        setState(() {
          _error = 'Avval transport qo\'shing';
          _isLoading = false;
        });
        return;
      }

      setState(() {
        _driverProfileId = eligibility.profileId;
        _vehicles = vehicles.where((v) => v.status == 'ACTIVE').toList();
        if (_vehicles.isNotEmpty) _selectedVehicle = _vehicles.first;
        _isLoading = false;
      });
    } catch (_) {
      setState(() {
        _error = 'Ma\'lumotlarni yuklashda xatolik';
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  void _submit() {
    final amount =
        int.tryParse(_amountController.text.replaceAll(RegExp(r'[^\d]'), ''));
    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Narxni kiriting')),
      );
      return;
    }

    if (_selectedVehicle == null || _driverProfileId == null) return;

    final payload = CreateOfferPayload(
      loadId: widget.loadId,
      driverProfileId: _driverProfileId!,
      vehicleId: _selectedVehicle!.vehicleId,
      amount: amount,
      currency: 'UZS',
      message: _messageController.text.trim().isNotEmpty
          ? _messageController.text.trim()
          : null,
    );

    context.read<LoadDetailBloc>().add(LoadDetailOfferSubmitted(payload));
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        16,
        16,
        16,
        16 + MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
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
          const Text(
            'Taklif berish',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.all(24),
              child: Center(child: CircularProgressIndicator()),
            )
          else if (_error != null)
            Padding(
              padding: const EdgeInsets.all(24),
              child: Center(
                child: Text(
                  _error!,
                  style: const TextStyle(
                      fontSize: 14, color: AppColors.textSecondary),
                ),
              ),
            )
          else ...[
            if (_vehicles.length > 1)
              DropdownButtonFormField<VehicleResponse>(
                initialValue: _selectedVehicle,
                decoration: const InputDecoration(
                  labelText: 'Transport',
                  prefixIcon: Icon(Icons.local_shipping_outlined),
                ),
                items: _vehicles
                    .map((v) => DropdownMenuItem(
                          value: v,
                          child: Text(v.plateNumber),
                        ))
                    .toList(),
                onChanged: (v) => setState(() => _selectedVehicle = v),
              )
            else
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: AppColors.primarySurface,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.local_shipping_outlined,
                        color: AppColors.primary, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      _selectedVehicle?.plateNumber ?? '',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 12),
            TextField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: const InputDecoration(
                labelText: 'Narx (UZS)',
                prefixIcon: Icon(Icons.payments_outlined),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _messageController,
              maxLines: 2,
              decoration: const InputDecoration(
                labelText: 'Xabar (ixtiyoriy)',
                prefixIcon: Icon(Icons.message_outlined),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _submit,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accent,
                foregroundColor: Colors.white,
              ),
              child: const Text('Taklif yuborish'),
            ),
          ],
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}
