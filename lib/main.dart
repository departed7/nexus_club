import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:provider/provider.dart';
import 'core/api_client.dart';
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
import 'state/computer_list_notifier.dart';
import 'state/zone_list_notifier.dart';
import 'router.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  usePathUrlStrategy();

  final dio = buildDio();
  final computerRepo = ApiComputerRepository(dio);
  final zoneRepo = ApiZoneRepository(dio);
  final gameRepo = InMemoryGameRepository();
  final tariffRepo = InMemoryTariffRepository();
  final memberRepo = InMemoryMemberRepository();

  runApp(
    MultiProvider(
      providers: [
        Provider<Dio>.value(value: dio),
        Provider<ComputerRepository>.value(value: computerRepo),
        Provider<ZoneRepository>.value(value: zoneRepo),
        Provider<GameRepository>.value(value: gameRepo),
        Provider<TariffRepository>.value(value: tariffRepo),
        Provider<MemberRepository>.value(value: memberRepo),
        ChangeNotifierProvider(create: (_) => ComputerListNotifier(computerRepo)),
        ChangeNotifierProvider(create: (_) => ZoneListNotifier(zoneRepo)..load()),
      ],
      child: const NexusApp(),
    ),
  );
}

class NexusApp extends StatelessWidget {
  const NexusApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
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
          scrolledUnderElevation: 0,
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
      routerConfig: appRouter,
    );
  }
}