import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../l10n/app_localizations.dart';
import '../models/goal.dart';
import '../models/partnership.dart';
import '../state/budget_controller.dart';
import '../utils/formatters.dart';

/// Bottom sheet to add money to a shared goal. For a shared pot it deposits;
/// for split-contributions it boosts. A "from" selector attributes the money
/// to either partner. Returns the [BoostResult] so the caller can fire confetti.
Future<BoostResult?> showSharedContributeSheet(
  BuildContext context, {
  required Goal goal,
}) {
  return showModalBottomSheet<BoostResult>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _SharedContributeSheet(goal: goal),
  );
}

class _SharedContributeSheet extends StatefulWidget {
  final Goal goal;
  const _SharedContributeSheet({required this.goal});

  @override
  State<_SharedContributeSheet> createState() => _SharedContributeSheetState();
}

class _SharedContributeSheetState extends State<_SharedContributeSheet> {
  String _amount = '';
  bool _fromMe = true;
  bool _busy = false;

  double get _value => double.tryParse(_amount) ?? 0;
  bool get _isPot => widget.goal.fundingMode == GoalFundingMode.sharedPot;

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
    final controller = context.read<BudgetController>();
    final me = controller.user;
    final partner = controller.partner;
    final contributorId = _fromMe ? me?.id : partner?.id;
    try {
      final result = _isPot
          ? await controller.depositToSharedPot(
              widget.goal.id,
              _value,
              contributorUserId: contributorId,
            )
          : await controller.boostGoal(
              widget.goal.id,
              _value,
              contributorUserId: contributorId,
            );
      if (mounted) Navigator.pop(context, result);
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
    final meName = budget.user?.name ?? l.sharedGoalYou;
    final partnerName = budget.partner?.name ?? '';
    final remaining = (widget.goal.targetAmount - widget.goal.currentAmount)
        .clamp(0.0, double.infinity);
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
              _isPot ? l.sharedGoalDepositTitle : l.goalSetAside,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 4),
            Text(
              l.setAsideToGo(
                formatCurrencyRounded(remaining, code, locale: localeStr),
              ),
              style: const TextStyle(color: Colors.black54, fontSize: 13),
            ),
            const SizedBox(height: 14),
            Text(
              '$symbol${_amount.isEmpty ? '0' : _amount}',
              style: const TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.w800,
                letterSpacing: -1.2,
              ),
            ),
            const SizedBox(height: 12),
            // "from" selector — attribute the money to either partner.
            Row(
              children: [
                Text(
                  '${l.sharedGoalDepositFrom}:',
                  style: const TextStyle(color: Colors.black54),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _FromToggle(
                    meName: meName,
                    partnerName: partnerName,
                    fromMe: _fromMe,
                    onChanged: (v) => setState(() => _fromMe = v),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _MiniKeypad(onKey: _onKey, onBackspace: _onBackspace),
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _value > 0 && !_busy ? _submit : null,
                style: FilledButton.styleFrom(
                  backgroundColor: widget.goal.color,
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
                        _isPot ? l.sharedGoalDeposit : l.goalSetAside,
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

class _FromToggle extends StatelessWidget {
  final String meName;
  final String partnerName;
  final bool fromMe;
  final ValueChanged<bool> onChanged;

  const _FromToggle({
    required this.meName,
    required this.partnerName,
    required this.fromMe,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final accent = Theme.of(context).colorScheme.primary;
    Widget seg(String label, bool selected, VoidCallback onTap) => Expanded(
          child: GestureDetector(
            onTap: onTap,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 140),
              height: 40,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: selected ? accent : Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                label,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: selected ? Colors.white : Colors.black87,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        );
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: const Color(0xFFE2E8F0),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          seg(meName, fromMe, () => onChanged(true)),
          const SizedBox(width: 3),
          seg(partnerName, !fromMe, () => onChanged(false)),
        ],
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
