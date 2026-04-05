import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseAuthRepository extends ChangeNotifier {
  late final Stream<AuthState> _authStream;

  SupabaseAuthRepository() {
    _authStream = Supabase.instance.client.auth.onAuthStateChange;

    // Listen to changes and notify any listeners (like GoRouter)
    _authStream.listen((data) {
      notifyListeners();
    });
  }

  // Helper to check current session status anywhere in the app
  Session? get currentSession => Supabase.instance.client.auth.currentSession;

  bool get isAuthenticated => currentSession != null;
}

// Create a single instance to be used by the Router
final authRepository = SupabaseAuthRepository();
