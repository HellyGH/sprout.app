import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../l10n/app_localizations.dart';
import '../../models/goal.dart';
import '../../models/partnership.dart';
import '../../state/budget_controller.dart';
import '../../utils/formatters.dart';
import '../../widgets/milestone_celebration.dart';
import '../../widgets/partner_common.dart';
import '../../widgets/shared_contribute_sheet.dart';
import '../../widgets/sprout_mascot.dart';

/// Detail view for a goal jointly owned with a partner. Reuses the personal
/// goal-detail chrome (progress ring, mascot, deadline chip, milestone
/// confetti) and adds partner-specific bits: a pot-balance card + deposit for
/// shared pots, or per-partner contribution bars for split goals, plus a
/// contributor-attributed history list.
class SharedGoalDetailScreen extends StatelessWidget {
  final String goalId;

  const SharedGoalDetailScreen({super.key, required this.goalId});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final localeStr = Localizations.localeOf(context).languageCode;
    final budget = context.watch<BudgetController>();
    final goal = budget.sharedGoals.where((g) => g.id == goalId).firstOrNull;
    if (goal == null) {
      return Scaffold(
        body: SafeArea(child: Center(child: Text(l.goalNotFound))),
      );
    }
    final code = budget.currency.code;
    final meId = budget.user?.id;
    final meName = budget.user?.name ?? l.sharedGoalYou;
    final partnerName = budget.partner?.name ?? '';
    final isPot = goal.fundingMode == GoalFundingMode.sharedPot;
    final boosts = [...goal.boosts]
      ..sort((a, b) => b.dateTime.compareTo(a.dateTime));

    // Per-partner contribution totals (split goals).
    double mine = 0, theirs = 0;
    for (final b in goal.boosts) {
      if (b.contributorUserId == meId) {
        mine += b.amount;
      } else {
        theirs += b.amount;
      }
    }

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
                        goal.name,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.3,
                        ),
                      ),
                    ),
                    _FundingBadge(
                      label: isPot ? l.goalFundingPot : l.goalFundingSplit,
                    ),
                    const SizedBox(width: 8),
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
            if (isPot)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                  child: _PotBalanceCard(goal: goal, currencyCode: code),
                ),
              )
            else
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                  child: _SplitBars(
                    goal: goal,
                    meName: meName,
                    partnerName: partnerName,
                    mine: mine,
                    theirs: theirs,
                    currencyCode: code,
                    localeStr: localeStr,
                  ),
                ),
              ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
                child: FilledButton.icon(
                  onPressed: goal.isComplete
                      ? null
                      : () => _contribute(context, goal),
                  icon: Icon(
                    isPot ? Icons.savings_rounded : Icons.add_rounded,
                  ),
                  label: Text(
                    goal.isComplete
                        ? l.goalComplete
                        : isPot
                            ? l.sharedGoalDeposit
                            : l.goalSetAside,
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
                child: Text(
                  l.sharedGoalContributions,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
            if (boosts.isEmpty)
              SliverToBoxAdapter(
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
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
                    final byMe = b.contributorUserId == meId;
                    final who = byMe ? meName : partnerName;
                    final color = byMe
                        ? Theme.of(context).colorScheme.primary
                        : goal.color;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 12),
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
                            PartnerAvatar(name: who, color: color, size: 30),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    who,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 14,
                                    ),
                                  ),
                                  Text(
                                    formatRelativeShort(
                                      b.dateTime,
                                      today: l.dateToday,
                                      yesterday: l.dateYesterday,
                                      locale: localeStr,
                                    ),
                                    style: const TextStyle(
                                      color: Colors.black45,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Text(
                              '+${formatCurrencyRounded(b.amount, code, locale: localeStr)}',
                              style: TextStyle(
                                color: color,
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

  Future<void> _contribute(BuildContext context, Goal goal) async {
    final l = AppLocalizations.of(context);
    final result = await showSharedContributeSheet(context, goal: goal);
    if (!context.mounted || result == null) return;
    final code = context.read<BudgetController>().currency.code;
    final localeStr = Localizations.localeOf(context).languageCode;
    if (goal.fundingMode == GoalFundingMode.sharedPot) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(
              l.partnerPotDeposit(
                formatCurrencyRounded(
                  result.goal.sharedPotBalance, code,
                  locale: localeStr,
                ),
              ),
            ),
          ),
        );
    }
    if (result.milestone != null) {
      await showMilestoneCelebration(
        context,
        goalName: result.goal.name,
        milestone: result.milestone!,
      );
    }
  }
}

class _FundingBadge extends StatelessWidget {
  final String label;
  const _FundingBadge({required this.label});

  @override
  Widget build(BuildContext context) {
    final accent = Theme.of(context).colorScheme.primary;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: accent,
          fontWeight: FontWeight.w700,
          fontSize: 12,
        ),
      ),
    );
  }
}

class _PotBalanceCard extends StatelessWidget {
  final Goal goal;
  final String currencyCode;
  const _PotBalanceCard({required this.goal, required this.currencyCode});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final localeStr = Localizations.localeOf(context).languageCode;
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF2765CF), Color(0xFF633CA5)],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          const Icon(Icons.savings_rounded, color: Colors.white, size: 28),
          const SizedBox(width: 14),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l.sharedGoalPotBalance,
                style: const TextStyle(color: Colors.white70, fontSize: 13),
              ),
              const SizedBox(height: 2),
              Text(
                formatCurrency(goal.sharedPotBalance, currencyCode,
                    locale: localeStr),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SplitBars extends StatelessWidget {
  final Goal goal;
  final String meName;
  final String partnerName;
  final double mine;
  final double theirs;
  final String currencyCode;
  final String localeStr;

  const _SplitBars({
    required this.goal,
    required this.meName,
    required this.partnerName,
    required this.mine,
    required this.theirs,
    required this.currencyCode,
    required this.localeStr,
  });

  @override
  Widget build(BuildContext context) {
    final accent = Theme.of(context).colorScheme.primary;
    final total = (mine + theirs) <= 0 ? 1.0 : (mine + theirs);
    Widget bar(String name, double amount, Color color) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(name,
                    style: const TextStyle(
                        fontWeight: FontWeight.w600, fontSize: 13)),
                Text(
                  formatCurrencyRounded(amount, currencyCode,
                      locale: localeStr),
                  style: TextStyle(color: color, fontWeight: FontWeight.w700),
                ),
              ],
            ),
            const SizedBox(height: 4),
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: LinearProgressIndicator(
                value: (amount / total).clamp(0.0, 1.0),
                minHeight: 8,
                backgroundColor: Colors.grey.shade200,
                color: color,
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          bar(meName, mine, accent),
          bar(partnerName, theirs, goal.color),
        ],
      ),
    );
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
                      backgroundColor: goal.color.withValues(alpha: 0.15),
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
              style: const TextStyle(color: Colors.black87, fontSize: 16),
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
                    formatCurrencyRounded(goal.targetAmount, currencyCode,
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
              color: goal.isComplete ? const Color(0xFF3FBF7F) : Colors.black54,
              fontWeight: goal.isComplete ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
