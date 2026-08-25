import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:freight_mobile/features/companies/data/company_lookup_repository.dart';

/// ihamkor.uz `/api/search/quick?q=30842986` javobining haqiqiy nusxasi.
const _realResponse = {
  'data': {
    'company': [
      {
        'liquidationdate': null,
        'isgovernmentagency': null,
        'state': 'active',
        'company_name_company': '"ADOLESCENT LOGISTICS" MCHJ',
        'isinblacklist': null,
        'address': 'город Ташкент, Чиланзарский район, Кутарма МФЙ, 10 мавзеси,',
        'rating': 24,
        '@timestamp': '2026-08-16T02:51:32.504923527Z',
        'tin': '308429867',
        'stateid': 'active',
        '@version': '1',
        'key0': 2881707,
        'name': '"ADOLESCENT LOGISTICS" MCHJ',
        'statetitle': 'Активный',
        'statecode': '0',
        'registrationdate': '2021-04-24T00:00:00.000Z',
      }
    ],
    'product': <dynamic>[],
  },
  'success': true,
  'totalProducts': 0,
  'totalCompanies': 1,
};

/// Berilgan javobni qaytaradigan soxta Dio.
Dio _dioReturning(dynamic body, {int statusCode = 200}) {
  final dio = Dio();
  dio.httpClientAdapter = _StubAdapter(body, statusCode);
  return dio;
}

class _StubAdapter implements HttpClientAdapter {
  final dynamic body;
  final int statusCode;
  _StubAdapter(this.body, this.statusCode);

  @override
  Future<ResponseBody> fetch(RequestOptions options, Stream<Uint8List>? _,
      Future<void>? _) async {
    return ResponseBody.fromString(
      jsonEncode(body),
      statusCode,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

void main() {
  group('CompanyLookupRepository', () {
    test('haqiqiy javobni to\'g\'ri o\'qiydi', () async {
      final repo =
          CompanyLookupRepository(dio: _dioReturning(_realResponse));

      final result = await repo.findByTin('308429867');

      expect(result.tin, '308429867');
      // Qo'shtirnoqlar olib tashlanadi.
      expect(result.name, 'ADOLESCENT LOGISTICS MCHJ');
      expect(result.address,
          'город Ташкент, Чиланзарский район, Кутарма МФЙ, 10 мавзеси,');
      expect(result.state, 'active');
      expect(result.stateTitle, 'Активный');
      expect(result.isActive, isTrue);
      expect(result.registrationDate, '2021-04-24T00:00:00.000Z');
    });

    test('bo\'sh natijada notFound qaytaradi', () async {
      final repo = CompanyLookupRepository(
        dio: _dioReturning({
          'data': {'company': <dynamic>[], 'product': <dynamic>[]},
          'success': true,
          'totalCompanies': 0,
        }),
      );

      expect(
        () => repo.findByTin('123456789'),
        throwsA(isA<CompanyLookupException>().having(
          (e) => e.kind,
          'kind',
          CompanyLookupError.notFound,
        )),
      );
    });

    test('bo\'sh INN uchun so\'rov yubormaydi', () async {
      final repo = CompanyLookupRepository(dio: _dioReturning(_realResponse));

      expect(
        () => repo.findByTin('   '),
        throwsA(isA<CompanyLookupException>().having(
          (e) => e.kind,
          'kind',
          CompanyLookupError.notFound,
        )),
      );
    });

    test('bir nechta natijadan aniq mos kelganini tanlaydi', () async {
      final repo = CompanyLookupRepository(
        dio: _dioReturning({
          'data': {
            'company': [
              {'tin': '111111111', 'name': 'Boshqa kompaniya'},
              {'tin': '308429867', 'name': '"KERAKLI" MCHJ'},
            ],
            'product': <dynamic>[],
          },
          'success': true,
        }),
      );

      final result = await repo.findByTin('308429867');
      expect(result.name, 'KERAKLI MCHJ');
    });

    test('server xatosida unavailable qaytaradi', () async {
      final repo = CompanyLookupRepository(
        dio: _dioReturning({'error': 'boom'}, statusCode: 500),
      );

      expect(
        () => repo.findByTin('308429867'),
        throwsA(isA<CompanyLookupException>().having(
          (e) => e.kind,
          'kind',
          CompanyLookupError.unavailable,
        )),
      );
    });
  });
}
