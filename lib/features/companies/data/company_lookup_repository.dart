import 'package:dio/dio.dart';

import 'models/company_lookup_models.dart';

/// Xatolik turlari — ekran ularga qarab aniq xabar ko'rsatadi.
enum CompanyLookupError { notFound, network, unavailable }

class CompanyLookupException implements Exception {
  final CompanyLookupError kind;
  const CompanyLookupException(this.kind);
}

/// INN bo'yicha kompaniya ma'lumotini ihamkor.uz ochiq reyestridan oladi.
///
/// Bu tashqi xizmat, backend'imizga aloqasi yo'q — shuning uchun alohida
/// Dio nusxasi ishlatiladi (auth interceptorsiz, qisqa timeout bilan).
/// Xizmat ishlamay qolsa kompaniya yaratish oqimi to'xtamasligi kerak:
/// bu faqat maydonlarni avtomatik to'ldirish uchun qulaylik.
class CompanyLookupRepository {
  static const _baseUrl = 'https://ihamkor.uz';

  final Dio _dio;

  CompanyLookupRepository({Dio? dio})
      : _dio = dio ??
            Dio(BaseOptions(
              baseUrl: _baseUrl,
              connectTimeout: const Duration(seconds: 8),
              receiveTimeout: const Duration(seconds: 8),
            ));

  /// INN bo'yicha qidiradi. Topilmasa yoki xizmat javob bermasa
  /// [CompanyLookupException] tashlaydi.
  Future<CompanyLookupResult> findByTin(String tin) async {
    final query = tin.trim();
    if (query.isEmpty) {
      throw const CompanyLookupException(CompanyLookupError.notFound);
    }

    final Response<dynamic> response;
    try {
      response = await _dio.get(
        '/api/search/quick',
        queryParameters: {'q': query},
      );
    } on DioException catch (e) {
      throw CompanyLookupException(
        e.response != null
            ? CompanyLookupError.unavailable
            : CompanyLookupError.network,
      );
    }

    final body = response.data;
    if (body is! Map<String, dynamic>) {
      throw const CompanyLookupException(CompanyLookupError.unavailable);
    }

    final companies = (body['data'] as Map<String, dynamic>?)?['company'];
    if (companies is! List || companies.isEmpty) {
      throw const CompanyLookupException(CompanyLookupError.notFound);
    }

    // Qidiruv "quick" — kiritilgan INN bilan aniq mos keladiganini
    // afzal ko'ramiz, bo'lmasa birinchi natijani olamiz.
    final match = companies.firstWhere(
      (c) => c is Map<String, dynamic> && c['tin']?.toString() == query,
      orElse: () => companies.first,
    );

    if (match is! Map<String, dynamic>) {
      throw const CompanyLookupException(CompanyLookupError.unavailable);
    }

    return CompanyLookupResult.fromJson(match);
  }
}
