import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Catches the most common l10n regression: adding a key to the source
/// ARB and forgetting to add a translation. Also catches accidental
/// placeholder renames inside translated strings.
void main() {
  final root = Directory.current.path;
  final en = _loadArb('$root/lib/l10n/app_en.arb');
  final bg = _loadArb('$root/lib/l10n/app_bg.arb');

  test('en and bg ARBs have identical translatable key sets', () {
    final enKeys = _translatableKeys(en);
    final bgKeys = _translatableKeys(bg);
    final missingInBg = enKeys.difference(bgKeys);
    final missingInEn = bgKeys.difference(enKeys);
    expect(
      missingInBg,
      isEmpty,
      reason: 'app_bg.arb is missing keys defined in app_en.arb:\n'
          '${missingInBg.toList()..sort()}',
    );
    expect(
      missingInEn,
      isEmpty,
      reason: 'app_en.arb is missing keys defined in app_bg.arb (likely '
          'a stray translation):\n${missingInEn.toList()..sort()}',
    );
  });

  test('every {placeholder} in en exists verbatim in bg', () {
    final problems = <String>[];
    for (final key in _translatableKeys(en)) {
      final enValue = en[key];
      final bgValue = bg[key];
      if (enValue is! String || bgValue is! String) continue;
      final enPlaceholders = _placeholders(enValue);
      for (final ph in enPlaceholders) {
        if (!bgValue.contains('{$ph')) {
          problems.add('"$key": en has {$ph} but bg does not — '
              'bg value: $bgValue');
        }
      }
    }
    expect(
      problems,
      isEmpty,
      reason: 'Placeholder drift between en/bg:\n${problems.join('\n')}',
    );
  });
}

Map<String, dynamic> _loadArb(String path) {
  final raw = File(path).readAsStringSync();
  return jsonDecode(raw) as Map<String, dynamic>;
}

/// Translatable keys: anything that isn't a metadata key (@@locale or @key).
Set<String> _translatableKeys(Map<String, dynamic> arb) {
  return arb.keys
      .where((k) => !k.startsWith('@'))
      .toSet();
}

/// Pulls placeholder names out of `{name}` and `{name, plural, ...}` tokens.
Set<String> _placeholders(String value) {
  final out = <String>{};
  final re = RegExp(r'\{(\w+)');
  for (final m in re.allMatches(value)) {
    out.add(m.group(1)!);
  }
  return out;
}
