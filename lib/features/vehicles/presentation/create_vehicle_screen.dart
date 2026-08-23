import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../../../core/di/service_locator.dart';
import '../../../core/theme/app_colors.dart';
import '../data/models/vehicle_models.dart';

class CreateVehicleScreen extends StatefulWidget {
  const CreateVehicleScreen({super.key});

  @override
  State<CreateVehicleScreen> createState() => _CreateVehicleScreenState();
}

class _CreateVehicleScreenState extends State<CreateVehicleScreen> {
  final _formKey = GlobalKey<FormState>();
  final _plateController = TextEditingController();
  final _capacityController = TextEditingController();
  final _volumeController = TextEditingController();
  final _yearController = TextEditingController();

  List<ReferenceEntry> _vehicleTypes = [];
  List<ReferenceEntry> _bodyTypes = [];
  String? _selectedVehicleTypeId;
  String? _selectedBodyTypeId;
  bool _isLoading = false;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _loadReferenceData();
  }

  Future<void> _loadReferenceData() async {
    setState(() => _isLoading = true);
    try {
      final results = await Future.wait([
        sl.vehicleRepository.getVehicleTypes(),
        sl.vehicleRepository.getBodyTypes(),
      ]);
      setState(() {
        _vehicleTypes = results[0];
        _bodyTypes = results[1];
        _isLoading = false;
      });
    } catch (_) {
      setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _plateController.dispose();
    _capacityController.dispose();
    _volumeController.dispose();
    _yearController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedVehicleTypeId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Transport turini tanlang')),
      );
      return;
    }

    setState(() => _isSubmitting = true);
    try {
      await sl.vehicleRepository.createVehicle(CreateVehiclePayload(
        vehicleTypeId: _selectedVehicleTypeId!,
        bodyTypeId: _selectedBodyTypeId,
        plateNumber: _plateController.text.trim(),
        capacityKg: int.tryParse(_capacityController.text.trim()),
        volumeM3: int.tryParse(_volumeController.text.trim()),
        manufactureYear: int.tryParse(_yearController.text.trim()),
      ));
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Transport muvaffaqiyatli qo\'shildi')),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Transport qo\'shishda xatolik')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Transport qo\'shish')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  _buildCard([
                    DropdownButtonFormField<String>(
                      value: _selectedVehicleTypeId,
                      decoration: const InputDecoration(
                        labelText: 'Transport turi',
                        prefixIcon: Icon(Icons.local_shipping_outlined),
                      ),
                      items: _vehicleTypes
                          .map((t) => DropdownMenuItem(
                                value: t.id,
                                child: Text(t.displayName),
                              ))
                          .toList(),
                      onChanged: (v) =>
                          setState(() => _selectedVehicleTypeId = v),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      value: _selectedBodyTypeId,
                      decoration: const InputDecoration(
                        labelText: 'Kuzov turi (ixtiyoriy)',
                        prefixIcon: Icon(Icons.view_in_ar_outlined),
                      ),
                      items: _bodyTypes
                          .map((t) => DropdownMenuItem(
                                value: t.id,
                                child: Text(t.displayName),
                              ))
                          .toList(),
                      onChanged: (v) =>
                          setState(() => _selectedBodyTypeId = v),
                    ),
                  ]),
                  const SizedBox(height: 16),
                  _buildCard([
                    TextFormField(
                      controller: _plateController,
                      validator: (v) =>
                          v == null || v.trim().isEmpty ? 'Majburiy' : null,
                      textCapitalization: TextCapitalization.characters,
                      decoration: const InputDecoration(
                        labelText: 'Davlat raqami',
                        hintText: '01 A 123 BB',
                        prefixIcon: Icon(Icons.confirmation_number_outlined),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _capacityController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                      ],
                      decoration: const InputDecoration(
                        labelText: 'Yuk ko\'tarish sig\'imi (kg)',
                        prefixIcon: Icon(Icons.fitness_center),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _volumeController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                      ],
                      decoration: const InputDecoration(
                        labelText: 'Hajm (m³)',
                        prefixIcon: Icon(Icons.straighten),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _yearController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(4),
                      ],
                      decoration: const InputDecoration(
                        labelText: 'Ishlab chiqarilgan yili',
                        prefixIcon: Icon(Icons.calendar_today_outlined),
                      ),
                    ),
                  ]),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: _isSubmitting ? null : _submit,
                    child: _isSubmitting
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: Colors.white),
                          )
                        : const Text('Saqlash'),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
    );
  }

  Widget _buildCard(List<Widget> children) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.divider, width: 0.5),
      ),
      child: Column(children: children),
    );
  }
}
