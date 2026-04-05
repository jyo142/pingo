import 'package:google_sign_in/google_sign_in.dart';
import 'package:pingo/core/env/env.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<AuthResponse> nativeGoogleSignIn() async {
    final googleSignIn = GoogleSignIn.instance;

    final scopes = ['email', 'profile'];
    await googleSignIn.initialize(
      serverClientId: Env.googleWebClientId,
      clientId: Env.googleIOSClientId,
    );
    final googleUser = await googleSignIn.authenticate();

    /// Authorization is required to obtain the access token with the appropriate scopes for Supabase authentication,
    /// while also granting permission to access user information.
    final authorization =
        await googleUser.authorizationClient.authorizationForScopes(scopes) ??
        await googleUser.authorizationClient.authorizeScopes(scopes);
    final idToken = googleUser.authentication.idToken;
    if (idToken == null) {
      throw AuthException('No ID Token found.');
    }
    return await _supabase.auth.signInWithIdToken(
      provider: OAuthProvider.google,
      idToken: idToken,
      accessToken: authorization.accessToken,
    );
  }

  Future<void> signOut() async {
    // Access via singleton instance
    await GoogleSignIn.instance.signOut();
    await _supabase.auth.signOut();
  }
}
