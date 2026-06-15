enum InsightKind { latteFactor, moodPattern, weeklyRecap, achievement }

/// Locale-agnostic insight. The mock backend populates [kind] and [data];
/// the UI renders the title/body via AppLocalizations so insights flip
/// languages with the app.
class Insight {
  final String id;
  final InsightKind kind;
  final Map<String, Object?> data;

  const Insight({
    required this.id,
    required this.kind,
    this.data = const {},
  });

  factory Insight.fromJson(Map<String, dynamic> json) => Insight(
    id: json['id'] as String,
    kind: InsightKind.values.firstWhere(
      (k) => k.name == json['kind'],
      orElse: () => InsightKind.weeklyRecap,
    ),
    data: (json['data'] as Map?)?.cast<String, Object?>() ?? const {},
  );
}
