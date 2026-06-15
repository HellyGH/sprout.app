/// Phase 6 achievement badge. Derived state — unlocking is computed from
/// the current user/transactions/goals/streak rather than stored. Carries a
/// [kind] enum so the UI can localize the label and description.
enum AchievementKind { firstAmountSaved, streak7, cooldowns10, firstGoalHit }

class Achievement {
  final AchievementKind kind;
  final String emoji;
  final bool unlocked;

  /// Display amount for the firstAmountSaved badge, in user currency.
  /// Null for other kinds.
  final double? amount;

  const Achievement({
    required this.kind,
    required this.emoji,
    required this.unlocked,
    this.amount,
  });
}
