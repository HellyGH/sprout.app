import 'package:flutter/material.dart';

import 'partnership.dart';

/// Distinguishes "not passed" from "explicitly set to null" in [Goal.copyWith]
/// for the nullable [Goal.partnershipId] / [Goal.fundingMode] fields.
const Object _goalSentinel = Object();

/// One contribution toward a goal — appended to [Goal.boosts] when the user
/// taps "Set aside €X".
class GoalBoost {
  final double amount;
  final DateTime dateTime;

  /// Phase 9. Who made this contribution. Null for personal-goal boosts
  /// (legacy + solo); required for shared goals (split contributions and
  /// pot deposits) so the UI can attribute it to a partner.
  final String? contributorUserId;

  const GoalBoost({
    required this.amount,
    required this.dateTime,
    this.contributorUserId,
  });

  Map<String, dynamic> toJson() => {
    'amount': amount,
    'dateTime': dateTime.toIso8601String(),
    'contributorUserId': contributorUserId,
  };

  factory GoalBoost.fromJson(Map<String, dynamic> json) => GoalBoost(
    amount: (json['amount'] as num).toDouble(),
    dateTime: DateTime.parse(json['dateTime'] as String),
    contributorUserId: json['contributorUserId'] as String?,
  );
}

class Goal {
  final String id;
  final String name;
  final IconData icon;
  final Color color;
  final double targetAmount;
  final double currentAmount;
  final DateTime? deadline;
  final List<GoalBoost> boosts;

  /// Phase 9. Null = personal goal. Non-null = shared with the partner in
  /// this partnership.
  final String? partnershipId;

  /// Phase 9. Funding mode for shared goals (null when personal).
  final GoalFundingMode? fundingMode;

  /// Phase 9. Communal pot balance — only meaningful when
  /// [fundingMode] == [GoalFundingMode.sharedPot].
  final double sharedPotBalance;

  const Goal({
    required this.id,
    required this.name,
    required this.icon,
    required this.color,
    required this.targetAmount,
    this.currentAmount = 0,
    this.deadline,
    this.boosts = const [],
    this.partnershipId,
    this.fundingMode,
    this.sharedPotBalance = 0,
  });

  double get progress =>
      targetAmount <= 0 ? 0 : (currentAmount / targetAmount).clamp(0.0, 1.0);

  bool get isComplete => currentAmount >= targetAmount;

  /// True when this goal is owned jointly with the partner.
  bool get isShared => partnershipId != null;

  Goal copyWith({
    String? name,
    IconData? icon,
    Color? color,
    double? targetAmount,
    double? currentAmount,
    DateTime? deadline,
    List<GoalBoost>? boosts,
    Object? partnershipId = _goalSentinel,
    Object? fundingMode = _goalSentinel,
    double? sharedPotBalance,
  }) {
    return Goal(
      id: id,
      name: name ?? this.name,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      targetAmount: targetAmount ?? this.targetAmount,
      currentAmount: currentAmount ?? this.currentAmount,
      deadline: deadline ?? this.deadline,
      boosts: boosts ?? this.boosts,
      partnershipId: identical(partnershipId, _goalSentinel)
          ? this.partnershipId
          : partnershipId as String?,
      fundingMode: identical(fundingMode, _goalSentinel)
          ? this.fundingMode
          : fundingMode as GoalFundingMode?,
      sharedPotBalance: sharedPotBalance ?? this.sharedPotBalance,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'icon': icon.codePoint,
    'iconFontFamily': icon.fontFamily,
    'color': color.toARGB32(),
    'targetAmount': targetAmount,
    'currentAmount': currentAmount,
    'deadline': deadline?.toIso8601String(),
    'boosts': [for (final b in boosts) b.toJson()],
    'partnershipId': partnershipId,
    'fundingMode': fundingMode?.name,
    'sharedPotBalance': sharedPotBalance,
  };

  factory Goal.fromJson(Map<String, dynamic> json) => Goal(
    id: json['id'] as String,
    name: json['name'] as String,
    icon: IconData(
      json['icon'] as int,
      fontFamily: json['iconFontFamily'] as String? ?? 'MaterialIcons',
    ),
    color: Color(json['color'] as int),
    targetAmount: (json['targetAmount'] as num).toDouble(),
    currentAmount: (json['currentAmount'] as num?)?.toDouble() ?? 0,
    deadline: json['deadline'] == null
        ? null
        : DateTime.parse(json['deadline'] as String),
    boosts: (json['boosts'] as List?)
            ?.map((e) => GoalBoost.fromJson(e as Map<String, dynamic>))
            .toList() ??
        const [],
    partnershipId: json['partnershipId'] as String?,
    fundingMode: json['fundingMode'] == null
        ? null
        : GoalFundingMode.values.firstWhere(
            (m) => m.name == json['fundingMode'],
            orElse: () => GoalFundingMode.splitContributions,
          ),
    sharedPotBalance: (json['sharedPotBalance'] as num?)?.toDouble() ?? 0,
  );
}
