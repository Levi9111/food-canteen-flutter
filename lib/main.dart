import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/constants/app_constants.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_provider.dart';
import 'features/auth/presentation/login_screen.dart';
import 'features/auth/providers/session_provider.dart';
import 'features/recruits_canteen/presentation/canteen_main_screen.dart';
import 'features/splash/presentation/splash_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    const ProviderScope(
      child: RtsFoodCanteenApp(),
    ),
  );
}

class RtsFoodCanteenApp extends ConsumerWidget {
  final Widget? home;
  const RtsFoodCanteenApp({super.key, this.home});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);

    return MaterialApp(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      home: home ?? const AppGate(),
    );
  }
}

class AppGate extends ConsumerStatefulWidget {
  const AppGate({super.key});

  @override
  ConsumerState<AppGate> createState() => _AppGateState();
}

class _AppGateState extends ConsumerState<AppGate> {
  bool _showingSplash = true;

  @override
  Widget build(BuildContext context) {
    if (_showingSplash) {
      return SplashScreen(
        onComplete: () {
          setState(() {
            _showingSplash = false;
          });
        },
      );
    }

    final sessionState = ref.watch(sessionProvider);

    if (sessionState.isLoading) {
      return const Scaffold(
        backgroundColor: Color(0xFF0B132B),
        body: Center(
          child: CircularProgressIndicator(color: Color(0xFFD4AF37)),
        ),
      );
    }

    if (sessionState.isAuthenticated) {
      return const CanteenMainScreen();
    }

    return const LoginScreen();
  }
}
