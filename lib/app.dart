import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'core/l10n/app_texts.dart';
import 'core/momento_controller.dart';
import 'core/theme/momento_theme.dart';
import 'features/auth/welcome_screen.dart';
import 'features/home/home_shell.dart';
import 'features/onboarding/onboarding_screen.dart';

class MomentoApp extends StatelessWidget {
  const MomentoApp({super.key, required this.controller});

  final MomentoController controller;

  @override
  Widget build(BuildContext context) => AppScope(
        controller: controller,
        child: ListenableBuilder(
          listenable: controller,
          builder: (context, _) => MaterialApp(
            title: 'Momento',
            debugShowCheckedModeBanner: false,
            theme: MomentoTheme.light(),
            darkTheme: MomentoTheme.dark(),
            themeMode: controller.settings.themeMode,
            locale: controller.settings.locale,
            supportedLocales: AppTexts.supportedLocales,
            localizationsDelegates: const [
              AppTextsDelegate(),
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            home: const _RootGate(),
          ),
        ),
      );
}

/// Entscheidet, was als Erstes zu sehen ist: Einfuehrung, Anmeldung oder App.
class _RootGate extends StatelessWidget {
  const _RootGate();

  @override
  Widget build(BuildContext context) {
    final controller = AppScope.of(context);

    final Widget child;
    if (!controller.isReady) {
      child = const _SplashScreen();
    } else if (!controller.settings.onboardingDone) {
      child = const OnboardingScreen(key: ValueKey('onboarding'));
    } else if (!controller.isSignedIn) {
      child = const WelcomeScreen(key: ValueKey('welcome'));
    } else {
      child = const HomeShell(key: ValueKey('home'));
    }

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 420),
      switchInCurve: Curves.easeOutCubic,
      switchOutCurve: Curves.easeInCubic,
      child: child,
    );
  }
}

class _SplashScreen extends StatelessWidget {
  const _SplashScreen();

  @override
  Widget build(BuildContext context) => const Scaffold(
        body: Center(
          child: SizedBox(
            width: 32,
            height: 32,
            child: CircularProgressIndicator(strokeWidth: 2.4),
          ),
        ),
      );
}
