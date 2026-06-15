import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../l10n/app_localizations.dart';
import '../state/budget_controller.dart';

/// Language switcher (English / Bulgarian). Theme mode + accent were removed —
/// the app uses its default styling for everyone.
class LanguagePanel extends StatelessWidget {
  const LanguagePanel({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final user = context.watch<BudgetController>().user;
    if (user == null) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l.appearanceLanguage,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.black54,
            ),
          ),
          const SizedBox(height: 8),
          _LanguageSegment(value: user.languageCode),
        ],
      ),
    );
  }
}

class _LanguageSegment extends StatelessWidget {
  /// User-stored language code, or null = follow device locale.
  final String? value;
  const _LanguageSegment({required this.value});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    // The active locale displayed right now, so the highlight always reflects
    // what the user sees.
    final activeCode = Localizations.localeOf(context).languageCode;
    final selected = value ?? activeCode;
    final options = <(String, String)>[
      ('en', l.appearanceLanguageEnglish),
      ('bg', l.appearanceLanguageBulgarian),
    ];
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          for (final (code, label) in options)
            Expanded(
              child: GestureDetector(
                onTap: () => context.read<BudgetController>().setLocale(code),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 160),
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: selected == code
                        ? Theme.of(context).cardColor
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: selected == code
                        ? [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.06),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ]
                        : null,
                  ),
                  child: Text(
                    label,
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: selected == code ? scheme.primary : Colors.black54,
                      fontSize: 13,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
