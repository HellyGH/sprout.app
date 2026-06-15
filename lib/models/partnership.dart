// Phase 9 — Partner Plan.
//
// Two Sprout users link 1:1 to plan shared money while keeping personal
// finances private. These types model the link itself plus the *only* data
// a partner is ever allowed to see (the privacy-filtered summary).

/// Lifecycle of a partnership from one user's point of view.
enum PartnershipStatus { none, pendingOutbound, pendingInbound, linked }

/// How a shared goal is funded.
/// - [splitContributions]: each partner boosts from their own money; the goal
///   tracks who contributed what.
/// - [sharedPot]: partners deposit into one pot; balance is communal.
enum GoalFundingMode { splitContributions, sharedPot }

/// A live 1:1 link between two users. [userAId] is the inviter, [userBId] the
/// accepter. [inviterEmail] is only populated while an invite is still pending.
class Partnership {
  final String id;
  final String userAId;
  final String userBId;
  final DateTime linkedAt;
  final String? inviterEmail;

  const Partnership({
    required this.id,
    required this.userAId,
    required this.userBId,
    required this.linkedAt,
    this.inviterEmail,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'userAId': userAId,
    'userBId': userBId,
    'linkedAt': linkedAt.toIso8601String(),
    'inviterEmail': inviterEmail,
  };

  factory Partnership.fromJson(Map<String, dynamic> json) => Partnership(
    id: json['id'] as String,
    userAId: json['userAId'] as String,
    userBId: json['userBId'] as String,
    linkedAt: DateTime.parse(json['linkedAt'] as String),
    inviterEmail: json['inviterEmail'] as String?,
  );
}

/// The privacy-filtered view of a partner's finances. This is the *entire*
/// surface a partner can see — never overall spend, savings, budget, or
/// personal items. Built server-side (mock enforces the same filter).
class PartnerSummary {
  /// Categories the partner opted to share, each with its current-month sum.
  final List<SharedCategoryTotal> sharedCategoryTotals;

  /// Sum of shared transactions this month across both partners' shares.
  final double sharedTxThisMonthTotal;

  /// Sum of saved/pot balance across all goals in this partnership.
  final double sharedGoalsTotalSaved;

  /// ISO date the FX rate was sampled, when partners use different currencies.
  /// Null when no conversion was applied.
  final String? rateAsOf;

  const PartnerSummary({
    this.sharedCategoryTotals = const [],
    this.sharedTxThisMonthTotal = 0,
    this.sharedGoalsTotalSaved = 0,
    this.rateAsOf,
  });

  Map<String, dynamic> toJson() => {
    'sharedCategoryTotals': [
      for (final c in sharedCategoryTotals) c.toJson(),
    ],
    'sharedTxThisMonthTotal': sharedTxThisMonthTotal,
    'sharedGoalsTotalSaved': sharedGoalsTotalSaved,
    'rateAsOf': rateAsOf,
  };

  factory PartnerSummary.fromJson(Map<String, dynamic> json) => PartnerSummary(
    sharedCategoryTotals: (json['sharedCategoryTotals'] as List?)
            ?.map((e) =>
                SharedCategoryTotal.fromJson(e as Map<String, dynamic>))
            .toList() ??
        const [],
    sharedTxThisMonthTotal:
        (json['sharedTxThisMonthTotal'] as num?)?.toDouble() ?? 0,
    sharedGoalsTotalSaved:
        (json['sharedGoalsTotalSaved'] as num?)?.toDouble() ?? 0,
    rateAsOf: json['rateAsOf'] as String?,
  );
}

/// One opted-in category's monthly total. Never carries the underlying
/// transactions.
class SharedCategoryTotal {
  final String categoryId;
  final String name;
  final double total;

  const SharedCategoryTotal({
    required this.categoryId,
    required this.name,
    required this.total,
  });

  Map<String, dynamic> toJson() => {
    'categoryId': categoryId,
    'name': name,
    'total': total,
  };

  factory SharedCategoryTotal.fromJson(Map<String, dynamic> json) =>
      SharedCategoryTotal(
        categoryId: json['categoryId'] as String,
        name: json['name'] as String,
        total: (json['total'] as num).toDouble(),
      );
}

/// An inbound invite waiting on the current user to accept or decline.
class PendingInvite {
  final String inviterEmail;
  final String inviterName;

  const PendingInvite({
    required this.inviterEmail,
    required this.inviterName,
  });

  Map<String, dynamic> toJson() => {
    'inviterEmail': inviterEmail,
    'inviterName': inviterName,
  };

  factory PendingInvite.fromJson(Map<String, dynamic> json) => PendingInvite(
    inviterEmail: json['inviterEmail'] as String,
    inviterName: json['inviterName'] as String,
  );
}

/// How to dispose of one shared goal when unlinking.
enum SharedGoalAction { assignToMe, assignToPartner, delete }

/// A user's choice for a single shared goal during the unlink flow.
class SharedGoalResolution {
  final String goalId;
  final SharedGoalAction action;

  const SharedGoalResolution({required this.goalId, required this.action});
}
