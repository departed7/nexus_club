import 'dart:convert';
import 'package:dio/dio.dart';

sealed class ApiException implements Exception {
  final String message;
  const ApiException(this.message);

  @override
  String toString() => message;
}

class RequestCanceledException extends ApiException {
  const RequestCanceledException([super.message = 'Запрос отменён новым запросом.']);
}

class NetworkException extends ApiException {
  const NetworkException([super.message = 'Сервер недоступен. Проверьте соединение или наличие ошибки CORS.']);
}

class UnauthorizedException extends ApiException {
  const UnauthorizedException([super.message = 'Требуется вход в систему.']);
}

class ForbiddenException extends ApiException {
  const ForbiddenException([super.message = 'Недостаточно прав для этого действия.']);
}

class NotFoundException extends ApiException {
  const NotFoundException([super.message = 'Запись не найдена на сервере.']);
}

class ConflictException extends ApiException {
  const ConflictException([super.message = 'Операция невозможна из-за конфликта данных.']);
}

class ValidationException extends ApiException {
  final Map<String, String> errors;
  const ValidationException(super.message, this.errors);
}

class ServerException extends ApiException {
  const ServerException([super.message = 'Ошибка на стороне сервера (5xx).']);
}

ApiException mapDioError(DioException e) {
  if (e.type == DioExceptionType.cancel) {
    return const RequestCanceledException();
  }

  final existing = e.error;
  if (existing is ApiException) return existing;

  // Если в ошибке есть HTTP-ответ с кодом
  if (e.response != null && e.response!.statusCode != null) {
    return mapHttpError(e.response!.statusCode!, e.response!.data);
  }

  return switch (e.type) {
    DioExceptionType.connectionTimeout ||
    DioExceptionType.sendTimeout ||
    DioExceptionType.receiveTimeout =>
      const NetworkException('Сервер не ответил вовремя (Таймаут).'),
    DioExceptionType.connectionError =>
      const NetworkException('Не удалось соединиться с сервером. Проверьте, запущен ли mock-server.'),
    _ => const ServerException(),
  };
}

ApiException mapHttpError(int status, dynamic rawBody) {
  dynamic body = rawBody;
  if (body is String) {
    try {
      body = jsonDecode(body);
    } catch (_) {}
  }

  final message = (body is Map && body['message'] is String) ? body['message'] as String : null;

  return switch (status) {
    401 => UnauthorizedException(message ?? 'Требуется вход в систему.'),
    403 => ForbiddenException(message ?? 'Недостаточно прав.'),
    404 => NotFoundException(message ?? 'Запись не найдена.'),
    409 => ConflictException(message ?? 'Конфликт связанных данных.'),
    422 => ValidationException(
        message ?? 'Ошибка валидации',
        (body is Map && body['errors'] is Map)
            ? (body['errors'] as Map).map((k, v) => MapEntry('$k', '$v'))
            : const {},
      ),
    _ => ServerException(message ?? 'Ошибка сервера (код $status).'),
  };
}

Future<T> guard<T>(Future<T> Function() action) async {
  try {
    return await action();
  } on DioException catch (e) {
    throw mapDioError(e);
  }
}