import 'package:supabase_flutter/supabase_flutter.dart';

extension SupabaseUserHelpers on User {
  /// Returns the full name from Google metadata, or "User" if not found.
  String get userName => userMetadata?['full_name'] ?? "User";

  /// Returns the first name only (e.g., "John Doe" -> "John").
  String get firstName => userName.split(' ').first;

  /// Returns the Google avatar URL.
  String? get avatarUrl => userMetadata?['avatar_url'];
}
