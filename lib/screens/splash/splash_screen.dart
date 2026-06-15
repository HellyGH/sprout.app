import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../../widgets/sprout_mascot.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SproutMascot(state: SproutState.idle, size: 120),
            const SizedBox(height: 24),
            Text(
              l.appTitle,
              style: const TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              l.appTagline,
              style: const TextStyle(color: Colors.black54, fontSize: 14),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: 28,
              height: 28,
              child: CircularProgressIndicator(
                strokeWidth: 2.4,
                color: Colors.deepPurple.shade300,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
