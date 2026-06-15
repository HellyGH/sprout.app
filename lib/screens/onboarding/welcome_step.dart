import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../l10n/app_localizations.dart';
import '../../state/budget_controller.dart';
import '../../widgets/sprout_mascot.dart';

class WelcomeStep extends StatelessWidget {
  const WelcomeStep({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final user = context.watch<BudgetController>().user;
    final greeting = (user == null || user.name.isEmpty)
        ? l.onbWelcomeGreetingGeneric
        : l.onbWelcomeGreetingNamed(user.name.split(' ').first);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Center(
            child: SproutMascot(state: SproutState.waving, size: 140),
          ),
          const SizedBox(height: 36),
          Text(
            '$greeting\n${l.onbWelcomeIntro}',
            style: const TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.w700,
              height: 1.15,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            l.onbWelcomeSubtitle,
            style: const TextStyle(fontSize: 16, color: Colors.black54),
          ),
        ],
      ),
    );
  }
}
