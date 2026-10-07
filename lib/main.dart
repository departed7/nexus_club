import 'package:flutter/material.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'repositories/computer_repository.dart';
import 'repositories/in_memory_computer_repository.dart';
import 'repositories/zone_repository.dart';
import 'repositories/in_memory_zone_repository.dart';
import 'repositories/game_repository.dart';
import 'repositories/in_memory_game_repository.dart';
import 'repositories/tariff_repository.dart';
import 'repositories/in_memory_tariff_repository.dart';
import 'repositories/member_repository.dart';
import 'repositories/in_memory_member_repository.dart';
import 'state/computer_list_notifier.dart';
import 'state/zone_list_notifier.dart';
import 'router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  usePathUrlStrategy();

  final prefs = await SharedPreferences.getInstance();

  final computerRepo = InMemoryComputerRepository(prefs);
  final zoneRepo = InMemoryZoneRepository(prefs);
  final gameRepo = InMemoryGameRepository();
  final tariffRepo = InMemoryTariffRepository();
  final memberRepo = InMemoryMemberRepository(prefs);

  runApp(
    MultiProvider(
      providers: [
        Provider<ComputerRepository>.value(value: computerRepo),
        Provider<ZoneRepository>.value(value: zoneRepo),
        Provider<GameRepository>.value(value: gameRepo),
        Provider<TariffRepository>.value(value: tariffRepo),
        Provider<MemberRepository>.value(value: memberRepo),
        ChangeNotifierProvider(create: (_) => ComputerListNotifier(computerRepo)..load()),
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
        scaffoldBackgroundColor: const Color(0xFF090D16), // Глубокий премиальный индиго-черный
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF00E599), // Яркий неоновый мятный (Electric Mint)
          secondary: Color(0xFF38BDF8), // Яркий лазурный
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
          labelStyle: const TextStyle(color: Color(0xFF94A3B8)),
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
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            backgroundColor: const Color(0xFF00E599),
            foregroundColor: const Color(0xFF090D16),
            textStyle: const TextStyle(fontWeight: FontWeight.bold),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        ),
      ),
      routerConfig: appRouter,
    );
  }
}