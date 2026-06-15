import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../l10n/app_localizations.dart';
import '../models/partnership.dart';
import '../state/budget_controller.dart';
import '../utils/formatters.dart';
import 'partner_common.dart';
import 'unlink_resolution_sheet.dart';

/// Панелът "Свържи партньор" на екрана "Ти". Показва едно от четири състояния
/// (сам / изходяща покана / входяща покана / свързан) и управлява целия поток
/// за покана и прекъсване на връзката.
class PartnerPanel extends StatefulWidget {
  const PartnerPanel({super.key});

  @override
  State<PartnerPanel> createState() => _PartnerPanelState();
}

class _PartnerPanelState extends State<PartnerPanel> {
  final _email = TextEditingController();
  bool _busy = false;
  String _lastInvited = '';

  @override
  void dispose() {
    _email.dispose();
    super.dispose();
  }

  void _toast(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _invite() async {
    final l = AppLocalizations.of(context);
    final email = _email.text.trim();
    if (email.isEmpty) return;
    setState(() => _busy = true);
    final controller = context.read<BudgetController>();
    try {
      _lastInvited = email;
      await controller.invitePartner(email);
      if (!mounted) return;
      if (controller.isPartnered) {
        _toast(l.partnerInviteAccepted);
      } else {
        _email.clear();
        _toast(l.partnerInviteOnItsWay(email));
      }
    } catch (e) {
      if (mounted) _toast(partnerErrorMessage(l, e));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _cancel() async {
    final l = AppLocalizations.of(context);
    setState(() => _busy = true);
    try {
      await context.read<BudgetController>().cancelInvite();
      if (mounted) _toast(l.partnerInviteCancelled);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _accept() async {
    final l = AppLocalizations.of(context);
    setState(() => _busy = true);
    try {
      await context.read<BudgetController>().acceptPartnership();
      if (mounted) _toast(l.partnerInviteAccepted);
    } catch (e) {
      if (mounted) _toast(partnerErrorMessage(l, e));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _decline(String inviterName) async {
    final l = AppLocalizations.of(context);
    setState(() => _busy = true);
    try {
      await context.read<BudgetController>().declinePartnership();
      if (mounted) _toast(l.partnerInviteDeclined(inviterName));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _unlink() async {
    final l = AppLocalizations.of(context);
    final confirmed = await showUnlinkResolutionSheet(context);
    if (confirmed == true && mounted) _toast(l.partnerUnlinkDone);
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final localeStr = Localizations.localeOf(context).languageCode;
    final budget = context.watch<BudgetController>();
    final status = budget.partnershipStatus;

    final Widget body = switch (status) {
      PartnershipStatus.linked => _linked(l, localeStr, budget),
      PartnershipStatus.pendingInbound => _inbound(l, budget),
      PartnershipStatus.pendingOutbound => _outbound(l),
      PartnershipStatus.none => _solo(l),
    };

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.favorite_rounded,
                color: Theme.of(context).colorScheme.primary,
                size: 20,
              ),
              const SizedBox(width: 12),
              Text(
                l.partnerSectionTitle,
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          body,
        ],
      ),
    );
  }

  Widget _solo(AppLocalizations l) {
    final accent = Theme.of(context).colorScheme.primary;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l.partnerSoloPrompt,
          style: const TextStyle(color: Colors.black54, fontSize: 13),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _email,
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.done,
          onSubmitted: (_) => _invite(),
          decoration: InputDecoration(
            hintText: l.partnerEmailHint,
            filled: true,
            fillColor: const Color(0xFFEDF1F5),
            isDense: true,
            prefixIcon: const Icon(Icons.mail_outline_rounded,
                color: Colors.black45),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 4, vertical: 14),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide.none,
            ),
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          width: double.infinity,
          child: FilledButton(
            onPressed: _busy ? null : _invite,
            style: FilledButton.styleFrom(
              backgroundColor: accent,
              minimumSize: const Size.fromHeight(46),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
            ),
            child: _busy
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: Colors.white),
                  )
                : Text(l.partnerInviteCta),
          ),
        ),
      ],
    );
  }

  Widget _outbound(AppLocalizations l) {
    final email = _lastInvited.isEmpty ? '…' : _lastInvited;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l.partnerPendingOutbound(email),
          style: const TextStyle(fontSize: 14),
        ),
        const SizedBox(height: 8),
        TextButton(
          onPressed: _busy ? null : _cancel,
          style: TextButton.styleFrom(padding: EdgeInsets.zero),
          child: Text(l.partnerCancelInvite),
        ),
      ],
    );
  }

  Widget _inbound(AppLocalizations l, BudgetController budget) {
    final name = budget.pendingInvite?.inviterName ?? '';
    final accent = Theme.of(context).colorScheme.primary;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l.partnerInviteReceived(name),
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: FilledButton(
                onPressed: _busy ? null : _accept,
                style: FilledButton.styleFrom(
                  backgroundColor: accent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                ),
                child: Text(l.partnerAcceptYes),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: OutlinedButton(
                onPressed: _busy ? null : () => _decline(name),
                style: OutlinedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                ),
                child: Text(l.partnerAcceptNo),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _linked(
    AppLocalizations l,
    String localeStr,
    BudgetController budget,
  ) {
    final name = budget.partner?.name ?? '';
    final since = budget.user?.linkedAt;
    final dateStr =
        since == null ? '' : formatLongDate(since, locale: localeStr);
    final accent = Theme.of(context).colorScheme.primary;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            PartnerAvatar(name: name, color: accent),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                l.partnerLinkedSince(name, dateStr),
                style: const TextStyle(fontSize: 14),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        TextButton.icon(
          onPressed: _busy ? null : _unlink,
          style: TextButton.styleFrom(
            foregroundColor: const Color(0xFFFF6B6B),
            padding: EdgeInsets.zero,
          ),
          icon: const Icon(Icons.link_off_rounded, size: 18),
          label: Text(l.partnerUnlink),
        ),
      ],
    );
  }
}
