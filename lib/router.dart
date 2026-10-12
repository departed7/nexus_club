import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'models/role.dart';
import 'state/auth_notifier.dart';
import 'screens/dashboard_screen.dart';
import 'screens/computers_screen.dart';
import 'screens/zones_screen.dart';
import 'screens/members_screen.dart';
import 'screens/computer_form_screen.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/forbidden_screen.dart';
import 'screens/admin_users_screen.dart';

final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>();

GoRouter buildRouter(AuthNotifier auth) {
  return GoRouter(
    navigatorKey: rootNavigatorKey,
    refreshListenable: auth,
    initialLocation: '/dashboard',
    redirect: (context, state) {
      if (!auth.isInitialized) return null;

      final loggedIn = auth.isAuthenticated;
      final target = state.matchedLocation;
      final isPublic = target == '/login' || target == '/register';

      if (!loggedIn && !isPublic) {
        return '/login?from=${Uri.encodeComponent(state.uri.toString())}';
      }

      if (loggedIn && isPublic) {
        return '/dashboard';
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => LoginScreen(from: state.uri.queryParameters['from']),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: '/forbidden',
        builder: (context, state) => const ForbiddenScreen(),
      ),
      GoRoute(
        path: '/dashboard',
        builder: (context, state) => const DashboardScreen(),
      ),
      GoRoute(
        path: '/',
        redirect: (_, __) => '/dashboard',
      ),
      GoRoute(
        path: '/computers',
        builder: (context, state) => ComputersScreen(queryParams: state.uri.queryParameters),
        routes: [
          GoRoute(
            path: 'new',
            builder: (context, state) => const ComputerFormScreen(),
            redirect: (context, state) => auth.has(Role.operator) ? null : '/forbidden',
          ),
          GoRoute(
            path: ':id/edit',
            builder: (context, state) => ComputerFormScreen(
              id: int.tryParse(state.pathParameters['id'] ?? ''),
            ),
            redirect: (context, state) => auth.has(Role.operator) ? null : '/forbidden',
          ),
        ],
      ),
      GoRoute(
        path: '/zones',
        builder: (context, state) => ZonesScreen(queryParams: state.uri.queryParameters),
      ),
      GoRoute(
        path: '/members',
        builder: (context, state) => const MembersScreen(),
      ),
      GoRoute(
        path: '/admin/users',
        builder: (context, state) => const AdminUsersScreen(),
        redirect: (context, state) => auth.has(Role.admin) ? null : '/forbidden',
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      backgroundColor: const Color(0xFF0A0D14),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('404 - Страница не найдена', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
            const SizedBox(height: 16),
            FilledButton(onPressed: () => context.go('/dashboard'), child: const Text('На главную')),
          ],
        ),
      ),
    ),
  );
}