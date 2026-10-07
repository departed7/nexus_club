import 'package:flutter/material.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:provider/provider.dart';
import 'repositories/computer_repository.dart';
import 'repositories/in_memory_computer_repository.dart';
import 'repositories/zone_repository.dart';
import 'repositories/in_memory_zone_repository.dart';
import 'state/computer_list_notifier.dart';
import 'state/zone_list_notifier.dart';
import 'router.dart';

void main() {
  usePathUrlStrategy();

  final computerRepo = InMemoryComputerRepository();
  final zoneRepo = InMemoryZoneRepository();

  runApp(
    MultiProvider(
      providers: [
        Provider<ComputerRepository>.value(value: computerRepo),
        Provider<ZoneRepository>.value(value: zoneRepo),
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
      title: 'Nexus Club Manager',
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.dark,
      darkTheme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0F1117), // Deep Slate
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF38BDF8), // Мягкий Sky Blue
          surface: Color(0xFF161922),
          surfaceContainerHighest: Color(0xFF1E2230),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF161922),
          elevation: 0,
          scrolledUnderElevation: 0,
          shape: Border(bottom: BorderSide(color: Color(0xFF232838))),
        ),
        cardTheme: CardThemeData(
          color: const Color(0xFF161922),
          elevation: 0,
          shape: RoundedRectangleBorder(
            side: const BorderSide(color: Color(0xFF232838)),
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color(0xFF10121A),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Color(0xFF282E40)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Color(0xFF282E40)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Color(0xFF38BDF8), width: 1.5),
          ),
        ),
      ),
      routerConfig: appRouter,
    );
  }
}