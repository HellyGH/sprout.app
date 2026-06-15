import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../l10n/app_localizations.dart';
import '../../models/goal.dart';
import '../../state/budget_controller.dart';
import '../../utils/formatters.dart';
import 'onboarding_flow.dart';

class _Preset {
  final String Function(AppLocalizations l) labelOf;
  final IconData icon;
  final Color color;
  final double amount;
  const _Preset(this.labelOf, this.icon, this.color, this.amount);
}

final _presets = <_Preset>[
  _Preset(
    (l) => l.onbGoalPresetTokyo,
    Icons.flight_takeoff_rounded,
    const Color(0xFF2765CF),
    1200,
  ),
  _Preset(
    (l) => l.onbGoalPresetMacbook,
    Icons.laptop_mac_rounded,
    const Color(0xFF6B7280),
    1500,
  ),
  _Preset(
    (l) => l.onbGoalPresetEmergency,
    Icons.shield_rounded,
    const Color(0xFF3FBF7F),
    1000,
  ),
  _Preset(
    (l) => l.onbGoalPresetConcert,
    Icons.music_note_rounded,
    const Color(0xFFA78BFA),
    120,
  ),
];

class GoalStep extends StatefulWidget {
  final OnboardingDraft draft;
  final VoidCallback onChanged;

  const GoalStep({
    super.key,
    required this.draft,
    required this.onChanged,
  });

  @override
  State<GoalStep> createState() => _GoalStepState();
}

class _GoalStepState extends State<GoalStep> {
  bool _custom = false;
  final _customName = TextEditingController();
  final _customAmount = TextEditingController();
  DateTime? _customDeadline;

  @override
  void dispose() {
    _customName.dispose();
    _customAmount.dispose();
    super.dispose();
  }

  void _selectPreset(_Preset p, AppLocalizations l) {
    setState(() {
      _custom = false;
      widget.draft.primaryGoal = Goal(
        id: '',
        name: p.labelOf(l),
        icon: p.icon,
        color: p.color,
        targetAmount: p.amount,
      );
    });
    widget.onChanged();
  }

  bool _isSelected(_Preset p, AppLocalizations l) {
    final g = widget.draft.primaryGoal;
    return !_custom &&
        g != null &&
        g.name == p.labelOf(l) &&
        g.targetAmount == p.amount;
  }

  void _enableCustom() {
    setState(() {
      _custom = true;
      widget.draft.primaryGoal = null;
    });
    _syncCustom();
    widget.onChanged();
  }

  void _syncCustom() {
    if (!_custom) return;
    final amount = double.tryParse(_customAmount.text.replaceAll(',', '.'));
    final name = _customName.text.trim();
    if (name.isEmpty || amount == null || amount <= 0) {
      widget.draft.primaryGoal = null;
    } else {
      widget.draft.primaryGoal = Goal(
        id: '',
        name: name,
        icon: Icons.star_rounded,
        color: Colors.deepPurple,
        targetAmount: amount,
        deadline: _customDeadline,
      );
    }
    widget.onChanged();
  }

  Future<void> _pickDeadline() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _customDeadline ?? now.add(const Duration(days: 90)),
      firstDate: now,
      lastDate: now.add(const Duration(days: 365 * 5)),
    );
    if (picked != null) {
      setState(() => _customDeadline = picked);
      _syncCustom();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final localeStr = Localizations.localeOf(context).languageCode;
    final currencyCode =
        context.read<BudgetController>().currency.code;
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),
          Text(
            l.onbGoalTitle,
            style: const TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            l.onbGoalSubtitle,
            style: const TextStyle(color: Colors.black54),
          ),
          const SizedBox(height: 20),
          GridView.count(
            crossAxisCount: 2,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 1.15,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              for (final p in _presets)
                _PresetCard(
                  preset: p,
                  selected: _isSelected(p, l),
                  onTap: () => _selectPreset(p, l),
                  currencyCode: currencyCode,
                  localeStr: localeStr,
                  label: p.labelOf(l),
                ),
            ],
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: _enableCustom,
            icon: Icon(
              _custom ? Icons.edit : Icons.add_rounded,
              size: 18,
            ),
            label: Text(_custom ? l.onbGoalCustom : l.onbGoalCreateOwn),
            style: OutlinedButton.styleFrom(
              foregroundColor: _custom
                  ? Colors.deepPurple
                  : Colors.black87,
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
            const SizedBox(height: 16),
            TextField(
              controller: _customName,
              onChanged: (_) => _syncCustom(),
              decoration: _customDecoration(l.onbGoalNameField),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _customAmount,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              onChanged: (_) => _syncCustom(),
              decoration: _customDecoration(l.onbGoalTargetField),
            ),
            const SizedBox(height: 12),
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
                      _customDeadline == null
                          ? l.onbGoalDeadlineHint
                          : formatLongDate(_customDeadline!, locale: localeStr),
                      style: TextStyle(
                        color: _customDeadline == null
                            ? Colors.black54
                            : Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  InputDecoration _customDecoration(String label) {
    return InputDecoration(
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
}

class _PresetCard extends StatelessWidget {
  final _Preset preset;
  final bool selected;
  final VoidCallback onTap;
  final String currencyCode;
  final String localeStr;
  final String label;

  const _PresetCard({
    required this.preset,
    required this.selected,
    required this.onTap,
    required this.currencyCode,
    required this.localeStr,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? preset.color : Colors.transparent,
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
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
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 15,
              ),
            ),
            Text(
              formatCurrencyRounded(preset.amount, currencyCode,
                  locale: localeStr),
              style: const TextStyle(color: Colors.black54, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }
}
