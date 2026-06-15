import 'package:finance_app/l10n/app_localizations_en.dart';
import 'package:finance_app/models/category.dart';
import 'package:finance_app/utils/formatters.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('currencySymbol', () {
    test('maps known codes to glyphs', () {
      expect(currencySymbol('EUR'), '€');
      expect(currencySymbol('USD'), '\$');
      expect(currencySymbol('BGN'), 'лв');
    });

    test('falls back to the code itself for unknown currencies', () {
      expect(currencySymbol('XYZ'), 'XYZ');
    });
  });

  group('formatCurrency', () {
    test('en EUR uses Latin grouping + decimal', () {
      expect(
        formatCurrency(1234.56, 'EUR', locale: 'en'),
        '€1,234.56',
      );
    });

    test('bg EUR uses comma as decimal separator', () {
      final formatted = formatCurrency(1234.56, 'EUR', locale: 'bg');
      // intl uses a (non-breaking) space as the thousands separator in bg
      // and a comma as the decimal separator. Assert on structure rather
      // than the exact whitespace, which can drift between intl versions.
      expect(formatted, contains('€'));
      expect(formatted, contains(',56'));
      expect(formatted, isNot(contains('.56')));
    });

    test('formatCurrencyRounded drops decimals and rounds half-up', () {
      expect(formatCurrencyRounded(12.5, 'USD', locale: 'en'), '\$13');
      expect(formatCurrencyRounded(99.4, 'USD', locale: 'en'), '\$99');
    });
  });

  group('formatRelativeShort', () {
    test('returns the "today" label for today', () {
      final now = DateTime.now();
      expect(
        formatRelativeShort(
          now,
          today: 'TODAY',
          yesterday: 'YESTERDAY',
          locale: 'en',
        ),
        'TODAY',
      );
    });

    test('returns the "yesterday" label for yesterday', () {
      final yesterday = DateTime.now().subtract(const Duration(days: 1));
      expect(
        formatRelativeShort(
          yesterday,
          today: 'TODAY',
          yesterday: 'YESTERDAY',
          locale: 'en',
        ),
        'YESTERDAY',
      );
    });
  });

  group('categoryDisplayName', () {
    final l = AppLocalizationsEn();

    test('localizes seed category IDs', () {
      const food = Category(
        id: 'cat_food',
        name: 'IGNORED_STORED_NAME',
        icon: Icons.restaurant_rounded,
        color: Color(0xFF34D399),
        monthlyCap: 200,
      );
      expect(categoryDisplayName(l, food), 'Food');
    });

    test('returns the stored name verbatim for user-created categories', () {
      const custom = Category(
        id: 'cat_${'user_12345'}',
        name: 'My weird hobby',
        icon: Icons.star_rounded,
        color: Color(0xFFA78BFA),
        monthlyCap: 50,
      );
      expect(categoryDisplayName(l, custom), 'My weird hobby');
    });
  });
}
