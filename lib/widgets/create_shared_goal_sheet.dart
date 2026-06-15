import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../l10n/app_localizations.dart';
import '../models/goal.dart';
import '../models/partnership.dart';
import '../state/budget_controller.dart';
import '../utils/formatters.dart';

/// Sheet to create a goal jointly owned with the partner, including a
/// funding-mode choice (shared pot vs. split contributions).
Future<void> showCreateSharedGoalSheet(BuildContext context) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => const _CreateSharedGoalSheet(),
  );
}

class _CreateSharedGoalSheet extends StatefulWidget {
  const _CreateSharedGoalSheet();

  @override
  State<_CreateSharedGoalSheet> createState() => _CreateSharedGoalSheetState();
}

class _CreateSharedGoalSheetState extends State<_CreateSharedGoalSheet> {
  final _name = TextEditingController();
  final _amount = TextEditingController();
  DateTime? _deadline;
  GoalFundingMode _mode = GoalFundingMode.sharedPot;
  bool _submitting = false;

  @override
  void dispose() {
    _name.dispose();
    _amount.dispose();
    super.dispose();
  }

  bool get _canSubmit {
    if (_submitting) return false;
    final amt = double.tryParse(_amount.text.replaceAll(',', '.')) ?? 0;
    return _name.text.trim().isNotEmpty && amt > 0;
  }

  Future<void> _pickDeadline() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _deadline ?? now.add(const Duration(days: 90)),
      firstDate: now,
      lastDate: now.add(const Duration(days: 365 * 5)),
    );
    if (picked != null) setState(() => _deadline = picked);
  }

  Future<void> _save() async {
    if (!_canSubmit) return;
    setState(() => _submitting = true);
    try {
      final goal = Goal(
        id: '',
        name: _name.text.trim(),
        icon: Icons.diversity_3_rounded,
        color: const Color(0xFF3FBF7F),
        targetAmount: double.parse(_amount.text.replaceAll(',', '.')),
        deadline: _deadline,
      );
      await context.read<BudgetController>().createSharedGoal(goal, _mode);
      if (mounted) Navigator.pop(context);
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  InputDecoration _decoration(String label) => InputDecoration(
        labelText: label,
        filled: true,
        fillColor: Colors.white,
        isDense: true,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
      );

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final localeStr = Localizations.localeOf(context).languageCode;
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 14, 20, 22),
        decoration: const BoxDecoration(
          color: Color(0xFFEDF1F5),
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
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
              const SizedBox(height: 14),
              Text(
                l.sharedGoalCreateTitle,
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: _name,
                onChanged: (_) => setState(() {}),
                decoration: _decoration(l.onbGoalNameField),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _amount,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                onChanged: (_) => setState(() {}),
                decoration: _decoration(l.onbGoalTargetField),
              ),
              const SizedBox(height: 10),
              InkWell(
                onTap: _pickDeadline,
                borderRadius: BorderRadius.circular(14),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.event_rounded,
                          size: 18, color: Colors.black54),
                      const SizedBox(width: 10),
                      Text(
                        _deadline == null
                            ? l.onbGoalDeadlineHint
                            : formatLongDate(_deadline!, locale: localeStr),
                        style: TextStyle(
                          color: _deadline == null
                              ? Colors.black54
                              : Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                l.sharedGoalFundingQuestion,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 10),
              _ModeCard(
                title: l.goalFundingPot,
                desc: l.sharedGoalModePotDesc,
                icon: Icons.savings_rounded,
                selected: _mode == GoalFundingMode.sharedPot,
                onTap: () =>
                    setState(() => _mode = GoalFundingMode.sharedPot),
              ),
              const SizedBox(height: 8),
              _ModeCard(
                title: l.goalFundingSplit,
                desc: l.sharedGoalModeSplitDesc,
                icon: Icons.call_split_rounded,
                selected: _mode == GoalFundingMode.splitContributions,
                onTap: () => setState(
                    () => _mode = GoalFundingMode.splitContributions),
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed:
                          _submitting ? null : () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(28),
                        ),
                      ),
                      child: Text(l.commonCancel),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: FilledButton(
                      onPressed: _canSubmit ? _save : null,
                      style: FilledButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(28),
                        ),
                      ),
                      child: _submitting
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2, color: Colors.white),
                            )
                          : Text(
                              l.goalSheetAddGoal,
                              style:
                                  const TextStyle(fontWeight: FontWeight.w600),
                            ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ModeCard extends StatelessWidget {
  final String title;
  final String desc;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  const _ModeCard({
    required this.title,
    required this.desc,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final accent = Theme.of(context).colorScheme.primary;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 140),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected ? accent : Colors.transparent,
            width: 2,
          ),
        ),
        child: Row(
          children: [
            Icon(icon, color: selected ? accent : Colors.black45, size: 22),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(fontWeight: FontWeight.w700)),
                  const SizedBox(height: 2),
                  Text(
                    desc,
                    style:
                        const TextStyle(color: Colors.black54, fontSize: 12),
                  ),
                ],
              ),
            ),
            if (selected) Icon(Icons.check_circle_rounded, color: accent),
          ],
        ),
      ),
    );
  }
}
