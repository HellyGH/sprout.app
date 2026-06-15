class Transaction {
  final String id;
  final DateTime dateTime;
  final double amount;
  final String currencyCode;
  final String categoryId;
  final String? note;
  final int? mood;
  final bool isPlanned;
  final DateTime createdAt;

  /// Phase 9. When true, both partners' totals reflect their share of this
  /// transaction. The unshared portion stays personal.
  final bool isShared;

  /// Phase 9. The partner's share, 0..100. Only set when [isShared]
  /// (defaults to 50). The caller keeps `100 - partnerSharePercent`.
  final double? partnerSharePercent;

  /// Phase 9. Which partner physically paid. Required when [isShared].
  final String? paidByUserId;

  const Transaction({
    required this.id,
    required this.dateTime,
    required this.amount,
    required this.currencyCode,
    required this.categoryId,
    this.note,
    this.mood,
    this.isPlanned = false,
    required this.createdAt,
    this.isShared = false,
    this.partnerSharePercent,
    this.paidByUserId,
  });

  Transaction copyWith({
    DateTime? dateTime,
    double? amount,
    String? currencyCode,
    String? categoryId,
    String? note,
    int? mood,
    bool? isPlanned,
    bool? isShared,
    double? partnerSharePercent,
    String? paidByUserId,
  }) {
    return Transaction(
      id: id,
      dateTime: dateTime ?? this.dateTime,
      amount: amount ?? this.amount,
      currencyCode: currencyCode ?? this.currencyCode,
      categoryId: categoryId ?? this.categoryId,
      note: note ?? this.note,
      mood: mood ?? this.mood,
      isPlanned: isPlanned ?? this.isPlanned,
      createdAt: createdAt,
      isShared: isShared ?? this.isShared,
      partnerSharePercent: partnerSharePercent ?? this.partnerSharePercent,
      paidByUserId: paidByUserId ?? this.paidByUserId,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'dateTime': dateTime.toIso8601String(),
    'amount': amount,
    'currencyCode': currencyCode,
    'categoryId': categoryId,
    'note': note,
    'mood': mood,
    'isPlanned': isPlanned,
    'createdAt': createdAt.toIso8601String(),
    'isShared': isShared,
    'partnerSharePercent': partnerSharePercent,
    'paidByUserId': paidByUserId,
  };

  factory Transaction.fromJson(Map<String, dynamic> json) => Transaction(
    id: json['id'] as String,
    dateTime: DateTime.parse(json['dateTime'] as String),
    amount: (json['amount'] as num).toDouble(),
    currencyCode: json['currencyCode'] as String,
    categoryId: json['categoryId'] as String,
    note: json['note'] as String?,
    mood: json['mood'] as int?,
    isPlanned: json['isPlanned'] as bool? ?? false,
    createdAt: DateTime.parse(json['createdAt'] as String),
    isShared: json['isShared'] as bool? ?? false,
    partnerSharePercent: (json['partnerSharePercent'] as num?)?.toDouble(),
    paidByUserId: json['paidByUserId'] as String?,
  );
}
