import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'screens/computers_screen.dart';
import 'screens/zones_screen.dart';

final appRouter = GoRouter(
  initialLocation: '/computers',
  routes: [
    GoRoute(
      path: '/computers',
      builder: (context, state) => ComputersScreen(queryParams: state.uri.queryParameters),
    ),
    GoRoute(
      path: '/zones',
      builder: (context, state) => ZonesScreen(queryParams: state.uri.queryParameters),
    ),
  ],
  errorBuilder: (context, state) => Scaffold(
    body: Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('404 - Страница не найдена', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          FilledButton(onPressed: () => context.go('/computers'), child: const Text('В каталог')),
        ],
      ),
    ),
  ),
);