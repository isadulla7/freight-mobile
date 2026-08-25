import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../bloc/loads_bloc.dart';
import '../data/models/load_models.dart';

class CreateLoadScreen extends StatefulWidget {
  const CreateLoadScreen({super.key});

  @override
  State<CreateLoadScreen> createState() => _CreateLoadScreenState();
}

class _CreateLoadScreenState extends State<CreateLoadScreen> {
  final _formKey = GlobalKey<FormState>();
  final _cargoTypeController = TextEditingController();
  final _cargoDescriptionController = TextEditingController();
  final _weightController = TextEditingController();
  final _volumeController = TextEditingController();
  final _priceController = TextEditingController();
  final _pickupCityController = TextEditingController();
  final _pickupAddressController = TextEditingController();
  final _deliveryCityController = TextEditingController();
  final _deliveryAddressController = TextEditingController();

  String _pricingMode = 'FIXED';

  @override
  void dispose() {
    _cargoTypeController.dispose();
    _cargoDescriptionController.dispose();
    _weightController.dispose();
    _volumeController.dispose();
    _priceController.dispose();
    _pickupCityController.dispose();
    _pickupAddressController.dispose();
    _deliveryCityController.dispose();
    _deliveryAddressController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    final stops = [
      LoadStopPayload(
        sequence: 1,
        stopType: 'PICKUP',
        city: _pickupCityController.text.trim(),
        address: _pickupAddressController.text.trim(),
        countryCode: 'UZ',
      ),
      LoadStopPayload(
        sequence: 2,
        stopType: 'DELIVERY',
        city: _deliveryCityController.text.trim(),
        address: _deliveryAddressController.text.trim(),
        countryCode: 'UZ',
      ),
    ];

    final weight = int.tryParse(_weightController.text.trim());
    final volume = int.tryParse(_volumeController.text.trim());
    final price = int.tryParse(
        _priceController.text.trim().replaceAll(RegExp(r'[^\d]'), ''));

    final payload = CreateLoadPayload(
      cargoType: _cargoTypeController.text.trim().isNotEmpty
          ? _cargoTypeController.text.trim()
          : null,
      cargoDescription: _cargoDescriptionController.text.trim().isNotEmpty
          ? _cargoDescriptionController.text.trim()
          : null,
      cargoWeightKg: weight,
      cargoVolumeM3: volume,
      pricingMode: _pricingMode,
      priceAmount: _pricingMode == 'FIXED' ? price : null,
      priceCurrency: 'UZS',
      stops: stops,
    );

    context.read<LoadsBloc>().add(LoadCreateRequested(payload));
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<LoadsBloc, LoadsState>(
      listener: (context, state) {
        if (state is LoadCreateSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Yuk muvaffaqiyatli yaratildi')),
          );
          context.pop();
        } else if (state is LoadsError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(title: const Text('Yuk yaratish')),
        body: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _sectionTitle('Marshrut'),
              _buildCard([
                _field(
                  _pickupCityController,
                  'Yuklash shahri',
                  Icons.location_on_outlined,
                  required: true,
                ),
                _field(
                  _pickupAddressController,
                  'Yuklash manzili',
                  Icons.home_outlined,
                ),
                const SizedBox(height: 8),
                _field(
                  _deliveryCityController,
                  'Tushirish shahri',
                  Icons.location_on,
                  required: true,
                ),
                _field(
                  _deliveryAddressController,
                  'Tushirish manzili',
                  Icons.home,
                ),
              ]),
              const SizedBox(height: 16),
              _sectionTitle('Yuk ma\'lumotlari'),
              _buildCard([
                _field(
                  _cargoTypeController,
                  'Yuk turi (masalan: Qurilish materiallari)',
                  Icons.category_outlined,
                ),
                _field(
                  _cargoDescriptionController,
                  'Tavsif',
                  Icons.description_outlined,
                ),
                _field(
                  _weightController,
                  'Og\'irlik (kg)',
                  Icons.fitness_center,
                  inputType: TextInputType.number,
                  formatters: [FilteringTextInputFormatter.digitsOnly],
                ),
                _field(
                  _volumeController,
                  'Hajm (m³)',
                  Icons.straighten,
                  inputType: TextInputType.number,
                  formatters: [FilteringTextInputFormatter.digitsOnly],
                ),
              ]),
              const SizedBox(height: 16),
              _sectionTitle('Narx'),
              _buildCard([
                RadioGroup<String>(
                  groupValue: _pricingMode,
                  onChanged: (v) => setState(() => _pricingMode = v!),
                  child: const Row(
                    children: [
                      Expanded(
                        child: RadioListTile<String>(
                          title: Text('Belgilangan', style: TextStyle(fontSize: 14)),
                          value: 'FIXED',
                          contentPadding: EdgeInsets.zero,
                          dense: true,
                        ),
                      ),
                      Expanded(
                        child: RadioListTile<String>(
                          title: Text('Taklif', style: TextStyle(fontSize: 14)),
                          value: 'OFFERS',
                          contentPadding: EdgeInsets.zero,
                          dense: true,
                        ),
                      ),
                    ],
                  ),
                ),
                if (_pricingMode == 'FIXED')
                  _field(
                    _priceController,
                    'Narx (UZS)',
                    Icons.payments_outlined,
                    inputType: TextInputType.number,
                    formatters: [FilteringTextInputFormatter.digitsOnly],
                    required: true,
                  ),
              ]),
              const SizedBox(height: 24),
              BlocBuilder<LoadsBloc, LoadsState>(
                builder: (context, state) {
                  final isLoading = state is LoadsLoading;
                  return ElevatedButton(
                    onPressed: isLoading ? null : _submit,
                    child: isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text('Yaratish'),
                  );
                },
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
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

  Widget _field(
    TextEditingController controller,
    String label,
    IconData icon, {
    TextInputType inputType = TextInputType.text,
    List<TextInputFormatter>? formatters,
    bool required = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        keyboardType: inputType,
        inputFormatters: formatters,
        validator: required
            ? (v) => v == null || v.trim().isEmpty ? 'Majburiy maydon' : null
            : null,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, size: 20),
        ),
      ),
    );
  }
}
