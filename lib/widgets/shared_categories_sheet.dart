import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../l10n/app_localizations.dart';
import '../state/budget_controller.dart';
import '../utils/formatters.dart';

/// Manage which of *your* categories are shared with the partner. Each row is
/// a switch bound to the category's `sharedWithPartner` flag — the single
/// place to add or remove a shared category total. The partner's own shared
/// categories are theirs to control and never appear here.
Future<void> showSharedCategoriesSheet(BuildContext context) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => const _SharedCategoriesSheet(),
  );
}

class _SharedCategoriesSheet extends StatelessWidget {
  const _SharedCategoriesSheet();

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final budget = context.watch<BudgetController>();
    final categories = budget.categories;
    final accent = Theme.of(context).colorScheme.primary;
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
            l.sharedCategoriesTitle,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 4),
          Text(
            l.sharedCategoriesSubtitle,
            style: const TextStyle(color: Colors.black54),
          ),
          const SizedBox(height: 16),
          if (categories.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Text(
                l.sharedCategoriesEmpty,
                style: const TextStyle(color: Colors.black54),
              ),
            )
          else
            Flexible(
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: categories.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (_, i) {
                  final c = categories[i];
                  return Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(7),
                          decoration: BoxDecoration(
                            color: c.color.withValues(alpha: 0.15),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(c.icon, color: c.color, size: 16),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            categoryDisplayName(l, c),
                            style:
                                const TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ),
                        Switch.adaptive(
                          value: c.sharedWithPartner,
                          activeThumbColor: accent,
                          onChanged: (_) => context
                              .read<BudgetController>()
                              .toggleCategoryShared(c.id),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: () => Navigator.pop(context),
              style: FilledButton.styleFrom(
                backgroundColor: accent,
                minimumSize: const Size.fromHeight(48),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
              ),
              child: Text(l.commonSave),
            ),
          ),
        ],
      ),
    );
  }
}
