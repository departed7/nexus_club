import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'config.dart';
import 'api_exceptions.dart';

Dio buildDio({String? Function()? tokenProvider}) {
  final dio = Dio(
    BaseOptions(
      baseUrl: apiBaseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 15),
      headers: {'Content-Type': 'application/json'},
      validateStatus: (status) => status != null && status < 500,
    ),
  );

  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) {
        if (tokenProvider != null) {
          final token = tokenProvider();
          if (token != null) options.headers['Authorization'] = 'Bearer $token';
        }
        if (kDebugMode) {
          debugPrint('--> [HTTP ${options.method}] ${options.uri}');
        }
        return handler.next(options);
      },
      onResponse: (response, handler) {
        final status = response.statusCode ?? 0;
        if (kDebugMode) {
          debugPrint('<-- [HTTP $status] ${response.requestOptions.uri}');
        }
        if (status >= 400) {
          return handler.reject(
            DioException(
              requestOptions: response.requestOptions,
              response: response,
              type: DioExceptionType.badResponse,
              error: mapHttpError(status, response.data),
            ),
            true,
          );
        }
        return handler.next(response);
      },
      onError: (error, handler) async {
        // Автоматический повтор (Retry) до 3 раз только для GET-запросов (Критерий 14)
        final req = error.requestOptions;
        final retryCount = (req.extra['retry_count'] as int?) ?? 0;

        if (req.method == 'GET' && retryCount < 3 && error.type != DioExceptionType.cancel) {
          req.extra['retry_count'] = retryCount + 1;
          await Future.delayed(Duration(milliseconds: 500 * (retryCount + 1)));
          try {
            final response = await dio.fetch(req);
            return handler.resolve(response);
          } catch (_) {}
        }

        return handler.next(error);
      },
    ),
  );

  return dio;
}