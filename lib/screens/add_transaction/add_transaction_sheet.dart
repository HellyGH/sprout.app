import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../l10n/app_localizations.dart';
import '../../models/category.dart' as model;
import '../../models/transaction.dart';
import '../../state/budget_controller.dart';
import '../../utils/formatters.dart';
import '../../widgets/add_category_sheet.dart';
import '../../widgets/milestone_celebration.dart';
import 'cooldown_screen.dart';

Future<void> showAddTransactionSheet(
  BuildContext context, {
  String? presetCategoryId,
  Transaction? editing,
}) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _AddTransactionSheet(
      presetCategoryId: presetCategoryId,
      editing: editing,
    ),
  );
}

class _AddTransactionSheet extends StatefulWidget {
  final String? presetCategoryId;
  final Transaction? editing;

  const _AddTransactionSheet({this.presetCategoryId, this.editing});

  @override
  State<_AddTransactionSheet> createState() => _AddTransactionSheetState();
}

class _AddTransactionSheetState extends State<_AddTransactionSheet> {
  late String _amount;
  String? _categoryId;
  late final TextEditingController _note;
  int? _mood;
  late bool _isPlanned;
  bool _submitting = false;
  bool _showSuccess = false;

  // Phase 9 shared-transaction state.
  late bool _shareWithPartner;
  late double _partnerSharePercent;
  late bool _paidByMe;

  @override
  void initState() {
    super.initState();
    final tx = widget.editing;
    _amount = tx == null ? '' : _formatAmount(tx.amount);
    _categoryId = tx?.categoryId ?? widget.presetCategoryId;
    _note = TextEditingController(text: tx?.note ?? '');
    _mood = tx?.mood;
    _isPlanned = tx?.isPlanned ?? false;
    _shareWithPartner = tx?.isShared ?? false;
    _partnerSharePercent = tx?.partnerSharePercent ?? 50;
    _paidByMe = tx?.paidByUserId == null
        ? true
        : tx!.paidByUserId == context.read<BudgetController>().user?.id;
  }

  @override
  void dispose() {
    _note.dispose();
    super.dispose();
  }

  String _formatAmount(double v) {
    final s = v.toStringAsFixed(2);
    return s.endsWith('.00') ? s.substring(0, s.length - 3) : s;
  }

