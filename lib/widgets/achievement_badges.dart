import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../l10n/app_localizations.dart';
import '../models/achievement.dart';
import '../state/budget_controller.dart';
import '../utils/formatters.dart';

class AchievementBadges extends StatelessWidget {
  const AchievementBadges({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final localeStr = Localizations.localeOf(context).languageCode;
    final budget = context.watch<BudgetController>();
    final code = budget.currency.code;
    final achievements = budget.achievements;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(4, 8, 4, 6),
          child: Text(
            l.achievementsHeader,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        GridView.count(
          crossAxisCount: 2,
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
          childAspectRatio: 1.55,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          children: [
            for (final a in achievements)
              _BadgeTile(
                emoji: a.emoji,
                label: _label(l, a, code, localeStr),
                description: _description(l, a),
                unlocked: a.unlocked,
              ),
          ],
        ),
      ],
    );
  }

  String _label(
    AppLocalizations l,
    Achievement a,
    String code,
    String localeStr,
  ) {
    return switch (a.kind) {
      AchievementKind.firstAmountSaved => l.achFirstSavedLabel(
          formatCurrencyRounded(a.amount ?? 0, code, locale: localeStr),
        ),
      AchievementKind.streak7 => l.achStreakLabel,
      AchievementKind.cooldowns10 => l.achCooldownsLabel,
      AchievementKind.firstGoalHit => l.achGoalLabel,
    };
  }

  String _description(AppLocalizations l, Achievement a) {
    return switch (a.kind) {
      AchievementKind.firstAmountSaved => l.achFirstSavedDesc,
      AchievementKind.streak7 => l.achStreakDesc,
      AchievementKind.cooldowns10 => l.achCooldownsDesc,
      AchievementKind.firstGoalHit => l.achGoalDesc,
    };
  }
}

class _BadgeTile extends StatelessWidget {
  final String emoji;
  final String label;
  final String description;
  final bool unlocked;

  const _BadgeTile({
    required this.emoji,
    required this.label,
    required this.description,
    required this.unlocked,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: 38,
                height: 38,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: unlocked
                      ? const Color(0xFF3FBF7F).withValues(alpha: 0.15)
                      : Colors.black.withValues(alpha: 0.05),
                  shape: BoxShape.circle,
                ),
                child: Opacity(
                  opacity: unlocked ? 1 : 0.4,
                  child: Text(
                    emoji,
                    style: const TextStyle(fontSize: 20),
                  ),
                ),
              ),
              if (!unlocked)
                const Positioned(
                  right: -2,
                  bottom: -2,
                  child: CircleAvatar(
                    radius: 8,
                    backgroundColor: Colors.white,
                    child: Icon(
                      Icons.lock_rounded,
                      size: 10,
                      color: Colors.black54,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 12.5,
                    color: unlocked ? Colors.black87 : Colors.black54,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 11,
                    color: Colors.black54,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
