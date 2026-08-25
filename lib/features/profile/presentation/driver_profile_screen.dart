import 'package:flutter/material.dart';
import '../../../core/di/service_locator.dart';
import '../../../core/theme/app_colors.dart';
import '../data/models/user_models.dart';

class DriverProfileScreen extends StatefulWidget {
  const DriverProfileScreen({super.key});

  @override
  State<DriverProfileScreen> createState() => _DriverProfileScreenState();
}

class _DriverProfileScreenState extends State<DriverProfileScreen> {
  DriverEligibilityResponse? _eligibility;
  bool _isLoading = true;
  bool _isCreating = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _checkEligibility();
  }

  Future<void> _checkEligibility() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final eligibility = await sl.userRepository.getDriverEligibility();
      setState(() {
        _eligibility = eligibility;
        _isLoading = false;
      });
    } catch (_) {
      setState(() {
        _error = 'Ma\'lumotlarni yuklashda xatolik';
        _isLoading = false;
      });
    }
  }

  Future<void> _createDriverProfile() async {
    setState(() => _isCreating = true);
    try {
      await sl.userRepository.createDriverProfile();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Haydovchi profili muvaffaqiyatli yaratildi')),
        );
        _checkEligibility();
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Haydovchi profili yaratishda xatolik')),
        );
      }
    } finally {
      if (mounted) setState(() => _isCreating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Haydovchi profili')),
      body: _buildBody(),
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
            TextButton(
                onPressed: _checkEligibility,
                child: const Text('Qayta urinish')),
          ],
        ),
      );
    }

    final e = _eligibility!;

    if (e.hasDriverProfile) {
      return _buildExistingProfile(e);
    }

    return _buildCreateProfile(e);
  }

  Widget _buildExistingProfile(DriverEligibilityResponse e) {
    final verificationLabel = switch (e.verificationStatus) {
      'VERIFIED' => 'Tasdiqlangan',
      'PENDING' => 'Tekshirilmoqda',
      'REJECTED' => 'Rad etilgan',
      _ => e.verificationStatus ?? 'Noma\'lum',
    };
    final verificationColor = switch (e.verificationStatus) {
      'VERIFIED' => AppColors.success,
      'PENDING' => AppColors.warning,
      'REJECTED' => AppColors.error,
      _ => AppColors.textSecondary,
    };

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.divider, width: 0.5),
          ),
          child: Column(
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: AppColors.primarySurface,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: const Icon(Icons.badge_outlined,
                    size: 36, color: AppColors.primary),
              ),
              const SizedBox(height: 16),
              const Text(
                'Haydovchi profili',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: verificationColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  verificationLabel,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: verificationColor,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Container(
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
                'Imkoniyatlar',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 12),
              _capabilityRow(
                Icons.local_shipping,
                'Yuk tashish',
                e.eligible,
              ),
              _capabilityRow(
                Icons.handshake_outlined,
                'Taklif berish',
                e.eligible,
              ),
              _capabilityRow(
                Icons.map_outlined,
                'Marshrut rejasi',
                e.hasDriverProfile,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCreateProfile(DriverEligibilityResponse e) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.primarySurface,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(Icons.badge_outlined,
                  size: 40, color: AppColors.primary),
            ),
            const SizedBox(height: 24),
            const Text(
              'Haydovchi sifatida ro\'yxatdan o\'ting',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            const Text(
              'Haydovchi profilini yaratib, yuk tashish buyurtmalarini qabul qilishni boshlang',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 32),
            _featureItem(Icons.check_circle, 'Yuk buyurtmalariga taklif bering'),
            const SizedBox(height: 12),
            _featureItem(Icons.check_circle, 'Yetkazish jarayonini boshqaring'),
            const SizedBox(height: 12),
            _featureItem(Icons.check_circle, 'Mijozlar bilan bog\'laning'),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _isCreating ? null : _createDriverProfile,
              child: _isCreating
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white),
                    )
                  : const Text('Haydovchi profilini yaratish'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _featureItem(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 20, color: AppColors.primary),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(fontSize: 15, color: AppColors.textPrimary),
          ),
        ),
      ],
    );
  }

  Widget _capabilityRow(IconData icon, String label, bool enabled) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 20,
              color: enabled ? AppColors.primary : AppColors.textMuted),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: enabled ? AppColors.textPrimary : AppColors.textMuted,
              ),
            ),
          ),
          Icon(
            enabled ? Icons.check_circle : Icons.radio_button_unchecked,
            size: 20,
            color: enabled ? AppColors.success : AppColors.textMuted,
          ),
        ],
      ),
    );
  }
}
