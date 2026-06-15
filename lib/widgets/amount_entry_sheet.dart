import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../state/budget_controller.dart';
import '../utils/formatters.dart';

/// A reusable keypad bottom sheet for entering a single money amount, capped
/// at [max]. Returns the entered value, or null if dismissed. Used for editing
/// the monthly budget and for the onboarding exact-amount entry.
Future<double?> showAmountEntrySheet(
  BuildContext context, {
  required String title,
  String? subtitle,
  required String confirmLabel,
  double initialValue = 0,
  double max = kMaxMonthlyBudget,
  String? currencyCode,
}) {
  return showModalBottomSheet<double>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _AmountEntrySheet(
      title: title,
      subtitle: subtitle,
      confirmLabel: confirmLabel,
      initialValue: initialValue,
      max: max,
      currencyCode: currencyCode,
    ),
  );
}

class _AmountEntrySheet extends StatefulWidget {
  final String title;
  final String? subtitle;
  final String confirmLabel;
  final double initialValue;
  final double max;
  final String? currencyCode;

  const _AmountEntrySheet({
    required this.title,
    required this.subtitle,
    required this.confirmLabel,
    required this.initialValue,
    required this.max,
    required this.currencyCode,
  });

  @override
  State<_AmountEntrySheet> createState() => _AmountEntrySheetState();
}

class _AmountEntrySheetState extends State<_AmountEntrySheet> {
  late String _amount = widget.initialValue > 0
      ? _format(widget.initialValue)
      : '';

  static String _format(double v) {
    final s = v.toStringAsFixed(2);
    return s.endsWith('.00') ? s.substring(0, s.length - 3) : s;
  }

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
        final candidate = (_amount == '0' ? '' : _amount) + key;
        // Don't let the entry exceed the cap.
        if ((double.tryParse(candidate) ?? 0) > widget.max) return;
        _amount = candidate;
      }
    });
    HapticFeedback.selectionClick();
  }

  void _onBackspace() {
    if (_amount.isEmpty) return;
    setState(() => _amount = _amount.substring(0, _amount.length - 1));
  }

  @override
  Widget build(BuildContext context) {
    final code =
        widget.currencyCode ?? context.read<BudgetController>().currency.code;
    final symbol = currencySymbol(code);
    final accent = Theme.of(context).colorScheme.primary;
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
              widget.title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            ),
            if (widget.subtitle != null) ...[
              const SizedBox(height: 4),
              Text(
                widget.subtitle!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.black54),
              ),
            ],
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
            _Keypad(onKey: _onKey, onBackspace: _onBackspace),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _value > 0
                    ? () => Navigator.pop(context, _value)
                    : null,
                style: FilledButton.styleFrom(
                  backgroundColor: accent,
                  minimumSize: const Size.fromHeight(52),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(28),
                  ),
                ),
                child: Text(
                  widget.confirmLabel,
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

class _Keypad extends StatelessWidget {
  final ValueChanged<String> onKey;
  final VoidCallback onBackspace;
  const _Keypad({required this.onKey, required this.onBackspace});

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
