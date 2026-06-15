import 'partnership.dart';

enum SpendingPersonality { saver, treater, goalChaser, impulse }

const Object _sentinel = Object();

/// Theme preference. Defaults to [system] (follow OS). Persisted as a
/// string on User; widened/narrowed cleanly across mock + Python backend.
enum ThemePreference { system, light, dark }

class User {
  final String id;
  final String name;
  final String email;
  final String currencyCode;
  final double monthlyBudget;
  final String themeAccent;
  final bool hasOnboarded;
  final SpendingPersonality? personality;

  /// Phase 4 cooldown timer. When [cooldownEnabled] is true and an AddTx
  /// amount ≥ [cooldownThreshold] (and not isPlanned), the user takes a
  /// 30s breath before logging. Cancelling adds to [cooldownSaved] and
  /// increments [cooldownWinCount].
  final bool cooldownEnabled;
  final double cooldownThreshold;
  final double cooldownSaved;
  final int cooldownWinCount;

  /// Phase 6 habit loops. ISO date strings (yyyy-MM-dd) the user has
  /// flagged as "no-spend". The streak compute unions these with days
  /// that have transactions.
  final List<DateTime> noSpendDays;

  /// Phase 7 theme preference. Defaults to follow the OS.
  final ThemePreference themeMode;

  /// Phase 8 round-up savings. When true, every logged spend triggers a
  /// boost on the primary goal equal to `ceil(amount) − amount`.
  final bool roundUpEnabled;

  /// BCP-47 language code for app UI. Null means "follow device locale".
  /// Currently 'en' or 'bg'.
  final String? languageCode;

  /// Phase 9 partner plan. [partnerId] is the linked partner's userId (null
  /// when solo or while an invite is still pending). [partnership] is this
  /// user's view of the link lifecycle. [linkedAt] is when the current
  /// partnership was accepted.
  final String? partnerId;
  final PartnershipStatus partnership;
  final DateTime? linkedAt;

  /// One-off budget top-ups keyed by month ('yyyy-MM'). A bonus that lifts
  /// that single month's budget without changing the recurring [monthlyBudget].
  final Map<String, double> budgetTopUps;

  const User({
    required this.id,
    required this.name,
    required this.email,
    this.currencyCode = 'EUR',
    this.monthlyBudget = 0,
    this.themeAccent = '#673AB7',
    this.hasOnboarded = false,
    this.personality,
    this.cooldownEnabled = false,
    this.cooldownThreshold = 30,
    this.cooldownSaved = 0,
    this.cooldownWinCount = 0,
    this.noSpendDays = const [],
    this.themeMode = ThemePreference.system,
    this.roundUpEnabled = false,
    this.languageCode,
    this.partnerId,
    this.partnership = PartnershipStatus.none,
    this.linkedAt,
    this.budgetTopUps = const {},
  });

