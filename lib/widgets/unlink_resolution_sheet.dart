import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../l10n/app_localizations.dart';
import '../models/goal.dart';
import '../models/partnership.dart';
import '../state/budget_controller.dart';

/// Поток за прекъсване на връзката. Потвърждава намерението и за всяка
/// споделена цел пита дали да се запази (става лична), да се предаде на
/// партньора или да се изтрие. Избраните решения се прилагат, преди връзката
/// да бъде премахната.
/// Returns true once the unlink completed.
Future<bool?> showUnlinkResolutionSheet(BuildContext context) {
  return showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => const _UnlinkResolutionSheet(),
  );
}

class _UnlinkResolutionSheet extends StatefulWidget {
  const _UnlinkResolutionSheet();

  @override
  State<_UnlinkResolutionSheet> createState() => _UnlinkResolutionSheetState();
}

class _UnlinkResolutionSheetState extends State<_UnlinkResolutionSheet> {
  final Map<String, SharedGoalAction> _choices = {};
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    for (final g in context.read<BudgetController>().sharedGoals) {
      _choices[g.id] = SharedGoalAction.assignToMe;
    }
  }

  Future<void> _confirm() async {
    setState(() => _busy = true);
    final controller = context.read<BudgetController>();
    final resolutions = [
      for (final entry in _choices.entries)
        SharedGoalResolution(goalId: entry.key, action: entry.value),
    ];
    try {
      await controller.unlinkPartner(resolutions: resolutions);
      if (mounted) Navigator.pop(context, true);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final budget = context.watch<BudgetController>();
    final partnerName = budget.partner?.name ?? '';
    final sharedGoals = budget.sharedGoals;
    return Container(
      padding: EdgeInsets.fromLTRB(
        20,
        16,
        20,
        20 + MediaQuery.of(context).viewInsets.bottom,
      ),
      decoration: const BoxDecoration(
        color: Color(0xFFEDF1F5),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
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
            l.unlinkResolveTitle,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 4),
          Text(
            l.partnerUnlinkConfirm,
            style: const TextStyle(color: Colors.black54),
          ),
          if (sharedGoals.isNotEmpty) ...[
            const SizedBox(height: 18),
            Text(
              l.unlinkResolveBody,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 10),
            for (final g in sharedGoals)
              _GoalResolution(
                goal: g,
                partnerName: partnerName,
                value: _choices[g.id]!,
                onChanged: (a) => setState(() => _choices[g.id] = a),
              ),
          ],
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: _busy ? null : () => Navigator.pop(context, false),
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
                  onPressed: _busy ? null : _confirm,
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFFFF6B6B),
                    padding: const EdgeInsets.symmetric(vertical: 14),
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
                          l.partnerUnlink,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _GoalResolution extends StatelessWidget {
  final Goal goal;
  final String partnerName;
  final SharedGoalAction value;
  final ValueChanged<SharedGoalAction> onChanged;

  const _GoalResolution({
    required this.goal,
    required this.partnerName,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final options = <SharedGoalAction, String>{
      SharedGoalAction.assignToMe: l.unlinkResolveAssignMe,
      SharedGoalAction.assignToPartner: l.unlinkResolveAssignPartner(partnerName),
      SharedGoalAction.delete: l.unlinkResolveDelete,
    };
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(goal.icon, color: goal.color, size: 18),
              const SizedBox(width: 8),
              Text(
                goal.name,
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final entry in options.entries)
                ChoiceChip(
                  label: Text(entry.value),
                  selected: value == entry.key,
                  onSelected: (_) => onChanged(entry.key),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
