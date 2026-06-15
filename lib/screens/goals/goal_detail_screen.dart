import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../l10n/app_localizations.dart';
import '../../models/goal.dart';
import '../../state/budget_controller.dart';
import '../../utils/formatters.dart';
import '../../widgets/edit_goal_sheet.dart';
import '../../widgets/milestone_celebration.dart';
import '../../widgets/set_aside_sheet.dart';
import '../../widgets/sprout_mascot.dart';

class GoalDetailScreen extends StatelessWidget {
  final String goalId;

  const GoalDetailScreen({super.key, required this.goalId});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final localeStr = Localizations.localeOf(context).languageCode;
    final budget = context.watch<BudgetController>();
    final goal = budget.goals.firstWhere(
      (g) => g.id == goalId,
      orElse: () => const _MissingGoal(),
    );
    if (goal is _MissingGoal) {
      return Scaffold(
        body: SafeArea(child: Center(child: Text(l.goalNotFound))),
      );
    }
    final code = budget.currency.code;
    final boosts = [...goal.boosts]
      ..sort((a, b) => b.dateTime.compareTo(a.dateTime));
    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(8, 8, 16, 4),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_rounded),
                      onPressed: () => Navigator.pop(context),
                    ),
                    Expanded(
                      child: Text(
                        goalDisplayName(l, goal),
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.3,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.tune_rounded),
                      onPressed: () => _edit(context, goal),
                    ),
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: _Hero(goal: goal, currencyCode: code),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
                child: FilledButton.icon(
                  onPressed: goal.isComplete
                      ? null
                      : () => _setAside(context, goal),
                  icon: const Icon(Icons.add_rounded),
                  label: Text(
                    goal.isComplete ? l.goalComplete : l.goalSetAside,
                  ),
                  style: FilledButton.styleFrom(
                    backgroundColor: goal.color,
                    minimumSize: const Size.fromHeight(50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28),
                    ),
                  ),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      l.goalDetailHistory,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      l.goalDetailContribCount(boosts.length),
                      style: const TextStyle(
                        color: Colors.black54,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (boosts.isEmpty)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 24),
                  child: Center(
                    child: Text(
                      l.goalDetailFirstSetAside,
                      style: const TextStyle(color: Colors.black54),
                    ),
                  ),
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                sliver: SliverList.builder(
                  itemCount: boosts.length,
                  itemBuilder: (_, i) {
                    final b = boosts[i];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.04),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(7),
                              decoration: BoxDecoration(
                                color:
                                    goal.color.withValues(alpha: 0.15),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.savings_rounded,
                                color: goal.color,
                                size: 16,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                formatRelativeShort(
                                  b.dateTime,
                                  today: l.dateToday,
                                  yesterday: l.dateYesterday,
                                  locale: localeStr,
                                ),
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                            Text(
                              '+${formatCurrencyRounded(b.amount, code, locale: localeStr)}',
                              style: TextStyle(
                                color: goal.color,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            const SliverToBoxAdapter(child: SizedBox(height: 24)),
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

  Future<void> _edit(BuildContext context, Goal goal) async {
    final navigator = Navigator.of(context);
    final deleted = await showEditGoalSheet(context, goal: goal);
    if (deleted == true && navigator.mounted) navigator.pop();
  }
}

class _Hero extends StatelessWidget {
  final Goal goal;
  final String currencyCode;

  const _Hero({required this.goal, required this.currencyCode});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final localeStr = Localizations.localeOf(context).languageCode;
    final progress = goal.progress;
    final remaining =
        (goal.targetAmount - goal.currentAmount).clamp(0.0, double.infinity);
    final sproutSize = 70 + 70 * progress;
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          SizedBox(
            width: 200,
            height: 200,
            child: Stack(
              alignment: Alignment.center,
              children: [
                TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0, end: progress),
                  duration: const Duration(milliseconds: 700),
                  curve: Curves.easeOutCubic,
                  builder: (context, v, _) => SizedBox(
                    width: 200,
                    height: 200,
                    child: CircularProgressIndicator(
                      value: v,
                      strokeWidth: 12,
                      strokeCap: StrokeCap.round,
                      backgroundColor:
                          goal.color.withValues(alpha: 0.15),
                      color: goal.color,
                    ),
                  ),
                ),
                SproutMascot(
                  state: goal.isComplete
                      ? SproutState.cheering
                      : SproutState.idle,
                  size: sproutSize,
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
              style: const TextStyle(
                color: Colors.black87,
                fontSize: 16,
              ),
              children: [
                TextSpan(
                  text:
                      '${formatCurrencyRounded(goal.currentAmount, currencyCode, locale: localeStr)} ',
                  style: const TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.5,
                  ),
                ),
                TextSpan(
                  text: l.goalOfTarget(
                    formatCurrencyRounded(
                        goal.targetAmount, currencyCode,
                        locale: localeStr),
                  ),
                  style: const TextStyle(color: Colors.black54),
                ),
              ],
            ),
          ),
          const SizedBox(height: 4),
          Text(
            goal.isComplete
                ? l.goalYouDidIt
                : l.goalToGo(formatCurrencyRounded(remaining, currencyCode,
                    locale: localeStr)),
            style: TextStyle(
              color: goal.isComplete
                  ? const Color(0xFF3FBF7F)
                  : Colors.black54,
              fontWeight:
                  goal.isComplete ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
          if (goal.deadline != null) ...[
            const SizedBox(height: 8),
            _DeadlineChip(deadline: goal.deadline!),
          ],
        ],
      ),
    );
  }
}

class _DeadlineChip extends StatelessWidget {
  final DateTime deadline;
  const _DeadlineChip({required this.deadline});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final today = DateTime.now();
    final daysLeft = DateTime(deadline.year, deadline.month, deadline.day)
        .difference(DateTime(today.year, today.month, today.day))
        .inDays;
    final label = daysLeft < 0
        ? l.goalDeadlinePast
        : daysLeft == 0
            ? l.goalDeadlineToday
            : daysLeft < 30
                ? l.goalDeadlineDaysLeft(daysLeft)
                : l.goalDeadlineWeeksLeft((daysLeft / 7).round());
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.event_rounded, size: 14, color: Colors.black54),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(fontSize: 12, color: Colors.black54),
          ),
        ],
      ),
    );
  }
}

class _MissingGoal extends Goal {
  const _MissingGoal()
      : super(
          id: '__missing__',
          name: '',
          icon: Icons.help_outline,
          color: Colors.transparent,
          targetAmount: 1,
        );
}
