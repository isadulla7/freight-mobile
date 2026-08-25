/// ihamkor.uz reyestridan olingan kompaniya ma'lumoti.
class CompanyLookupResult {
  final String tin;
  final String name;
  final String? address;

  /// Masalan `active` — reyestrdagi holat kodi.
  final String? state;

  /// Holatning o'qiladigan nomi (masalan "Активный").
  final String? stateTitle;

  final String? registrationDate;

  const CompanyLookupResult({
    required this.tin,
    required this.name,
    this.address,
    this.state,
    this.stateTitle,
    this.registrationDate,
  });

  bool get isActive => state?.toLowerCase() == 'active';

  factory CompanyLookupResult.fromJson(Map<String, dynamic> json) {
    // Reyestr nomni ikki maydonda qaytaradi; `name` bo'sh bo'lishi mumkin.
    final rawName = (json['name'] ?? json['company_name_company']) as String?;

    return CompanyLookupResult(
      tin: (json['tin'] ?? '').toString(),
      name: _clean(rawName) ?? '',
      address: _clean(json['address'] as String?),
      state: json['state'] as String?,
      stateTitle: json['statetitle'] as String?,
      registrationDate: json['registrationdate'] as String?,
    );
  }

  /// Reyestr nomlarni qo'shtirnoq bilan qaytaradi: `"NOMI" MCHJ`.
  static String? _clean(String? value) {
    final trimmed = value?.trim();
    if (trimmed == null || trimmed.isEmpty) return null;
    return trimmed.replaceAll('"', '').replaceAll(RegExp(r'\s+'), ' ');
  }
}
