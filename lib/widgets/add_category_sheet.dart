import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../l10n/app_localizations.dart';
import '../models/category.dart' as model;
import '../state/budget_controller.dart';
import '../utils/formatters.dart';

const _iconChoices = <IconData>[
  Icons.restaurant_rounded,
  Icons.local_cafe_rounded,
  Icons.directions_bus_rounded,
  Icons.celebration_rounded,
  Icons.shopping_bag_rounded,
  Icons.fitness_center_rounded,
  Icons.local_gas_station_rounded,
  Icons.movie_rounded,
  Icons.pets_rounded,
  Icons.auto_stories_rounded,
  Icons.health_and_safety_rounded,
  Icons.more_horiz_rounded,
];

const _colorChoices = <Color>[
  Color(0xFF34D399),
  Color(0xFFA67149),
  Color(0xFF60A5FA),
  Color(0xFFA78BFA),
  Color(0xFFF472B6),
  Color(0xFFFFB74D),
  Color(0xFF4DD0E1),
  Color(0xFF9CA3AF),
];

Future<void> showAddCategorySheet(BuildContext context) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => const _AddCategorySheet(),
  );
}

class _AddCategorySheet extends StatefulWidget {
  const _AddCategorySheet();

  @override
  State<_AddCategorySheet> createState() => _AddCategorySheetState();
}

class _AddCategorySheetState extends State<_AddCategorySheet> {
  final _name = TextEditingController();
  IconData _icon = _iconChoices.first;
  Color _color = _colorChoices.first;
  double _cap = 100;
  bool _saving = false;

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  bool get _canSave => _name.text.trim().isNotEmpty && !_saving;

  Future<void> _save() async {
    if (!_canSave) return;
    setState(() => _saving = true);
    try {
      await context.read<BudgetController>().addCategory(
            model.Category(
              id: '',
              name: _name.text.trim(),
              icon: _icon,
              color: _color,
              monthlyCap: _cap,
            ),
          );
      if (mounted) Navigator.pop(context);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final localeStr = Localizations.localeOf(context).languageCode;
    final code = context.read<BudgetController>().currency.code;
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
                l.addCategoryNew,
                style: const TextStyle(
                    fontSize: 18, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _name,
                onChanged: (_) => setState(() {}),
                decoration: InputDecoration(
                  labelText: l.addCategoryName,
                  filled: true,
                  fillColor: Colors.white,
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 14,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Text(
                l.addCategoryIcon,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.black54,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final ic in _iconChoices)
                    GestureDetector(
                      onTap: () => setState(() => _icon = ic),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 160),
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color:
                              _icon == ic ? _color : Colors.white,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: _icon == ic
                                ? _color
                                : Colors.transparent,
                            width: 2,
                          ),
                        ),
                        alignment: Alignment.center,
                        child: Icon(
                          ic,
                          color: _icon == ic
                              ? Colors.white
                              : Colors.black54,
                          size: 20,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 18),
              Text(
                l.addCategoryColor,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.black54,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 10,
                children: [
                  for (final c in _colorChoices)
                    GestureDetector(
                      onTap: () => setState(() => _color = c),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 160),
                        width: 30,
                        height: 30,
                        decoration: BoxDecoration(
                          color: c,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: _color == c
                                ? Colors.black87
                                : Colors.transparent,
                            width: 2.5,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 18),
              Text(
                l.addCategoryMonthlyCap,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.black54,
                ),
              ),
              const SizedBox(height: 6),
              Center(
                child: Text(
                  formatCurrencyRounded(_cap, code, locale: localeStr),
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -1,
                  ),
                ),
              ),
              SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  activeTrackColor: _color,
                  thumbColor: _color,
                  inactiveTrackColor: _color.withValues(alpha: 0.18),
                  overlayColor: _color.withValues(alpha: 0.15),
                ),
                child: Slider(
                  min: 10,
                  max: 800,
                  divisions: 79,
                  value: _cap,
                  onChanged: (v) => setState(() => _cap = v),
                ),
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed:
                          _saving ? null : () => Navigator.pop(context),
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
                      onPressed: _canSave ? _save : null,
                      style: FilledButton.styleFrom(
                        backgroundColor:
                            Theme.of(context).colorScheme.primary,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(28),
                        ),
                      ),
                      child: _saving
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : Text(
                              l.commonAdd,
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
}
