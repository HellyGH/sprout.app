import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../models/goal.dart';
import '../utils/formatters.dart';
import 'sprout_mascot.dart';

class GoalCard extends StatelessWidget {
  final Goal goal;
  final String currencyCode;
  final VoidCallback onTap;
  final VoidCallback onSetAside;

  const GoalCard({
    super.key,
    required this.goal,
    required this.currencyCode,
    required this.onTap,
    required this.onSetAside,
  });

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final localeStr = Localizations.localeOf(context).languageCode;
    final progress = goal.progress;
    final isComplete = goal.isComplete;
    final remaining =
        (goal.targetAmount - goal.currentAmount).clamp(0.0, double.infinity);
    final paceLabel = _paceLabel(l);
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(22),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(22),
        child: Container(
          padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _RingWithSprout(
                progress: progress,
                color: goal.color,
                isComplete: isComplete,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(goal.icon, color: goal.color, size: 18),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            goalDisplayName(l, goal),
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 15,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    RichText(
                      text: TextSpan(
                        style: const TextStyle(
                          color: Colors.black87,
                          fontSize: 13,
                        ),
                        children: [
                          TextSpan(
                            text:
                                '${formatCurrencyRounded(goal.currentAmount, currencyCode, locale: localeStr)} ',
                            style: const TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 17,
                            ),
                          ),
                          TextSpan(
                            text: l.goalOfTarget(
                              formatCurrencyRounded(goal.targetAmount,
                                  currencyCode,
                                  locale: localeStr),
                            ),
                            style: const TextStyle(color: Colors.black54),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 4),
                    if (isComplete)
                      Text(
                        l.goalYouDidIt,
                        style: const TextStyle(
                          color: Color(0xFF3FBF7F),
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      )
                    else
                      Text(
                        paceLabel ??
                            l.goalToGo(formatCurrencyRounded(
                                remaining, currencyCode,
                                locale: localeStr)),
                        style: const TextStyle(
                          color: Colors.black54,
                          fontSize: 12,
                        ),
                      ),
                    const SizedBox(height: 10),
                    if (!isComplete)
                      OutlinedButton(
                        onPressed: onSetAside,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: goal.color,
                          side: BorderSide(
                            color: goal.color.withValues(alpha: 0.5),
                          ),
                          minimumSize: Size.zero,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 8,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        child: Text(
                          l.goalSetAside,
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String? _paceLabel(AppLocalizations l) {
    if (goal.boosts.isEmpty) return null;
    final cutoff = DateTime.now().subtract(const Duration(days: 28));
    final recent =
        goal.boosts.where((b) => b.dateTime.isAfter(cutoff)).toList();
    if (recent.isEmpty) return null;
    final total = recent.fold<double>(0, (s, b) => s + b.amount);
    final perWeek = total / 4;
    if (perWeek <= 0) return null;
    final remaining = goal.targetAmount - goal.currentAmount;
    if (remaining <= 0) return null;
    final weeks = (remaining / perWeek).round();
    return l.goalPaceWeeks(weeks);
  }
}

class _RingWithSprout extends StatelessWidget {
  final double progress;
  final Color color;
  final bool isComplete;

  const _RingWithSprout({
    required this.progress,
    required this.color,
    required this.isComplete,
  });

  @override
  Widget build(BuildContext context) {
    final sproutSize = 28 + 30 * progress;
    return SizedBox(
      width: 76,
      height: 76,
      child: Stack(
        alignment: Alignment.center,
        children: [
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: progress),
            duration: const Duration(milliseconds: 600),
            curve: Curves.easeOutCubic,
            builder: (context, value, _) => SizedBox(
              width: 76,
              height: 76,
              child: CircularProgressIndicator(
                value: value,
                strokeWidth: 6,
                strokeCap: StrokeCap.round,
                backgroundColor: color.withValues(alpha: 0.15),
                color: color,
              ),
            ),
          ),
          SproutMascot(
            state: isComplete ? SproutState.cheering : SproutState.idle,
            size: sproutSize,
          ),
        ],
      ),
    );
  }
}
