import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pingo/core/auth/supabase_auth_repository.dart';
import 'package:pingo/features/auth/screens/login_screen.dart';
import 'package:pingo/features/events/screens/create_event_screen.dart';
import 'package:pingo/features/home/screens/home_screen.dart';
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
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          // You'll need to uncomment and implement your NavBar here
          return Scaffold(body: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                name: "home",
                path: '/home',
                pageBuilder: (context, state) =>
                    NoTransitionPage(child: HomeScreen()),
              ),
            ],
          ),
          // Add your other branches here...
        ],
      ),
      GoRoute(
        name: "login",
        path: "/unauthenticated",
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        name: "createEvent",
        path: "/createEvent",
        builder: (context, state) => const CreateEventScreen(),
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
