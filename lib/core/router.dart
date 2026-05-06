import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pingo/core/auth/supabase_auth_repository.dart';
import 'package:pingo/features/auth/screens/login_screen.dart';
import 'package:pingo/features/events/screens/create_event_screen.dart';
import 'package:pingo/features/events/screens/event_details_screen.dart';
import 'package:pingo/features/home/screens/home_screen.dart';
import 'package:pingo/features/navbar/main_bottom_nav_bar.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();

abstract class AppRouter {
  static final GoRouter pingoConfig = GoRouter(
    navigatorKey: _rootNavigatorKey,

    // 1. Tell GoRouter to re-run the redirect logic when Supabase auth changes
    refreshListenable: authRepository,

    // 2. Set the initial location to '/' or your home path
    initialLocation: '/home',

    routes: [
      /// 🌍 ROOT LEVEL (global overlays)
      GoRoute(
        path: '/unauthenticated',
        builder: (_, __) => const LoginScreen(),
      ),

      GoRoute(
        path: '/createEvent',
        parentNavigatorKey: _rootNavigatorKey, // 👈 important
        builder: (_, __) => const CreateEventScreen(),
      ),

      GoRoute(
        path: '/events/:id',
        parentNavigatorKey: _rootNavigatorKey, // 👈 important
        builder: (_, state) =>
            EventDetailScreen(eventId: state.pathParameters['id']!),
      ),

      /// 📱 SHELL (bottom tabs)
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return Scaffold(
            body: navigationShell,
            bottomNavigationBar: MainBottomNavBar(shell: navigationShell),
          );
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(path: '/home', builder: (_, __) => const HomeScreen()),
            ],
          ),

          StatefulShellBranch(
            routes: [
              GoRoute(path: '/alerts', builder: (_, __) => const HomeScreen()),
            ],
          ),

          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/messages',
                builder: (_, __) => const HomeScreen(),
              ),
            ],
          ),

          StatefulShellBranch(
            routes: [
              GoRoute(path: '/scan', builder: (_, __) => const HomeScreen()),
            ],
          ),
        ],
      ),
    ],
    // 3. Updated Redirect Logic for Supabase
    redirect: (context, state) {
      final session = Supabase.instance.client.auth.currentSession;
      final bool isLoggingIn = state.matchedLocation == '/unauthenticated';

      // If user is not logged in and not on the login page, redirect to login
      if (session == null) {
        return isLoggingIn ? null : '/unauthenticated';
      }

      // If user is logged in but tries to go to the login page, redirect to home
      if (isLoggingIn) {
        return '/home';
      }

      // No redirect needed
      return null;
    },
  );
}
