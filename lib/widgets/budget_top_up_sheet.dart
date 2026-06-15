import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../l10n/app_localizations.dart';
import '../state/budget_controller.dart';
import '../utils/formatters.dart';

/// Bottom sheet to add a one-off bonus to the current month's budget. Adds to
/// any existing top-up for the month and leaves future months untouched.
Future<void> showBudgetTopUpSheet(BuildContext context) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => const _BudgetTopUpSheet(),
  );
}

class _BudgetTopUpSheet extends StatefulWidget {
  const _BudgetTopUpSheet();

  @override
  State<_BudgetTopUpSheet> createState() => _BudgetTopUpSheetState();
}

class _BudgetTopUpSheetState extends State<_BudgetTopUpSheet> {
  String _amount = '';
  bool _busy = false;

  double get _value => double.tryParse(_amount) ?? 0;

  void _onKey(String key) {
    setState(() {
      if (key == '.') {
        if (_amount.isEmpty) _amount = '0';
        if (_amount.contains('.')) return;
        _amount += '.';
      } else {
        if (_amount.contains('.') &&
            _amount.length - _amount.indexOf('.') > 2) {
          return;
        }
        if (_amount == '0') _amount = '';
        _amount += key;
      }
    });
    HapticFeedback.selectionClick();
  }

  void _onBackspace() {
    if (_amount.isEmpty) return;
    setState(() => _amount = _amount.substring(0, _amount.length - 1));
  }

  Future<void> _submit() async {
    if (_value <= 0 || _busy) return;
    setState(() => _busy = true);
    HapticFeedback.mediumImpact();
    try {
      await context.read<BudgetController>().addBudgetTopUp(_value);
      if (mounted) Navigator.pop(context);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final localeStr = Localizations.localeOf(context).languageCode;
    final budget = context.watch<BudgetController>();
    final code = budget.currency.code;
    final symbol = currencySymbol(code);
    final accent = Theme.of(context).colorScheme.primary;
    final monthName = formatMonthName(DateTime.now(), locale: localeStr);
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 22),
        decoration: const BoxDecoration(
          color: Color(0xFFEDF1F5),
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.black26,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(height: 14),
            Text(
              l.topUpTitle(monthName),
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 4),
            Text(
              l.topUpSubtitle,
              style: const TextStyle(color: Colors.black54),
            ),
            const SizedBox(height: 18),
            Text(
              '$symbol${_amount.isEmpty ? '0' : _amount}',
              style: const TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.w800,
                letterSpacing: -1.2,
              ),
            ),
            const SizedBox(height: 14),
            _MiniKeypad(onKey: _onKey, onBackspace: _onBackspace),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _value > 0 && !_busy ? _submit : null,
                style: FilledButton.styleFrom(
                  backgroundColor: accent,
                  minimumSize: const Size.fromHeight(52),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(28),
                  ),
                ),
                child: _busy
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white),
                      )
                    : Text(
                        l.topUpButton(
                          formatCurrency(_value, code, locale: localeStr),
                        ),
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MiniKeypad extends StatelessWidget {
  final ValueChanged<String> onKey;
  final VoidCallback onBackspace;
  const _MiniKeypad({required this.onKey, required this.onBackspace});

  static const _layout = [
    ['1', '2', '3'],
    ['4', '5', '6'],
    ['7', '8', '9'],
    ['.', '0', '⌫'],
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (final row in _layout)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              children: [
                for (final key in row)
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: GestureDetector(
                        onTap: () => key == '⌫' ? onBackspace() : onKey(key),
                        child: Container(
                          height: 46,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Text(
                            key,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
      ],
    );
  }
}
