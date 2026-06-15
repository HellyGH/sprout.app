import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../l10n/app_localizations.dart';
import '../state/budget_controller.dart';
import '../utils/formatters.dart';

/// Daily nudge banner that sits at the top of Home. Renders a small
/// Sprout-voice one-liner derived from [BudgetController.dailyNudge].
/// Hides itself when there's nothing to say.
class NudgeBanner extends StatelessWidget {
  const NudgeBanner({super.key});

  @override
  Widget build(BuildContext context) {
    final budget = context.watch<BudgetController>();
    final nudge = budget.dailyNudge;
    if (nudge == null) return const SizedBox.shrink();
    final l = AppLocalizations.of(context);
    final localeStr = Localizations.localeOf(context).languageCode;
    final text = switch (nudge.kind) {
      DailyNudgeKind.noSpend => l.nudgeNoSpend,
      DailyNudgeKind.aheadOfPace => l.nudgeAheadOfPace(
          formatCurrencyRounded(nudge.amount ?? 0, budget.currency.code,
              locale: localeStr),
        ),
      DailyNudgeKind.treatDay => l.nudgeTreatDay,
    };
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF3FBF7F).withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          const Text('🌱', style: TextStyle(fontSize: 18)),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 13.5,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1F7A4F),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