  User copyWith({
    String? name,
    String? email,
    String? currencyCode,
    double? monthlyBudget,
    String? themeAccent,
    bool? hasOnboarded,
    SpendingPersonality? personality,
    bool? cooldownEnabled,
    double? cooldownThreshold,
    double? cooldownSaved,
    int? cooldownWinCount,
    List<DateTime>? noSpendDays,
    ThemePreference? themeMode,
    bool? roundUpEnabled,
    Object? languageCode = _sentinel,
    Object? partnerId = _sentinel,
    PartnershipStatus? partnership,
    Object? linkedAt = _sentinel,
    Map<String, double>? budgetTopUps,
  }) {
    return User(
      id: id,
      name: name ?? this.name,
      email: email ?? this.email,
      currencyCode: currencyCode ?? this.currencyCode,
      monthlyBudget: monthlyBudget ?? this.monthlyBudget,
      themeAccent: themeAccent ?? this.themeAccent,
      hasOnboarded: hasOnboarded ?? this.hasOnboarded,
      personality: personality ?? this.personality,
      cooldownEnabled: cooldownEnabled ?? this.cooldownEnabled,
      cooldownThreshold: cooldownThreshold ?? this.cooldownThreshold,
      cooldownSaved: cooldownSaved ?? this.cooldownSaved,
      cooldownWinCount: cooldownWinCount ?? this.cooldownWinCount,
      noSpendDays: noSpendDays ?? this.noSpendDays,
      themeMode: themeMode ?? this.themeMode,
      roundUpEnabled: roundUpEnabled ?? this.roundUpEnabled,
      languageCode: identical(languageCode, _sentinel)
          ? this.languageCode
          : languageCode as String?,
      partnerId: identical(partnerId, _sentinel)
          ? this.partnerId
          : partnerId as String?,
      partnership: partnership ?? this.partnership,
      linkedAt: identical(linkedAt, _sentinel)
          ? this.linkedAt
          : linkedAt as DateTime?,
      budgetTopUps: budgetTopUps ?? this.budgetTopUps,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'email': email,
    'currencyCode': currencyCode,
    'monthlyBudget': monthlyBudget,
    'themeAccent': themeAccent,
    'hasOnboarded': hasOnboarded,
    'personality': personality?.name,
    'cooldownEnabled': cooldownEnabled,
    'cooldownThreshold': cooldownThreshold,
    'cooldownSaved': cooldownSaved,
    'cooldownWinCount': cooldownWinCount,
    'noSpendDays': [for (final d in noSpendDays) d.toIso8601String()],
    'themeMode': themeMode.name,
    'roundUpEnabled': roundUpEnabled,
    'languageCode': languageCode,
    'partnerId': partnerId,
    'partnership': partnership.name,
    'linkedAt': linkedAt?.toIso8601String(),
    'budgetTopUps': budgetTopUps,
  };

  factory User.fromJson(Map<String, dynamic> json) => User(
    id: json['id'] as String,
    name: json['name'] as String,
    email: json['email'] as String,
    currencyCode: json['currencyCode'] as String? ?? 'EUR',
    monthlyBudget: (json['monthlyBudget'] as num?)?.toDouble() ?? 0,
    themeAccent: json['themeAccent'] as String? ?? '#673AB7',
    hasOnboarded: json['hasOnboarded'] as bool? ?? false,
    personality: json['personality'] == null
        ? null
        : SpendingPersonality.values.firstWhere(
            (p) => p.name == json['personality'],
            orElse: () => SpendingPersonality.saver,
          ),
    cooldownEnabled: json['cooldownEnabled'] as bool? ?? false,
    cooldownThreshold:
        (json['cooldownThreshold'] as num?)?.toDouble() ?? 30,
    cooldownSaved: (json['cooldownSaved'] as num?)?.toDouble() ?? 0,
    cooldownWinCount: (json['cooldownWinCount'] as num?)?.toInt() ?? 0,
    noSpendDays: (json['noSpendDays'] as List?)
            ?.map((e) => DateTime.parse(e as String))
            .toList() ??
        const [],
    themeMode: json['themeMode'] == null
        ? ThemePreference.system
        : ThemePreference.values.firstWhere(
            (m) => m.name == json['themeMode'],
            orElse: () => ThemePreference.system,
          ),
    roundUpEnabled: json['roundUpEnabled'] as bool? ?? false,
    languageCode: json['languageCode'] as String?,
    partnerId: json['partnerId'] as String?,
    partnership: json['partnership'] == null
        ? PartnershipStatus.none
        : PartnershipStatus.values.firstWhere(
            (p) => p.name == json['partnership'],
            orElse: () => PartnershipStatus.none,
          ),
    linkedAt: json['linkedAt'] == null
        ? null
        : DateTime.parse(json['linkedAt'] as String),
    budgetTopUps: (json['budgetTopUps'] as Map?)?.map(
          (k, v) => MapEntry(k as String, (v as num).toDouble()),
        ) ??
        const {},
  );
}
