import 'package:dio/dio.dart';

class ApiException implements Exception {
  final String code;
  final String message;
  final String? traceId;
  final int? statusCode;

  const ApiException({
    required this.code,
    required this.message,
    this.traceId,
    this.statusCode,
  });

  factory ApiException.fromDioException(DioException e) {
    final data = e.response?.data;
    if (data is Map<String, dynamic> && data.containsKey('error')) {
      final error = data['error'] as Map<String, dynamic>;
      return ApiException(
        code: error['code'] as String? ?? 'UNKNOWN',
        message: error['message'] as String? ?? 'Xatolik yuz berdi',
        traceId: error['traceId'] as String?,
        statusCode: e.response?.statusCode,
      );
    }
    return ApiException(
      code: 'NETWORK_ERROR',
      message: _messageForType(e.type),
      statusCode: e.response?.statusCode,
    );
  }

  static String _messageForType(DioExceptionType type) {
    return switch (type) {
      DioExceptionType.connectionTimeout => 'Serverga ulanib bo\'lmadi',
      DioExceptionType.receiveTimeout => 'Javob kutish vaqti tugadi',
      DioExceptionType.connectionError => 'Internet aloqasi yo\'q',
      _ => 'Xatolik yuz berdi',
    };
  }

  bool get isUnauthorized => statusCode == 401;
  bool get isForbidden => statusCode == 403;
  bool get isNotFound => statusCode == 404;
  bool get isConflict => statusCode == 409;

  @override
  String toString() => 'ApiException($code): $message';
}