  void _onKey(String key) {
    setState(() {
      if (key == '.') {
        if (_amount.isEmpty) _amount = '0';
        if (_amount.contains('.')) return;
        _amount += '.';
      } else {
        if (_amount.contains('.')) {
          final dotIndex = _amount.indexOf('.');
          if (_amount.length - dotIndex > 3) return;
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
    HapticFeedback.selectionClick();
  }

  double get _amountValue => double.tryParse(_amount) ?? 0;

  bool get _canSubmit =>
      !_submitting &&
      _amountValue > 0 &&
      _categoryId != null &&
      _categoryId!.isNotEmpty;

  Future<void> _submit() async {
    if (!_canSubmit) return;
    setState(() => _submitting = true);
    HapticFeedback.mediumImpact();
    try {
      final controller = context.read<BudgetController>();
      final tx = widget.editing;
      if (tx == null) {
        final user = controller.user;
        final shouldCooldown = user != null &&
            user.cooldownEnabled &&
            !_isPlanned &&
            _amountValue >= user.cooldownThreshold;
        if (shouldCooldown) {
          final navigator = Navigator.of(context);
          final proceed = await navigator.push<bool>(
            MaterialPageRoute(
              fullscreenDialog: true,
              builder: (_) => CooldownScreen(
                amount: _amountValue,
                currencyCode: controller.currency.code,
              ),
            ),
          );
          if (proceed != true) {
            if (proceed == false) {
              await controller.recordCooldownWin(_amountValue);
            }
            navigator.pop();
            return;
          }
        }
      }
      BoostResult? roundUpBoost;
      if (tx == null) {
        final shareOn = _shareWithPartner && controller.isPartnered;
        if (shareOn) {
          final paidBy =
              _paidByMe ? controller.user!.id : controller.partner!.id;
          roundUpBoost = await controller.createSharedTransaction(
            amount: _amountValue,
            categoryId: _categoryId!,
            partnerSharePercent: _partnerSharePercent,
            paidByUserId: paidBy,
            note: _note.text.trim().isEmpty ? null : _note.text.trim(),
            mood: _mood,
          );
        } else {
          roundUpBoost = await controller.addTransaction(
            amount: _amountValue,
            categoryId: _categoryId!,
            note: _note.text.trim().isEmpty ? null : _note.text.trim(),
            mood: _mood,
            isPlanned: _isPlanned,
          );
        }
      } else {
        await controller.updateTransaction(
          tx.copyWith(
            amount: _amountValue,
            categoryId: _categoryId!,
            note: _note.text.trim().isEmpty ? null : _note.text.trim(),
            mood: _mood,
            isPlanned: _isPlanned,
          ),
        );
      }
      if (!mounted) return;
      setState(() => _showSuccess = true);
      await Future.delayed(const Duration(milliseconds: 700));
      if (!mounted) return;
      final navigator = Navigator.of(context);
      final parentContext = navigator.context;
      navigator.pop();
      if (roundUpBoost?.milestone != null && parentContext.mounted) {
        await showMilestoneCelebration(
          parentContext,
          goalName: goalDisplayName(
              AppLocalizations.of(parentContext), roundUpBoost!.goal),
          milestone: roundUpBoost.milestone!,
        );
      }
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  List<model.Category> _orderedCategories(BudgetController c) {
    final mostRecent = <String, DateTime>{};
    for (final tx in c.transactions) {
      final prev = mostRecent[tx.categoryId];
      if (prev == null || tx.dateTime.isAfter(prev)) {
        mostRecent[tx.categoryId] = tx.dateTime;
      }
    }
    final list = [...c.categories];
    list.sort((a, b) {
      final aLast = mostRecent[a.id];
      final bLast = mostRecent[b.id];
      if (aLast == null && bLast == null) return 0;
      if (aLast == null) return 1;
      if (bLast == null) return -1;
      return bLast.compareTo(aLast);
    });
    return list;
  }

  @override
  Widget build(BuildContext context) {
    final budget = context.watch<BudgetController>();
    final symbol = currencySymbol(budget.currency.code);
    final categories = _orderedCategories(budget);
    // Sharing is offered only for new transactions when partnered.
    final canShare = widget.editing == null && budget.isPartnered;
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: AnimatedSize(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOut,
        alignment: Alignment.bottomCenter,
        child: Container(
          decoration: const BoxDecoration(
            color: Color(0xFFEDF1F5),
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: _showSuccess
              ? const _SuccessBody()
              : _Body(
                  amount: _amount,
                  symbol: symbol,
                  amountValue: _amountValue,
                  currencyCode: budget.currency.code,
                  categories: categories,
                  selectedCategoryId: _categoryId,
                  note: _note,
                  mood: _mood,
                  isPlanned: _isPlanned,
                  isEditing: widget.editing != null,
                  canShare: canShare,
                  partnerName: budget.partner?.name ?? '',
                  shareWithPartner: _shareWithPartner,
                  partnerSharePercent: _partnerSharePercent,
                  paidByMe: _paidByMe,
                  canSubmit: _canSubmit,
                  submitting: _submitting,
                  onKey: _onKey,
                  onBackspace: _onBackspace,
                  onPickCategory: (id) =>
                      setState(() => _categoryId = id),
                  onAddCategory: () async {
                    await showAddCategorySheet(context);
                  },
                  onPickMood: (m) {
                    HapticFeedback.selectionClick();
                    setState(() => _mood = _mood == m ? null : m);
                  },
                  onTogglePlanned: (v) =>
                      setState(() => _isPlanned = v),
                  onToggleShare: (v) =>
                      setState(() => _shareWithPartner = v),
                  onSplitChanged: (v) =>
                      setState(() => _partnerSharePercent = v),
                  onPaidByChanged: (v) => setState(() => _paidByMe = v),
                  onSubmit: _submit,
                ),
        ),
      ),
    );
  }
}

class _Body extends StatelessWidget {
  final String amount;
  final String symbol;
  final double amountValue;
  final String currencyCode;
  final List<model.Category> categories;
  final String? selectedCategoryId;
  final TextEditingController note;
  final int? mood;
  final bool isPlanned;
  final bool isEditing;
  final bool canShare;
  final String partnerName;
  final bool shareWithPartner;
  final double partnerSharePercent;
  final bool paidByMe;
  final bool canSubmit;
  final bool submitting;
  final ValueChanged<String> onKey;
  final VoidCallback onBackspace;
  final ValueChanged<String> onPickCategory;
  final VoidCallback onAddCategory;
  final ValueChanged<int> onPickMood;
  final ValueChanged<bool> onTogglePlanned;
  final ValueChanged<bool> onToggleShare;
  final ValueChanged<double> onSplitChanged;
  final ValueChanged<bool> onPaidByChanged;
  final VoidCallback onSubmit;

  const _Body({
    required this.amount,
    required this.symbol,
    required this.amountValue,
    required this.currencyCode,
    required this.categories,
    required this.selectedCategoryId,
    required this.note,
    required this.mood,
    required this.isPlanned,
    required this.isEditing,
    required this.canShare,
    required this.partnerName,
    required this.shareWithPartner,
    required this.partnerSharePercent,
    required this.paidByMe,
    required this.canSubmit,
    required this.submitting,
    required this.onKey,
    required this.onBackspace,
    required this.onPickCategory,
    required this.onAddCategory,
    required this.onPickMood,
    required this.onTogglePlanned,
    required this.onToggleShare,
    required this.onSplitChanged,
    required this.onPaidByChanged,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 22),
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
          const SizedBox(height: 12),
          Center(
            child: Text(
              isEditing ? l.addTxEditTitle : l.addTxLogSpend,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(height: 14),

          Center(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 140),
              transitionBuilder: (child, anim) => FadeTransition(
                opacity: anim,
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0, 0.2),
                    end: Offset.zero,
                  ).animate(anim),
                  child: child,
                ),
              ),
              child: Text(
                '$symbol${amount.isEmpty ? '0' : amount}',
                key: ValueKey(amount),
                style: const TextStyle(
                  fontSize: 52,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -1.5,
                ),
              ),
            ),
          ),
          const SizedBox(height: 6),

          _Keypad(onKey: onKey, onBackspace: onBackspace),
          const SizedBox(height: 14),

          Text(
            l.addTxCategory,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.black54,
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 44,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: categories.length + 1,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, i) {
                if (i == categories.length) {
                  return _NewCategoryChip(onTap: onAddCategory);
                }
                final cat = categories[i];
                return _CategoryChip(
                  category: cat,
                  selected: cat.id == selectedCategoryId,
                  onTap: () => onPickCategory(cat.id),
                );
              },
            ),
          ),
          const SizedBox(height: 16),

          TextField(
            controller: note,
            maxLines: 1,
            textInputAction: TextInputAction.done,
            decoration: InputDecoration(
              hintText: l.addTxNoteHint,
              filled: true,
              fillColor: Colors.white,
              isDense: true,
              prefixIcon: const Icon(
                Icons.edit_note_rounded,
                color: Colors.black45,
              ),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 4, vertical: 14),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 16),

          Text(
            l.addTxMoodPrompt,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.black54,
            ),
          ),
          const SizedBox(height: 6),
          _MoodPicker(value: mood, onChanged: onPickMood),
          const SizedBox(height: 14),

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.refresh_rounded,
                  size: 20,
                  color: Colors.black54,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    l.addTxRepeatMonthly,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
                Switch.adaptive(
                  value: isPlanned,
                  onChanged: onTogglePlanned,
                  activeThumbColor: Theme.of(context).colorScheme.primary,
                ),
              ],
            ),
          ),
          if (canShare) ...[
            const SizedBox(height: 10),
            _SharePanel(
              partnerName: partnerName,
              shareWithPartner: shareWithPartner,
              partnerSharePercent: partnerSharePercent,
              paidByMe: paidByMe,
              amountValue: amountValue,
              currencyCode: currencyCode,
              onToggleShare: onToggleShare,
              onSplitChanged: onSplitChanged,
              onPaidByChanged: onPaidByChanged,
            ),
          ],
          const SizedBox(height: 18),

          FilledButton(
            onPressed: canSubmit ? onSubmit : null,
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primary,
              minimumSize: const Size.fromHeight(52),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(28),
              ),
            ),
            child: submitting
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : Text(
                    isEditing ? l.commonSave : l.addTxSubmitNew,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

/// Панел за споделена транзакция: превключвател "сподели с партньор", който
/// разкрива плъзгач за разделяне (стъпки от 5%), селектор "платено от" и
/// помощен текст на живо, показващ колко вижда партньорът в своята сума.
class _SharePanel extends StatelessWidget {
  final String partnerName;
  final bool shareWithPartner;
  final double partnerSharePercent;
  final bool paidByMe;
  final double amountValue;
  final String currencyCode;
  final ValueChanged<bool> onToggleShare;
  final ValueChanged<double> onSplitChanged;
  final ValueChanged<bool> onPaidByChanged;

  const _SharePanel({
    required this.partnerName,
    required this.shareWithPartner,
    required this.partnerSharePercent,
    required this.paidByMe,
    required this.amountValue,
    required this.currencyCode,
    required this.onToggleShare,
    required this.onSplitChanged,
    required this.onPaidByChanged,
  });

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final localeStr = Localizations.localeOf(context).languageCode;
    final accent = Theme.of(context).colorScheme.primary;
    final partnerSees = amountValue * partnerSharePercent / 100;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(Icons.favorite_rounded, size: 20, color: accent),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  l.addTxShareWithPartner,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
              Switch.adaptive(
                value: shareWithPartner,
                onChanged: onToggleShare,
                activeThumbColor: accent,
              ),
            ],
          ),
          AnimatedSize(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOut,
            alignment: Alignment.topCenter,
            child: shareWithPartner
                ? Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              l.addTxSplitLabel,
                              style: const TextStyle(
                                color: Colors.black54,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              '${partnerSharePercent.round()}%',
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                        SliderTheme(
                          data: SliderTheme.of(context).copyWith(
                            activeTrackColor: accent,
                            thumbColor: accent,
                            inactiveTrackColor:
                                accent.withValues(alpha: 0.18),
                            overlayColor: accent.withValues(alpha: 0.15),
                          ),
                          child: Slider(
                            min: 0,
                            max: 100,
                            divisions: 20,
                            value: partnerSharePercent.clamp(0, 100),
                            onChanged: onSplitChanged,
                          ),
                        ),
                        Text(
                          l.addTxPartnerSees(
                            formatCurrency(partnerSees, currencyCode,
                                locale: localeStr),
                          ),
                          style: const TextStyle(
                            color: Colors.black54,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Text(
                              '${l.addTxPaidBy}:',
                              style: const TextStyle(
                                color: Colors.black54,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: _PaidBySegment(
                                meLabel: l.addTxPaidByMe,
                                partnerLabel: partnerName,
                                paidByMe: paidByMe,
                                onChanged: onPaidByChanged,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}

class _PaidBySegment extends StatelessWidget {
  final String meLabel;
  final String partnerLabel;
  final bool paidByMe;
  final ValueChanged<bool> onChanged;

  const _PaidBySegment({
    required this.meLabel,
    required this.partnerLabel,
    required this.paidByMe,
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
              height: 38,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: selected ? accent : const Color(0xFFEDF1F5),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                label,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: selected ? Colors.white : Colors.black87,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ),
          ),
        );
    return Row(
      children: [
        seg(meLabel, paidByMe, () => onChanged(true)),
        const SizedBox(width: 6),
        seg(partnerLabel, !paidByMe, () => onChanged(false)),
      ],
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
        curve: Curves.easeOut,
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

class _CategoryChip extends StatelessWidget {
  final model.Category category;
  final bool selected;
  final VoidCallback onTap;

  const _CategoryChip({
    required this.category,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 140),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? category.color : Colors.white,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: selected ? category.color : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              category.icon,
              size: 18,
              color: selected ? Colors.white : category.color,
            ),
            const SizedBox(width: 6),
            Text(
              categoryDisplayName(l, category),
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: selected ? Colors.white : Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NewCategoryChip extends StatelessWidget {
  final VoidCallback onTap;
  const _NewCategoryChip({required this.onTap});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final accent = Theme.of(context).colorScheme.primary;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: accent.withValues(alpha: 0.4),
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.add_rounded, size: 18, color: accent),
            const SizedBox(width: 4),
            Text(
              l.commonNew,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: accent,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MoodPicker extends StatelessWidget {
  final int? value;
  final ValueChanged<int> onChanged;

  const _MoodPicker({required this.value, required this.onChanged});

  static const _emojis = ['😩', '😟', '😐', '😊', '😄'];

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (int i = 0; i < _emojis.length; i++)
          Expanded(
            child: GestureDetector(
              onTap: () => onChanged(i + 1),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 140),
                margin: const EdgeInsets.symmetric(horizontal: 3),
                height: 48,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: value == i + 1
                      ? Theme.of(context)
                          .colorScheme
                          .primary
                          .withValues(alpha: 0.15)
                      : Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: value == i + 1
                        ? Theme.of(context).colorScheme.primary
                        : Colors.transparent,
                    width: 1.5,
                  ),
                ),
                child: Text(
                  _emojis[i],
                  style: const TextStyle(fontSize: 22),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _SuccessBody extends StatelessWidget {
  const _SuccessBody();

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 32, 20, 40),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.black12,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(height: 18),
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.6, end: 1.0),
            duration: const Duration(milliseconds: 300),
            curve: Curves.elasticOut,
            builder: (context, value, _) => Transform.scale(
              scale: value,
              child: const Text('🌱', style: TextStyle(fontSize: 56)),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            l.addTxLogged,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: Color(0xFF3FBF7F),
            ),
          ),
        ],
      ),
    );
  }
}
