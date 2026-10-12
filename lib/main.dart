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
        if (error.response?.statusCode == 401 && !error.requestOptions.path.contains('/auth/')) {
          final refreshed = await authNotifier.refreshTokens();
          if (refreshed) {
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

  await authNotifier.restore();

  final computerRepo = ApiComputerRepository(dio);
  final zoneRepo = ApiZoneRepository(dio);
  final gameRepo = InMemoryGameRepository();
  final tariffRepo = InMemoryTariffRepository();
  final memberRepo = InMemoryMemberRepository(prefs);

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
      onTimeout: () => authNotifier.logout(),
      child: MaterialApp.router(
        title: 'Nexus Club OS',
        debugShowCheckedModeBanner: false,
        themeMode: ThemeMode.dark,
        darkTheme: ThemeData(
          useMaterial3: true,
          brightness: Brightness.dark,
          scaffoldBackgroundColor: const Color(0xFF080C16),
          colorScheme: const ColorScheme.dark(
            primary: Color(0xFFFF5500),
            secondary: Color(0xFF38BDF8),
            surface: Color(0xFF0F1527),
            surfaceContainerHighest: Color(0xFF161F36),
          ),
          appBarTheme: const AppBarTheme(
            backgroundColor: Color(0xFF0D1222),
            elevation: 0,
            shape: Border(bottom: BorderSide(color: Color(0xFF1E2842))),
          ),
          cardTheme: CardThemeData(
            color: const Color(0xFF0F1527),
            elevation: 0,
            shape: RoundedRectangleBorder(
              side: const BorderSide(color: Color(0xFF1E2842)),
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          inputDecorationTheme: InputDecorationTheme(
            filled: true,
            fillColor: const Color(0xFF080C16),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Color(0xFF1E2842)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Color(0xFF1E2842)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Color(0xFFFF5500), width: 1.8),
            ),
          ),
        ),
        routerConfig: buildRouter(authNotifier),
      ),
    );
  }
}