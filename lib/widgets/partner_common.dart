import 'package:flutter/material.dart';

import '../data/budget_api.dart';
import '../l10n/app_localizations.dart';

/// Initials for a name, e.g. "Alex Chen" → "AC", "Sam" → "S".
String initialsOf(String name) {
  final parts = name.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty);
  if (parts.isEmpty) return '?';
  if (parts.length == 1) return parts.first.characters.first.toUpperCase();
  return (parts.first.characters.first + parts.last.characters.first)
      .toUpperCase();
}

/// A small round initials chip used to attribute shared goals / boosts to a
/// partner. Two of them sit side-by-side on shared goal cards.
class PartnerAvatar extends StatelessWidget {
  final String name;
  final Color color;
  final double size;

  const PartnerAvatar({
    super.key,
    required this.name,
    required this.color,
    this.size = 28,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.18),
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 1.5),
      ),
      child: Text(
        initialsOf(name),
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w700,
          fontSize: size * 0.4,
        ),
      ),
    );
  }
}

/// Maps a thrown partner-flow error to its localized Sprout-voice string.
/// Falls back to a friendly generic line for anything unexpected.
String partnerErrorMessage(AppLocalizations l, Object error) {
  if (error is PartnershipException) {
    return switch (error.code) {
      PartnershipError.alreadyLinked => l.partnerErrAlreadyLinked,
      PartnershipError.targetLinked => l.partnerErrTargetLinked,
      PartnershipError.emailUnknown => l.partnerErrEmailUnknown,
      PartnershipError.inviteExpired => l.partnerErrInviteExpired,
      PartnershipError.notSharedPot => l.partnerErrNotSharedPot,
    };
  }
  return l.partnerErrGeneric;
}
