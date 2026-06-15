import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../models/category.dart' as model;
import '../utils/formatters.dart';

class CategoryCard extends StatefulWidget {
  final model.Category category;
  final double spent;
  final String currencyCode;
  final VoidCallback? onTap;

  const CategoryCard({
    super.key,
    required this.category,
    required this.spent,
    required this.currencyCode,
    this.onTap,
  });

  @override
  State<CategoryCard> createState() => _CategoryCardState();
}

class _CategoryCardState extends State<CategoryCard> {
  bool _down = false;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final localeStr = Localizations.localeOf(context).languageCode;
    final cap = widget.category.monthlyCap;
    final ratio = cap <= 0 ? 0.0 : (widget.spent / cap).clamp(0.0, 1.0);
    final overCap = widget.spent > cap;
    final progressColor = overCap
        ? const Color(0xFFFF6B6B)
        : ratio > 0.9
            ? Colors.amber.shade700
            : widget.category.color;

    return GestureDetector(
      onTap: widget.onTap,
      onTapDown: (_) => setState(() => _down = true),
      onTapCancel: () => setState(() => _down = false),
      onTapUp: (_) => setState(() => _down = false),
      child: AnimatedScale(
        scale: _down ? 0.97 : 1.0,
        duration: const Duration(milliseconds: 80),
        curve: Curves.easeOut,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          margin: const EdgeInsets.symmetric(vertical: 6),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: widget.category.color,
                  shape: BoxShape.circle,
                ),
                child: Icon(widget.category.icon, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      categoryDisplayName(l, widget.category),
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: LinearProgressIndicator(
                        value: ratio,
                        minHeight: 6,
                        backgroundColor: Colors.grey.shade200,
                        valueColor: AlwaysStoppedAnimation(progressColor),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    formatCurrency(widget.spent, widget.currencyCode,
                        locale: localeStr),
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: overCap
                          ? const Color(0xFFFF6B6B)
                          : Colors.black87,
                    ),
                  ),
                  Text(
                    l.categoryOfCap(
                      formatCurrencyRounded(cap, widget.currencyCode,
                          locale: localeStr),
                    ),
                    style: const TextStyle(
                      fontSize: 11,
                      color: Colors.black45,
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
