import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../l10n/app_localizations.dart';
import '../models/goal.dart';
import '../state/budget_controller.dart';
import '../utils/formatters.dart';

Future<BoostResult?> showSetAsideSheet(
  BuildContext context, {
  required Goal goal,
}) {
  return showModalBottomSheet<BoostResult>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _SetAsideSheet(goal: goal),
  );
}

class _SetAsideSheet extends StatefulWidget {
  final Goal goal;
  const _SetAsideSheet({required this.goal});

  @override
  State<_SetAsideSheet> createState() => _SetAsideSheetState();
}

class _SetAsideSheetState extends State<_SetAsideSheet> {
  String _amount = '';
  bool _submitting = false;

  static const _quickPicks = [10, 25, 50, 100];

  void _onKey(String key) {
    setState(() {
      if (key == '.') {
        if (_amount.isEmpty) _amount = '0';
        if (_amount.contains('.')) return;
        _amount += '.';
      } else {
        if (_amount.contains('.')) {
          final dot = _amount.indexOf('.');
          if (_amount.length - dot > 3) return;
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

  double get _value => double.tryParse(_amount) ?? 0;

  Future<void> _submit() async {
    if (_value <= 0 || _submitting) return;
    setState(() => _submitting = true);
    HapticFeedback.mediumImpact();
    try {
      final navigator = Navigator.of(context);
      final result = await context
          .read<BudgetController>()
          .boostGoal(widget.goal.id, _value);
      navigator.pop(result);
    } catch (_) {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final localeStr = Localizations.localeOf(context).languageCode;
    final budget = context.watch<BudgetController>();
    final code = budget.currency.code;
    final symbol = currencySymbol(code);
    final remaining = (widget.goal.targetAmount - widget.goal.currentAmount)
        .clamp(0.0, double.infinity);
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
        decoration: const BoxDecoration(
          color: Color(0xFFEDF1F5),
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.black26,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Center(
              child: Text(
                l.setAsideTitle(goalDisplayName(l, widget.goal)),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(height: 4),
            Center(
              child: Text(
                l.setAsideToGo(
                  formatCurrencyRounded(remaining, code, locale: localeStr),
                ),
                style: const TextStyle(color: Colors.black54, fontSize: 12),
              ),
            ),
            const SizedBox(height: 16),
            Center(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 140),
                child: Text(
                  '$symbol${_amount.isEmpty ? '0' : _amount}',
                  key: ValueKey(_amount),
                  style: const TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -1.2,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              alignment: WrapAlignment.center,
              spacing: 8,
              children: [
                for (final q in _quickPicks)
                  ChoiceChip(
                    label: Text('$symbol$q'),
                    selected: _value == q.toDouble(),
                    onSelected: (_) =>
                        setState(() => _amount = q.toString()),
                    selectedColor:
                        widget.goal.color.withValues(alpha: 0.15),
                    labelStyle: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: _value == q.toDouble()
                          ? widget.goal.color
                          : Colors.black87,
                    ),
                    side: BorderSide(
                      color: _value == q.toDouble()
                          ? widget.goal.color
                          : Colors.black12,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            _Keypad(onKey: _onKey, onBackspace: _onBackspace),
            const SizedBox(height: 14),
            FilledButton(
              onPressed: (_value > 0 && !_submitting) ? _submit : null,
              style: FilledButton.styleFrom(
                backgroundColor: widget.goal.color,
                minimumSize: const Size.fromHeight(52),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(28),
                ),
              ),
              child: _submitting
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Text(
                      _value > 0
                          ? l.setAsideButtonAmount(
                              formatCurrencyRounded(_value, code,
                                  locale: localeStr),
                            )
                          : l.goalSetAside,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
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
                      child: _KeyButton(
                        label: key,
                        onTap: () =>
                            key == '⌫' ? onBackspace() : onKey(key),
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

class _KeyButton extends StatefulWidget {
  final String label;
  final VoidCallback onTap;

  const _KeyButton({required this.label, required this.onTap});

  @override
  State<_KeyButton> createState() => _KeyButtonState();
}

class _KeyButtonState extends State<_KeyButton> {
  bool _down = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      onTapDown: (_) => setState(() => _down = true),
      onTapCancel: () => setState(() => _down = false),
      onTapUp: (_) => setState(() => _down = false),
      child: AnimatedScale(
        scale: _down ? 0.92 : 1.0,
        duration: const Duration(milliseconds: 60),
        child: Container(
          height: 50,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Text(
            widget.label,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
        ),
      ),
    );
  }
}
