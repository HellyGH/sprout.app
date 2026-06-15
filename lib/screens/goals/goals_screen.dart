import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../l10n/app_localizations.dart';
import '../../models/goal.dart';
import '../../state/budget_controller.dart';
import '../../utils/formatters.dart';
import '../../widgets/add_goal_sheet.dart';
import '../../widgets/goal_card.dart';
import '../../widgets/milestone_celebration.dart';
import '../../widgets/set_aside_sheet.dart';
import '../../widgets/shared_goal_card.dart';
import '../../widgets/sprout_mascot.dart';
import 'goal_detail_screen.dart';
import 'shared_goal_detail_screen.dart';

class GoalsScreen extends StatelessWidget {
  const GoalsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final localeStr = Localizations.localeOf(context).languageCode;
    final budget = context.watch<BudgetController>();
    final personalGoals = budget.personalGoals;
    final sharedGoals = budget.isPartnered ? budget.sharedGoals : <Goal>[];
    final meName = budget.user?.name ?? '';
    final partnerName = budget.partner?.name ?? '';
    final code = budget.currency.code;
    final isEmpty = personalGoals.isEmpty && sharedGoals.isEmpty;
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  l.goalsHeader,
                  style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.3,
                  ),
                ),
                Material(
                  color: Theme.of(context).colorScheme.primary,
                  shape: const CircleBorder(),
                  child: InkWell(
                    customBorder: const CircleBorder(),
                    onTap: () => showAddGoalSheet(context),
                    child: const SizedBox(
                      width: 40,
                      height: 40,
                      child: Icon(
                        Icons.add_rounded,
                        color: Colors.white,
                        size: 22,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              l.goalsSubtitle,
              style: const TextStyle(color: Colors.black54, fontSize: 13),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: RefreshIndicator(
                onRefresh: () =>
                    context.read<BudgetController>().bootstrap(),
                child: isEmpty
                    ? ListView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        children: const [_EmptyState()],
                      )
                    : ListView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        children: [
                          if (sharedGoals.isNotEmpty) ...[
                            _SectionLabel(text: l.goalsTogetherSection),
                            for (final g in sharedGoals)
                              Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: SharedGoalCard(
                                  goal: g,
                                  currencyCode: code,
                                  localeStr: localeStr,
                                  meName: meName,
                                  partnerName: partnerName,
                                  onTap: () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => SharedGoalDetailScreen(
                                          goalId: g.id),
                                    ),
                                  ),
                                ),
                              ),
                            const SizedBox(height: 8),
                          ],
                          for (final g in personalGoals)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: GoalCard(
                                goal: g,
                                currencyCode: code,
                                onTap: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        GoalDetailScreen(goalId: g.id),
                                  ),
                                ),
                                onSetAside: () => _setAside(context, g),
                              ),
                            ),
                        ],
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _setAside(BuildContext context, Goal goal) async {
    final result = await showSetAsideSheet(context, goal: goal);
    if (!context.mounted || result == null) return;
    if (result.milestone != null) {
      await showMilestoneCelebration(
        context,
        goalName: goalDisplayName(AppLocalizations.of(context), result.goal),
        milestone: result.milestone!,
      );
    }
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel({required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(
        text,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SproutMascot(state: SproutState.waving, size: 120),
          const SizedBox(height: 18),
          Text(
            l.goalsEmptyTitle,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              l.goalsEmptyBody,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.black54),
            ),
          ),
          const SizedBox(height: 18),
          FilledButton.icon(
            onPressed: () => showAddGoalSheet(context),
            icon: const Icon(Icons.add_rounded),
            label: Text(l.goalsAddCta),
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primary,
              padding: const EdgeInsets.symmetric(
                horizontal: 18,
                vertical: 12,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
