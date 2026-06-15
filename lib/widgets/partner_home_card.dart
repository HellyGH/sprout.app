import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../l10n/app_localizations.dart';
import '../state/budget_controller.dart';
import '../utils/formatters.dart';
import '../screens/root_shell.dart';

/// Home-screen partner section. Solo → a promo that jumps to the Together
/// tab. Linked → a compact shared summary (top shared goal progress + shared
/// spend this month). Shows nothing private about the partner.
class PartnerHomeCard extends StatelessWidget {
  const PartnerHomeCard({super.key});

  @override
  Widget build(BuildContext context) {
    final budget = context.watch<BudgetController>();
    return budget.isPartnered ? const _LinkedCard() : const _SoloCard();
  }
}

class _SoloCard extends StatelessWidget {
  const _SoloCard();

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final accent = Theme.of(context).colorScheme.primary;
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => RootShell.goToTab(context, kTogetherTabIndex),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.eco_rounded, color: accent, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  l.togetherSoloTitle,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                  ),
                ),
              ),
              const Icon(Icons.arrow_forward_rounded,
                  size: 18, color: Colors.black38),
            ],
          ),
        ),
      ),
    );
  }
}

class _LinkedCard extends StatelessWidget {
  const _LinkedCard();

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final localeStr = Localizations.localeOf(context).languageCode;
    final budget = context.watch<BudgetController>();
    final code = budget.currency.code;
    final partnerName = budget.partner?.name ?? '';
    final topGoal = budget.sharedGoals.isEmpty ? null : budget.sharedGoals.first;
    final sharedThisMonth = budget.partnerSummary?.sharedTxThisMonthTotal ?? 0;
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => RootShell.goToTab(context, kTogetherTabIndex),
        child: Container(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.eco_rounded,
                      color: Theme.of(context).colorScheme.primary, size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      l.togetherHeader(partnerName),
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                      ),
                    ),
                  ),
                  const Icon(Icons.arrow_forward_rounded,
                      size: 18, color: Colors.black38),
                ],
              ),
              if (topGoal != null) ...[
                const SizedBox(height: 12),
                Text(
                  topGoal.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: LinearProgressIndicator(
                    value: topGoal.progress,
                    minHeight: 8,
                    backgroundColor: Colors.grey.shade200,
                    color: topGoal.color,
                  ),
                ),
              ],
              const SizedBox(height: 10),
              Text(
                '${l.togetherSharedTxThisMonth}: ${formatCurrency(sharedThisMonth, code, locale: localeStr)}',
                style: const TextStyle(color: Colors.black54, fontSize: 13),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
