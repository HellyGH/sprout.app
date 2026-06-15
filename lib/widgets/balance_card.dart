import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../models/currency.dart';
import '../utils/formatters.dart';

class BalanceCard extends StatelessWidget {
  final double remaining;
  final double monthlyBudget;
  final Currency currency;
  final bool isOverBudget;
  final VoidCallback onLogSpend;
  final VoidCallback onTopUp;
  final ValueChanged<Currency> onSelectCurrency;

  const BalanceCard({
    super.key,
    required this.remaining,
    required this.monthlyBudget,
    required this.currency,
    required this.isOverBudget,
    required this.onLogSpend,
    required this.onTopUp,
    required this.onSelectCurrency,
  });

  static const _normalGradient = LinearGradient(
    colors: [
      Color.fromARGB(255, 39, 101, 207),
      Color.fromARGB(255, 99, 60, 165),
    ],
    begin: Alignment.centerLeft,
    end: Alignment.bottomRight,
  );

  static const _alertGradient = LinearGradient(
    colors: [Color.fromARGB(255, 42, 108, 222), Color(0xFFFF6B6B)],
    begin: Alignment.centerLeft,
    end: Alignment.bottomRight,
  );

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final localeStr = Localizations.localeOf(context).languageCode;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOutCubic,
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: isOverBudget ? _alertGradient : _normalGradient,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                l.homeRemainingThisMonth,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.2,
                ),
              ),
              _CurrencySelector(
                currency: currency,
                onSelected: onSelectCurrency,
              ),
            ],
          ),
          const SizedBox(height: 8),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 250),
            switchInCurve: Curves.easeOutCubic,
            switchOutCurve: Curves.easeInCubic,
            transitionBuilder: (child, anim) =>
                FadeTransition(opacity: anim, child: child),
            child: TweenAnimationBuilder<double>(
              key: ValueKey(currency),
              tween: Tween(begin: remaining, end: remaining),
              duration: const Duration(milliseconds: 350),
              curve: Curves.easeOutCubic,
              builder: (context, value, _) => Text(
                formatCurrency(value, currency.code, locale: localeStr),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 30,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.5,
                ),
              ),
            ),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Expanded(
                child: Text(
                  l.homeOfMonthly(
                    formatCurrencyRounded(monthlyBudget, currency.code,
                        locale: localeStr),
                  ),
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: onTopUp,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.add_rounded,
                          color: Colors.white, size: 16),
                      const SizedBox(width: 4),
                      Text(
                        l.homeTopUp,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          _PressableButton(
            onPressed: onLogSpend,
            child: Text(
              l.homeLogSpend,
              style: const TextStyle(
                color: Color(0xFF2765CF),
                fontWeight: FontWeight.w700,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CurrencySelector extends StatelessWidget {
  final Currency currency;
  final ValueChanged<Currency> onSelected;

  const _CurrencySelector({required this.currency, required this.onSelected});

  Future<void> _showSheet(BuildContext context) async {
    final l = AppLocalizations.of(context);
    final picked = await showCupertinoModalPopup<Currency>(
      context: context,
      builder: (sheetContext) => CupertinoActionSheet(
        title: Text(l.homeSelectCurrency),
        actions: [
          for (final c in Currency.values)
            CupertinoActionSheetAction(
              onPressed: () => Navigator.pop(sheetContext, c),
              isDefaultAction: c == currency,
              child: Text(c.code),
            ),
        ],
        cancelButton: CupertinoActionSheetAction(
          onPressed: () => Navigator.pop(sheetContext),
          isDestructiveAction: true,
          child: Text(l.commonCancel),
        ),
      ),
    );
    if (picked != null) onSelected(picked);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => _showSheet(context),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.18),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              currency.code,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
            const Icon(Icons.expand_more_rounded, color: Colors.white, size: 18),
          ],
        ),
      ),
    );
  }
}

class _PressableButton extends StatefulWidget {
  final VoidCallback onPressed;
  final Widget child;

  const _PressableButton({required this.onPressed, required this.child});

  @override
  State<_PressableButton> createState() => _PressableButtonState();
}

class _PressableButtonState extends State<_PressableButton> {
  bool _down = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _down = true),
      onTapCancel: () => setState(() => _down = false),
      onTapUp: (_) => setState(() => _down = false),
      onTap: widget.onPressed,
      child: AnimatedScale(
        scale: _down ? 0.96 : 1.0,
        duration: const Duration(milliseconds: 100),
        curve: Curves.easeOut,
        child: Container(
          width: double.infinity,
          height: 46,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(23),
          ),
          child: widget.child,
        ),
      ),
    );
  }
}
