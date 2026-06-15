import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../../models/currency.dart';
import '../../state/budget_controller.dart';
import '../../utils/formatters.dart';
import '../../widgets/amount_entry_sheet.dart';
import 'onboarding_flow.dart';

class BudgetStep extends StatefulWidget {
  final OnboardingDraft draft;
  final VoidCallback onChanged;

  const BudgetStep({
    super.key,
    required this.draft,
    required this.onChanged,
  });

  @override
  State<BudgetStep> createState() => _BudgetStepState();
}

class _BudgetStepState extends State<BudgetStep> {
  static const _presets = [400.0, 1000.0, 2500.0, 5000.0];

  Future<void> _enterExact() async {
    final l = AppLocalizations.of(context);
    final amount = await showAmountEntrySheet(
      context,
      title: l.onbBudgetTitle,
      confirmLabel: l.commonSave,
      initialValue: widget.draft.monthlyBudget,
      max: kMaxMonthlyBudget,
      currencyCode: widget.draft.currencyCode,
    );
    if (amount != null) {
      setState(() => widget.draft.monthlyBudget = amount);
      widget.onChanged();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final localeStr = Localizations.localeOf(context).languageCode;
    final draft = widget.draft;
    final perDay = (draft.monthlyBudget / 30).round();
    final big = formatCurrencyRounded(
      draft.monthlyBudget,
      draft.currencyCode,
      locale: localeStr,
    );
    final perDayFormatted = formatCurrencyRounded(
      perDay.toDouble(),
      draft.currencyCode,
      locale: localeStr,
    );
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),
          Text(
            l.onbBudgetTitle,
            style: const TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            l.onbBudgetSubtitle,
            style: const TextStyle(color: Colors.black54),
          ),
          const SizedBox(height: 24),

          // Currency segmented control
          Text(
            l.onbBudgetCurrency,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.black54,
            ),
          ),
          const SizedBox(height: 8),
          _CurrencySegment(
            value: draft.currencyCode,
            onChanged: (code) {
              setState(() => draft.currencyCode = code);
              widget.onChanged();
            },
          ),
          const SizedBox(height: 28),

          // Big number — tap to type an exact amount (up to the cap).
          Center(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: _enterExact,
              child: Column(
                children: [
                  Text(
                    big,
                    style: const TextStyle(
                      fontSize: 56,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -1.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    l.onbBudgetPerDay(perDayFormatted),
                    style: const TextStyle(color: Colors.black54),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Slider — quick range; tap the number above for higher amounts.
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: Colors.deepPurple,
              thumbColor: Colors.deepPurple,
              inactiveTrackColor:
                  Colors.deepPurple.withValues(alpha: 0.18),
              overlayColor: Colors.deepPurple.withValues(alpha: 0.15),
            ),
            child: Slider(
              min: 50,
              max: 5000,
              divisions: 99,
              value: draft.monthlyBudget.clamp(50, 5000),
              onChanged: (v) {
                setState(() => draft.monthlyBudget = v);
                widget.onChanged();
              },
            ),
          ),

          // Quick-pick chips
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final p in _presets)
                ChoiceChip(
                  label: Text(
                    formatCurrencyRounded(
                      p,
                      draft.currencyCode,
                      locale: localeStr,
                    ),
                  ),
                  selected: draft.monthlyBudget == p,
                  onSelected: (_) {
                    setState(() => draft.monthlyBudget = p);
                    widget.onChanged();
                  },
                  selectedColor:
                      Colors.deepPurple.withValues(alpha: 0.15),
                  labelStyle: TextStyle(
                    color: draft.monthlyBudget == p
                        ? Colors.deepPurple
                        : Colors.black87,
                    fontWeight: FontWeight.w600,
                  ),
                  side: BorderSide(
                    color: draft.monthlyBudget == p
                        ? Colors.deepPurple
                        : Colors.black12,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CurrencySegment extends StatelessWidget {
  final String value;
  final ValueChanged<String> onChanged;

  const _CurrencySegment({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          for (final c in Currency.values)
            Expanded(
              child: GestureDetector(
                onTap: () => onChanged(c.code),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color:
                        value == c.code ? Colors.white : Colors.transparent,
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: value == c.code
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
                    c.code,
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: value == c.code
                          ? Colors.deepPurple
                          : Colors.black54,
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
