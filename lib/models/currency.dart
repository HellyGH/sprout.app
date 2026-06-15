enum Currency {
  eur,
  usd;

  String get code => name.toUpperCase();

  static Currency fromCode(String code) =>
      Currency.values.firstWhere((c) => c.code == code, orElse: () => Currency.eur);
}
