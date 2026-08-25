import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/di/service_locator.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/status_badge.dart';
import '../data/models/company_models.dart';

class CompaniesScreen extends StatefulWidget {
  const CompaniesScreen({super.key});

  @override
  State<CompaniesScreen> createState() => _CompaniesScreenState();
}

class _CompaniesScreenState extends State<CompaniesScreen> {
  CompanyResponse? _company;
  bool _isLoading = true;
  bool _hasCompany = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _isLoading = true);
    try {
      final companies = await sl.companyRepository.getMyCompanies();
      if (companies.isNotEmpty) {
        setState(() {
          _company = companies.first;
          _hasCompany = true;
          _isLoading = false;
        });
      } else {
        setState(() {
          _hasCompany = false;
          _isLoading = false;
        });
      }
    } catch (_) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Kompaniya')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _hasCompany
              ? _buildCompanyView()
              : _buildCreateView(),
    );
  }

  Widget _buildCreateView() {
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
              child: const Icon(Icons.business,
                  size: 40, color: AppColors.primary),
            ),
            const SizedBox(height: 24),
            const Text(
              'Kompaniyangiz yo\'q',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Yuk tashish biznesingizni boshqarish uchun kompaniya yarating',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () async {
                final created = await context.push<bool>('/companies/create');
                if (created == true && mounted) {
                  _load();
                }
              },
              icon: const Icon(Icons.add),
              label: const Text('Kompaniya yaratish'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCompanyView() {
    if (_company == null) {
      return const Center(child: CircularProgressIndicator());
    }
    final c = _company!;
    final badgeType = switch (c.status) {
      'ACTIVE' => BadgeType.published,
      'SUSPENDED' => BadgeType.cancelled,
      _ => BadgeType.draft,
    };

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.divider, width: 0.5),
          ),
          child: Column(
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: AppColors.primarySurface,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(Icons.business,
                    size: 32, color: AppColors.primary),
              ),
              const SizedBox(height: 12),
              Text(
                c.name,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              StatusBadge(label: c.statusLabel, type: badgeType),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.divider, width: 0.5),
          ),
          child: Column(
            children: [
              if (c.businessIdentifier != null)
                _detailRow(Icons.numbers, 'INN', c.businessIdentifier!),
              if (c.displayName != null)
                _detailRow(Icons.label_outlined, 'Ko\'rsatiladigan nom', c.displayName!),
              _detailRow(Icons.calendar_today_outlined, 'Yaratilgan',
                  _formatDate(c.createdAt)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _detailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppColors.textSecondary),
          const SizedBox(width: 12),
          Text(label,
              style: const TextStyle(
                  fontSize: 14, color: AppColors.textSecondary)),
          const Spacer(),
          Flexible(
            child: Text(
              value,
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
    );
  }

  String _formatDate(String isoString) {
    try {
      final dt = DateTime.parse(isoString).toLocal();
      return '${dt.day.toString().padLeft(2, '0')}.${dt.month.toString().padLeft(2, '0')}.${dt.year}';
    } catch (_) {
      return '';
    }
  }
}
