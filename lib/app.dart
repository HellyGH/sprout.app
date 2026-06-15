import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'data/budget_api.dart';
import 'l10n/app_localizations.dart';
import 'screens/auth/auth_screen.dart';
import 'screens/onboarding/onboarding_flow.dart';
import 'screens/root_shell.dart';
import 'screens/splash/splash_screen.dart';
import 'state/budget_controller.dart';
import 'theme.dart';

class FinanceApp extends StatelessWidget {
  final BudgetApi api;

  const FinanceApp({super.key, required this.api});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => BudgetController(api)..bootstrap(),
      child: const _AppRoot(),
    );
  }
}

class _AppRoot extends StatelessWidget {
  const _AppRoot();

  @override
  Widget build(BuildContext context) {
    // Fixed default styling for everyone — no dark mode, no accent override.
    final locale = context.select<BudgetController, Locale?>((c) => c.locale);
    return MaterialApp(
      onGenerateTitle: (ctx) => AppLocalizations.of(ctx).appTitle,
      theme: buildSproutTheme(
        seed: SproutBrand.primary,
        brightness: Brightness.light,
      ),
      locale: locale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: const AuthGate(),
    );
  }
}

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    final status =
        context.select<BudgetController, AuthStatus>((c) => c.authStatus);
    final child = switch (status) {
      AuthStatus.booting => const SplashScreen(),
      AuthStatus.signedOut => const AuthScreen(),
      AuthStatus.needsOnboarding => const OnboardingFlow(),
      AuthStatus.ready => const RootShell(),
    };
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 250),
      switchInCurve: Curves.easeOut,
      switchOutCurve: Curves.easeIn,
      transitionBuilder: (child, anim) =>
          FadeTransition(opacity: anim, child: child),
      child: KeyedSubtree(key: ValueKey(status), child: child),
    );
  }
}
