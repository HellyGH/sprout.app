import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../l10n/app_localizations.dart';
import '../models/goal.dart';
import '../state/budget_controller.dart';
import '../utils/formatters.dart';

class _Preset {
  final String Function(AppLocalizations l) labelOf;
  final IconData icon;
  final Color color;
  final double amount;
  const _Preset(this.labelOf, this.icon, this.color, this.amount);
}

final _presets = <_Preset>[
  _Preset((l) => l.onbGoalPresetTokyo, Icons.flight_takeoff_rounded,
      const Color(0xFF2765CF), 1200),
  _Preset((l) => l.onbGoalPresetMacbook, Icons.laptop_mac_rounded,
      const Color(0xFF6B7280), 1500),
  _Preset((l) => l.onbGoalPresetEmergency, Icons.shield_rounded,
      const Color(0xFF3FBF7F), 1000),
  _Preset((l) => l.onbGoalPresetConcert, Icons.music_note_rounded,
      const Color(0xFFA78BFA), 120),
];

Future<void> showAddGoalSheet(BuildContext context) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => const _AddGoalSheet(),
  );
}

class _AddGoalSheet extends StatefulWidget {
  const _AddGoalSheet();

  @override
  State<_AddGoalSheet> createState() => _AddGoalSheetState();
}

class _AddGoalSheetState extends State<_AddGoalSheet> {
  _Preset? _selected;
  bool _custom = false;
  final _name = TextEditingController();
  final _amount = TextEditingController();
  DateTime? _deadline;
  bool _submitting = false;

  @override
  void dispose() {
    _name.dispose();
    _amount.dispose();
    super.dispose();
  }

  bool get _canSubmit {
    if (_submitting) return false;
    if (_custom) {
      final amt = double.tryParse(_amount.text.replaceAll(',', '.')) ?? 0;
      return _name.text.trim().isNotEmpty && amt > 0;
    }
    return _selected != null;
  }

  Future<void> _save(AppLocalizations l) async {
    if (!_canSubmit) return;
    setState(() => _submitting = true);
    try {
      final goal = _custom
          ? Goal(
              id: '',
              name: _name.text.trim(),
              icon: Icons.star_rounded,
              color: Colors.deepPurple,
              targetAmount:
                  double.parse(_amount.text.replaceAll(',', '.')),
              deadline: _deadline,
            )
          : Goal(
              id: '',
              name: _selected!.labelOf(l),
              icon: _selected!.icon,
              color: _selected!.color,
              targetAmount: _selected!.amount,
            );
      await context.read<BudgetController>().addGoal(goal);
      if (mounted) Navigator.pop(context);
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
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

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final localeStr = Localizations.localeOf(context).languageCode;
    final currencyCode =
        context.read<BudgetController>().currency.code;
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
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
                l.goalSheetNewTitle,
                style: const TextStyle(
                    fontSize: 18, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 4),
              Text(
                l.onbGoalTitle,
                style: const TextStyle(color: Colors.black54),
              ),
              const SizedBox(height: 16),
              GridView.count(
                crossAxisCount: 2,
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
                childAspectRatio: 1.2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  for (final p in _presets)
                    _PresetCard(
                      preset: p,
                      label: p.labelOf(l),
                      selected: !_custom &&
                          _selected?.labelOf(l) == p.labelOf(l),
                      onTap: () => setState(() {
                        _custom = false;
                        _selected = p;
                      }),
                      currencyCode: currencyCode,
                      localeStr: localeStr,
                    ),
                ],
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: () => setState(() {
                  _custom = true;
                  _selected = null;
                }),
                icon: Icon(
                  _custom ? Icons.edit : Icons.add_rounded,
                  size: 18,
                ),
                label: Text(_custom ? l.onbGoalCustom : l.onbGoalCreateOwn),
                style: OutlinedButton.styleFrom(
                  foregroundColor:
                      _custom ? Colors.deepPurple : Colors.black87,
                  side: BorderSide(
                    color: _custom ? Colors.deepPurple : Colors.black12,
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
              if (_custom) ...[
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
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 14,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.event_rounded,
                          size: 18,
                          color: Colors.black54,
                        ),
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
              ],
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
                      onPressed: _canSubmit ? () => _save(l) : null,
                      style: FilledButton.styleFrom(
                        backgroundColor:
                            Theme.of(context).colorScheme.primary,
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
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : Text(
                              l.goalSheetAddGoal,
                              style: const TextStyle(
                                  fontWeight: FontWeight.w600),
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
}

class _PresetCard extends StatelessWidget {
  final _Preset preset;
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final String currencyCode;
  final String localeStr;

  const _PresetCard({
    required this.preset,
    required this.label,
    required this.selected,
    required this.onTap,
    required this.currencyCode,
    required this.localeStr,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? preset.color : Colors.transparent,
            width: 2,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: preset.color.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(preset.icon, color: preset.color, size: 22),
            ),
            const SizedBox(height: 6),
            Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 14,
              ),
            ),
            Text(
              formatCurrencyRounded(preset.amount, currencyCode,
                  locale: localeStr),
              style: const TextStyle(color: Colors.black54, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}
