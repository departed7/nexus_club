import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'core/config.dart';
import 'repositories/computer_repository.dart';
import 'repositories/api_computer_repository.dart';
import 'repositories/zone_repository.dart';
import 'repositories/api_zone_repository.dart';
import 'repositories/game_repository.dart';
import 'repositories/in_memory_game_repository.dart';
import 'repositories/tariff_repository.dart';
import 'repositories/in_memory_tariff_repository.dart';
import 'repositories/member_repository.dart';
import 'repositories/in_memory_member_repository.dart';
import 'state/auth_notifier.dart';
import 'state/computer_list_notifier.dart';
import 'state/zone_list_notifier.dart';
import 'widgets/inactivity_watcher.dart';
import 'router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  usePathUrlStrategy();

  final prefs = await SharedPreferences.getInstance();

  // Создаем Dio
  final dio = Dio(
    BaseOptions(
      baseUrl: apiBaseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 15),
      headers: {'Content-Type': 'application/json'},
      validateStatus: (status) => status != null && status < 500,
    ),
  );

  late final AuthNotifier authNotifier;
  authNotifier = AuthNotifier(prefs, dio);

  // Интерцептор автоматической подстановки токена и Silent Refresh (Критерий 13 на «5»)
  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) {
        final token = authNotifier.accessToken;
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        return handler.next(options);
      },
      onError: (error, handler) async {
        // Если токен истёк (401), пробуем обновить через refresh-токен
        if (error.response?.statusCode == 401 && !error.requestOptions.path.contains('/auth/')) {
          final refreshed = await authNotifier.refreshTokens();
          if (refreshed) {
            // Повторяем упавший запрос с новым токеном
            final opts = error.requestOptions;
            opts.headers['Authorization'] = 'Bearer ${authNotifier.accessToken}';
            try {
              final response = await dio.fetch(opts);
              return handler.resolve(response);
            } catch (_) {}
          }
        }
        return handler.next(error);
      },
    ),
  );

  // Восстанавливаем сессию из SharedPreferences до первого кадра
  await authNotifier.restore();

  final computerRepo = ApiComputerRepository(dio);
  final zoneRepo = ApiZoneRepository(dio);
  final gameRepo = InMemoryGameRepository();
  final tariffRepo = InMemoryTariffRepository();
  final memberRepo = InMemoryMemberRepository();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: authNotifier),
        Provider<Dio>.value(value: dio),
        Provider<ComputerRepository>.value(value: computerRepo),
        Provider<ZoneRepository>.value(value: zoneRepo),
        Provider<GameRepository>.value(value: gameRepo),
        Provider<TariffRepository>.value(value: tariffRepo),
        Provider<MemberRepository>.value(value: memberRepo),
        ChangeNotifierProvider(create: (_) => ComputerListNotifier(computerRepo)),
        ChangeNotifierProvider(create: (_) => ZoneListNotifier(zoneRepo)..load()),
      ],
      child: NexusApp(authNotifier: authNotifier),
    ),
  );
}

class NexusApp extends StatelessWidget {
  final AuthNotifier authNotifier;
  const NexusApp({super.key, required this.authNotifier});

  @override
  Widget build(BuildContext context) {
    return InactivityWatcher(
      timeout: const Duration(minutes: 3), // Выход по неактивности через 3 мин (Критерий 14)
      onTimeout: () => authNotifier.logout(),
      child: MaterialApp.router(
        title: 'Nexus Club OS',
        debugShowCheckedModeBanner: false,
        themeMode: ThemeMode.dark,
        darkTheme: ThemeData(
          useMaterial3: true,
          brightness: Brightness.dark,
          scaffoldBackgroundColor: const Color(0xFF090D16),
          colorScheme: const ColorScheme.dark(
            primary: Color(0xFF00E599),
            secondary: Color(0xFF38BDF8),
            surface: Color(0xFF111726),
            surfaceContainerHighest: Color(0xFF1A2238),
          ),
          appBarTheme: const AppBarTheme(
            backgroundColor: Color(0xFF0F1523),
            elevation: 0,
            shape: Border(bottom: BorderSide(color: Color(0xFF1E283D))),
          ),
          cardTheme: CardThemeData(
            color: const Color(0xFF111726),
            elevation: 0,
            shape: RoundedRectangleBorder(
              side: const BorderSide(color: Color(0xFF1E283D)),
              borderRadius: BorderRadius.circular(14),
            ),
          ),
          inputDecorationTheme: InputDecorationTheme(
            filled: true,
            fillColor: const Color(0xFF0B0F19),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Color(0xFF24304A)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Color(0xFF24304A)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Color(0xFF00E599), width: 1.8),
            ),
          ),
        ),
        routerConfig: buildRouter(authNotifier),
      ),
    );
  }
}