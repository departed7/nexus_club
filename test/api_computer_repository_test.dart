import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nexus_club/core/api_client.dart';
import 'package:nexus_club/core/api_exceptions.dart';
import 'package:nexus_club/models/computer.dart';
import 'package:nexus_club/models/computer_query.dart';
import 'package:nexus_club/repositories/api_computer_repository.dart';

class MockAdapter implements HttpClientAdapter {
  ResponseBody Function(RequestOptions options)? handler;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    if (handler != null) return handler!(options);
    return ResponseBody.fromString('{}', 200);
  }

  @override
  void close({bool force = false}) {}
}

void main() {
  late Dio dio;
  late MockAdapter adapter;
  late ApiComputerRepository repository;

  setUp(() {
    dio = buildDio();
    adapter = MockAdapter();
    dio.httpClientAdapter = adapter;
    repository = ApiComputerRepository(dio);
  });

  group('Тестирование ApiComputerRepository (Критерий 17)', () {
    test('1. Успешная загрузка списка и разбор JSON', () async {
      adapter.handler = (opt) => ResponseBody.fromString(
        '{"items": [{"id": 1, "name": "PC-1", "gpu": "RTX 4060", "cpu": "i5", "ramGb": 16, "zoneId": 1, "hourlyRate": 150, "isVip": false, "ipAddress": "192.168.1.1"}], "total": 1, "page": 1, "size": 10}',
        200,
        headers: {'content-type': ['application/json; charset=utf-8']},
      );

      final res = await repository.find(const ComputerQuery());
      expect(res.items.length, 1);
      expect(res.items.first.name, 'PC-1');
    });

    test('2. Разбор ошибки 422 (ValidationException)', () async {
      adapter.handler = (opt) => ResponseBody.fromString(
        '{"message": "Ошибка", "errors": {"ipAddress": "Дубликат IP"}}',
        422,
        headers: {'content-type': ['application/json; charset=utf-8']},
      );

      const comp = Computer(
        id: 0,
        name: 'Test',
        gpu: 'RTX',
        cpu: 'i5',
        ramGb: 16,
        zoneId: 1,
        hourlyRate: 100,
        isVip: false,
        ipAddress: '192.168.1.1',
      );

      expect(
        () async => await repository.create(comp),
        throwsA(isA<ValidationException>()),
      );
    });

    test('3. Разбор ошибки 409 (ConflictException)', () async {
      adapter.handler = (opt) => ResponseBody.fromString(
        '{"message": "Конфликт связей"}',
        409,
        headers: {'content-type': ['application/json; charset=utf-8']},
      );

      expect(
        () async => await repository.hardDelete(1),
        throwsA(isA<ConflictException>()),
      );
    });

    test('4. Обработка недоступности сервера (NetworkException)', () async {
      adapter.handler = (opt) => throw DioException(
        requestOptions: opt,
        type: DioExceptionType.connectionError,
      );

      expect(
        () async => await repository.find(const ComputerQuery()),
        throwsA(isA<NetworkException>()),
      );
    });

    test('5. Обработка ошибки сервера 500 (ServerException)', () async {
      adapter.handler = (opt) => ResponseBody.fromString(
        '{"message": "Internal Error"}',
        500,
        headers: {'content-type': ['application/json; charset=utf-8']},
      );

      expect(
        () async => await repository.find(const ComputerQuery()),
        throwsA(isA<ServerException>()),
      );
    });
  });
}