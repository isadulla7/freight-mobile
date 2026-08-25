import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../../../core/di/service_locator.dart';
import '../../../core/theme/app_colors.dart';
import '../data/company_lookup_repository.dart';
import '../data/models/company_lookup_models.dart';
import '../data/models/company_models.dart';

class CreateCompanyScreen extends StatefulWidget {
  const CreateCompanyScreen({super.key});

  @override
  State<CreateCompanyScreen> createState() => _CreateCompanyScreenState();
}

class _CreateCompanyScreenState extends State<CreateCompanyScreen> {
  static const _tinLength = 9;

  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _innController = TextEditingController();

  bool _isSubmitting = false;
  bool _isLookingUp = false;
  CompanyLookupResult? _lookup;
  String? _lookupMessage;
  Timer? _lookupDebounce;

  @override
  void initState() {
    super.initState();
    _innController.addListener(_onInnChanged);
  }

  @override
  void dispose() {
    _lookupDebounce?.cancel();
    _innController.removeListener(_onInnChanged);
    _nameController.dispose();
    _innController.dispose();
    super.dispose();
  }

  /// INN to'liq kiritilishi bilan reyestrdan qidiramiz. Har bir belgida
  /// so'rov yubormaslik uchun kechiktiramiz.
  void _onInnChanged() {
    _lookupDebounce?.cancel();

    final tin = _innController.text.trim();
    if (tin.length < _tinLength) {
      if (_lookup != null || _lookupMessage != null) {
        setState(() {
          _lookup = null;
          _lookupMessage = null;
        });
      }
      return;
    }

    _lookupDebounce = Timer(
      const Duration(milliseconds: 400),
      () => _lookupCompany(tin),
    );
  }

  Future<void> _lookupCompany(String tin) async {
    setState(() {
      _isLookingUp = true;
      _lookupMessage = null;
    });

    try {
      final result = await sl.companyLookupRepository.findByTin(tin);
      if (!mounted) return;

      setState(() {
        _lookup = result;
        _isLookingUp = false;
        // Foydalanuvchi nomni qo'lda yozgan bo'lsa ustidan yozmaymiz.
        if (_nameController.text.trim().isEmpty && result.name.isNotEmpty) {
          _nameController.text = result.name;
        }
      });
    } on CompanyLookupException catch (e) {
      if (!mounted) return;
      setState(() {
        _lookup = null;
        _isLookingUp = false;
        _lookupMessage = switch (e.kind) {
          CompanyLookupError.notFound => 'Bu INN reyestrda topilmadi',
          CompanyLookupError.network => 'Reyestrga ulanib bo\'lmadi',
          CompanyLookupError.unavailable => 'Reyestr xizmati javob bermadi',
        };
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _lookup = null;
        _isLookingUp = false;
        _lookupMessage = 'Reyestr xizmati javob bermadi';
      });
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);
    try {
      final inn = _innController.text.trim();
      await sl.companyRepository.createCompany(CreateCompanyPayload(
        legalName: _nameController.text.trim(),
        businessIdentifier: inn.isNotEmpty ? inn : null,
      ));
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Kompaniya muvaffaqiyatli yaratildi')),
        );
        context.pop(true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Kompaniya yaratishda xatolik')),
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
      appBar: AppBar(title: const Text('Kompaniya yaratish')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildCard([
              TextFormField(
                controller: _innController,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(_tinLength),
                ],
                decoration: InputDecoration(
                  labelText: 'INN (ixtiyoriy)',
                  hintText: '123456789',
                  helperText: 'INN kiritilsa ma\'lumotlar avtomatik to\'ladi',
                  prefixIcon: const Icon(Icons.numbers),
                  suffixIcon: _isLookingUp
                      ? const Padding(
                          padding: EdgeInsets.all(12),
                          child: SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        )
                      : _lookup != null
                          ? const Icon(Icons.check_circle,
                              color: AppColors.primary)
                          : null,
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _nameController,
                validator: (v) =>
                    v == null || v.trim().isEmpty ? 'Majburiy maydon' : null,
                decoration: const InputDecoration(
                  labelText: 'Kompaniya nomi',
                  prefixIcon: Icon(Icons.business),
                ),
              ),
            ]),
            if (_lookupMessage != null) ...[
              const SizedBox(height: 12),
              _buildNotice(_lookupMessage!),
            ],
            if (_lookup != null) ...[
              const SizedBox(height: 12),
              _buildLookupCard(_lookup!),
            ],
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
                  : const Text('Yaratish'),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildNotice(String message) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.divider, width: 0.5),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline, size: 18, color: AppColors.textMuted),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLookupCard(CompanyLookupResult result) {
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
            children: [
              const Text(
                'Reyestr ma\'lumoti',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
              ),
              const Spacer(),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: result.isActive
                      ? AppColors.badgeGreen
                      : AppColors.primarySurface,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  result.isActive
                      ? 'Faol'
                      : (result.stateTitle ?? result.state ?? 'Noma\'lum'),
                  style: TextStyle(
                    fontSize: 12,
                    color: result.isActive
                        ? AppColors.badgeGreenText
                        : AppColors.textSecondary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          _row(Icons.business, result.name),
          if (result.address != null) ...[
            const SizedBox(height: 8),
            _row(Icons.location_on_outlined, result.address!),
          ],
          if (result.registrationDate != null) ...[
            const SizedBox(height: 8),
            _row(
              Icons.event_outlined,
              'Ro\'yxatdan o\'tgan: ${_formatDate(result.registrationDate!)}',
            ),
          ],
          if (!result.isActive) ...[
            const SizedBox(height: 10),
            const Text(
              'Diqqat: reyestrda kompaniya faol emas.',
              style: TextStyle(fontSize: 12, color: AppColors.error),
            ),
          ],
        ],
      ),
    );
  }

  Widget _row(IconData icon, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: AppColors.textMuted),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textPrimary,
            ),
          ),
        ),
      ],
    );
  }

  /// `2021-04-24T00:00:00.000Z` → `24.04.2021`
  String _formatDate(String raw) {
    final parsed = DateTime.tryParse(raw);
    if (parsed == null) return raw;
    final d = parsed.day.toString().padLeft(2, '0');
    final m = parsed.month.toString().padLeft(2, '0');
    return '$d.$m.${parsed.year}';
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
