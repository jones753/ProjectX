import 'package:shared_preferences/shared_preferences.dart';

class OnboardingService {
  static const _key = 'has_seen_welcome';

  /// Check if user has completed onboarding
  static Future<bool> hasSeenWelcome() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_key) ?? false;
  }

  /// Mark onboarding as completed
  static Future<void> setWelcomeCompleted() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_key, true);
  }

  /// Reset onboarding state (for testing/debug)
  static Future<void> reset() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}
