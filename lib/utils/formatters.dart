import 'package:intl/intl.dart';

import '../l10n/app_localizations.dart';
import '../models/category.dart';
import '../models/goal.dart';

/// Currency symbol map. The User model stores a 3-letter code
/// ('EUR' / 'USD'); the symbol is purely a display concern, so it lives
/// here in one place instead of being re-derived at every call site.
const Map<String, String> _currencySymbols = {
  'EUR': '€',
  'USD': '\$',
  'BGN': 'лв',
};

String currencySymbol(String code) => _currencySymbols[code] ?? code;

/// Formats [amount] with the user's locale-appropriate thousands and
/// decimal separators, plus the currency symbol for [code].
///
/// - en + EUR → "€1,234.56"
/// - bg + EUR → "1234,56 €"
/// - en + USD → "\$1,234.56"
String formatCurrency(
  double amount,
  String code, {
  String locale = 'en',
  int decimals = 2,
}) {
  final symbol = currencySymbol(code);
  final fmt = NumberFormat.currency(
    locale: locale,
    symbol: symbol,
    decimalDigits: decimals,
  );
  return fmt.format(amount);
}

/// Like [formatCurrency] but with no decimals — for the kind of rounded
/// numbers Sprout uses in nudges ("you spent 12 EUR on coffee").
String formatCurrencyRounded(
  double amount,
  String code, {
  String locale = 'en',
}) =>
    formatCurrency(amount, code, locale: locale, decimals: 0);

/// Just the number, locale-formatted. No symbol. Useful for things like
/// goal progress where the symbol is shown elsewhere on the card.
String formatAmount(
  double amount, {
  String locale = 'en',
  int decimals = 2,
}) {
  final fmt = NumberFormat.decimalPatternDigits(
    locale: locale,
    decimalDigits: decimals,
  );
  return fmt.format(amount);
}

/// Day + abbreviated month, e.g. "Jan 5" / "5 яну".
String formatShortDate(DateTime d, {String locale = 'en'}) =>
    DateFormat.MMMd(locale).format(d);

/// Full date with year, e.g. "January 5, 2026" / "5 януари 2026 г.".
String formatLongDate(DateTime d, {String locale = 'en'}) =>
    DateFormat.yMMMMd(locale).format(d);

/// Full month name, e.g. "June" / "юни".
String formatMonthName(DateTime d, {String locale = 'en'}) =>
    DateFormat.MMMM(locale).format(d);

/// Weekday short name, e.g. "Mon" / "пн".
String formatWeekdayShort(DateTime d, {String locale = 'en'}) =>
    DateFormat.E(locale).format(d);

/// Time of day, e.g. "14:30" / "14:30".
String formatTime(DateTime d, {String locale = 'en'}) =>
    DateFormat.Hm(locale).format(d);

/// Returns the localized display name for a default goal/bucket (stable IDs
/// like `goal_savings`), or the user-provided name for everything else.
String goalDisplayName(AppLocalizations l, Goal goal) {
  return switch (goal.id) {
    'goal_savings' => l.goalDefaultSavings,
    'goal_invest' => l.goalDefaultInvest,
    _ => goal.name,
  };
}

/// Returns the localized display name for a seed category (stable IDs
/// like `cat_food`), or the user-provided name for everything else.
String categoryDisplayName(AppLocalizations l, Category cat) {
  return switch (cat.id) {
    'cat_food' => l.categoryDefaultFood,
    'cat_coffee' => l.categoryDefaultCoffee,
    'cat_transport' => l.categoryDefaultTransport,
    'cat_fun' => l.categoryDefaultFun,
    'cat_shopping' => l.categoryDefaultShopping,
    'cat_other' => l.categoryDefaultOther,
    _ => cat.name,
  };
}

/// Relative day label: "Today" / "Yesterday" / "Mon" / fallback short date.
/// Caller is responsible for passing the right translations for the first
/// two labels — this helper only formats the date itself.
String formatRelativeShort(
  DateTime d, {
  required String today,
  required String yesterday,
  String locale = 'en',
}) {
  final now = DateTime.now();
  final dayOnly = DateTime(d.year, d.month, d.day);
  final todayOnly = DateTime(now.year, now.month, now.day);
  final diff = todayOnly.difference(dayOnly).inDays;
  if (diff == 0) return today;
  if (diff == 1) return yesterday;
  if (diff > 1 && diff < 7) return formatWeekdayShort(d, locale: locale);
  return formatShortDate(d, locale: locale);
}
