import 'package:flutter/material.dart';
import 'screens/auth/login_screen.dart';
import 'screens/home/home_screen.dart';
import 'screens/welcome/welcome_screen.dart';
import 'services/auth_service.dart';
import 'services/onboarding_service.dart';
import 'services/theme_service.dart';

class _AppStartupState {
  final bool isLoggedIn;
  final bool hasSeenWelcome;

  const _AppStartupState({
    required this.isLoggedIn,
    required this.hasSeenWelcome,
  });
}

Future<_AppStartupState> _getStartupState() async {
  final isLoggedIn = await AuthService().isLoggedIn();
  final hasSeenWelcome = await OnboardingService.hasSeenWelcome();
  return _AppStartupState(
    isLoggedIn: isLoggedIn,
    hasSeenWelcome: hasSeenWelcome,
  );
}

// Gradient constants
const _primaryGradient = LinearGradient(
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
  colors: [Color(0xFF007AFF), Color(0xFF0A84FF)],
);

const _accentGradient = LinearGradient(
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
  colors: [Color(0xFF007AFF), Color(0xFF5856D6)],
);

const _softShadow = [
  BoxShadow(
    color: Color(0x0D000000),
    blurRadius: 12,
    offset: Offset(0, 4),
  ),
];

const _mediumShadow = [
  BoxShadow(
    color: Color(0x1A000000),
    blurRadius: 20,
    offset: Offset(0, 8),
  ),
];

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await ThemeService.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: ThemeService.mode,
      builder: (context, themeMode, _) {
        return MaterialApp(
          title: 'Aura',
          theme: ThemeData(
            useMaterial3: true,
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xFF007AFF), // iOS Blue
              brightness: Brightness.light,
            ),
            appBarTheme: AppBarTheme(
              backgroundColor: Colors.white,
              foregroundColor: const Color(0xFF1C1C1E),
              elevation: 0,
              surfaceTintColor: Colors.transparent,
              centerTitle: false,
              titleTextStyle: const TextStyle(
                fontSize: 34,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1C1C1E),
              ),
            ),
            cardTheme: CardThemeData(
              color: Colors.white,
              surfaceTintColor: Colors.transparent,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            inputDecorationTheme: InputDecorationTheme(
              filled: true,
              fillColor: const Color(0xFFF2F2F7),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: Color(0xFF007AFF),
                  width: 2,
                ),
              ),
            ),
            elevatedButtonTheme: ElevatedButtonThemeData(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF007AFF),
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 32),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFF007AFF),
              ),
            ),
          ),
          darkTheme: ThemeData(
            useMaterial3: true,
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xFF0A84FF), // Lighter iOS Blue for dark mode
              brightness: Brightness.dark,
            ),
            appBarTheme: AppBarTheme(
              backgroundColor: const Color(0xFF1C1C1E),
              foregroundColor: Colors.white,
              elevation: 0,
              surfaceTintColor: Colors.transparent,
              centerTitle: false,
              titleTextStyle: const TextStyle(
                fontSize: 34,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
            cardTheme: CardThemeData(
              color: const Color(0xFF2C2C2E),
              surfaceTintColor: Colors.transparent,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            inputDecorationTheme: InputDecorationTheme(
              filled: true,
              fillColor: const Color(0xFF3A3A3C),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: Color(0xFF0A84FF),
                  width: 2,
                ),
              ),
            ),
            elevatedButtonTheme: ElevatedButtonThemeData(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0A84FF),
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 32),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFF0A84FF),
              ),
            ),
          ),
          themeMode: themeMode,
          home: FutureBuilder<_AppStartupState>(
            future: _getStartupState(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Scaffold(
                  backgroundColor: Colors.black,
                  body: Center(
                    child: CircularProgressIndicator(
                      color: Color(0xFF007AFF),
                    ),
                  ),
                );
              }

              final state = snapshot.data!;

              // Priority 1: Check if user is logged in
              if (state.isLoggedIn) {
                return const HomeScreen();
              }

              // Priority 2: Show welcome if first time
              if (!state.hasSeenWelcome) {
                return const WelcomeScreen();
              }

              // Default: Show login
              return const LoginScreen();
            },
          ),
        );
      },
    );
  }
}
