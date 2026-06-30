import 'package:shared_preferences/shared_preferences.dart';

/// Lightweight helper for checking the current user's role/auth state.
/// Reads from SharedPreferences, where 'user_role' (or similar) is expected
/// to be persisted at sign-in/sign-up time.
class AuthHelper {
  /// Returns true if the currently signed-in user is an admin.
  /// Defaults to false (and never throws) if no role info is present.
  Future<bool> isAdmin() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final role = prefs.getString('user_role');
      if (role != null) {
        return role.toLowerCase() == 'admin';
      }

      // Fallback: some flows store a boolean flag instead of a role string.
      final isAdminFlag = prefs.getBool('is_admin');
      return isAdminFlag ?? false;
    } catch (_) {
      return false;
    }
  }

  /// Returns true if a user is currently signed in (an auth token is stored).
  Future<bool> isLoggedIn() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      return token != null && token.isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  /// Returns the stored auth token, or null if not signed in.
  Future<String?> getToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString('auth_token');
    } catch (_) {
      return null;
    }
  }

  /// Returns the stored user id, or null if not signed in.
  Future<String?> getUserId() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString('user_id');
    } catch (_) {
      return null;
    }
  }
}

/// Global instance used throughout the app, e.g. `authHelper.isAdmin()`.
final AuthHelper authHelper = AuthHelper();
