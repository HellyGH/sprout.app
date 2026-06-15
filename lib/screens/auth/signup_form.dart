import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/budget_api.dart';
import '../../l10n/app_localizations.dart';
import '../../state/budget_controller.dart';

class SignupForm extends StatefulWidget {
  const SignupForm({super.key});

  @override
  State<SignupForm> createState() => _SignupFormState();
}

class _SignupFormState extends State<SignupForm> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _emailFocus = FocusNode();
  final _passwordFocus = FocusNode();
  bool _submitting = false;
  AuthError? _serverError;

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _password.dispose();
    _emailFocus.dispose();
    _passwordFocus.dispose();
    super.dispose();
  }

  static final _emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+$');

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    setState(() {
      _submitting = true;
      _serverError = null;
    });
    try {
      await context.read<BudgetController>().signup(
        name: _name.text.trim(),
        email: _email.text.trim(),
        password: _password.text,
      );
    } on AuthException catch (e) {
      if (mounted) setState(() => _serverError = e.code);
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  String _errorText(AppLocalizations l, AuthError e) {
    return switch (e) {
      AuthError.nameRequired => l.authNameRequired,
      AuthError.emailLooksOff => l.authEmailLooksOff,
      AuthError.passwordTooShort => l.authPasswordRuleSignup,
      AuthError.accountExists => l.authAccountExists,
      AuthError.noMatch => l.authNoMatch,
    };
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _LabeledField(
            label: l.authFieldName,
            controller: _name,
            autofill: const [AutofillHints.name],
            textInputAction: TextInputAction.next,
            textCapitalization: TextCapitalization.words,
            onFieldSubmitted: (_) => _emailFocus.requestFocus(),
            validator: (v) =>
                (v == null || v.trim().isEmpty) ? l.authNameRequired : null,
          ),
          const SizedBox(height: 14),
          _LabeledField(
            label: l.authFieldEmail,
            controller: _email,
            focusNode: _emailFocus,
            keyboard: TextInputType.emailAddress,
            autofill: const [AutofillHints.email],
            textInputAction: TextInputAction.next,
            onFieldSubmitted: (_) => _passwordFocus.requestFocus(),
            validator: (v) {
              if (v == null || v.trim().isEmpty) return l.authEmailRequired;
              if (!_emailRegex.hasMatch(v.trim())) {
                return l.authEmailInvalid;
              }
              return null;
            },
          ),
          const SizedBox(height: 14),
          _LabeledField(
            label: l.authFieldPassword,
            controller: _password,
            focusNode: _passwordFocus,
            obscure: true,
            autofill: const [AutofillHints.newPassword],
            textInputAction: TextInputAction.done,
            onFieldSubmitted: (_) => _submit(),
            validator: (v) {
              if (v == null || v.isEmpty) return l.authPasswordRequired;
              if (v.length < 6) return l.authPasswordTooShort;
              return null;
            },
          ),
          if (_serverError != null) ...[
            const SizedBox(height: 12),
            Text(
              _errorText(l, _serverError!),
              style: const TextStyle(color: Color(0xFFFF6B6B), fontSize: 13),
            ),
          ],
          const SizedBox(height: 22),
          FilledButton(
            onPressed: _submitting ? null : _submit,
            style: FilledButton.styleFrom(
              backgroundColor: Colors.deepPurple,
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
                    l.authCreateAccount,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
          ),
        ],
      ),
    );
  }
}

class _LabeledField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final TextInputType? keyboard;
  final bool obscure;
  final String? Function(String?)? validator;
  final List<String>? autofill;
  final FocusNode? focusNode;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onFieldSubmitted;
  final TextCapitalization textCapitalization;

  const _LabeledField({
    required this.label,
    required this.controller,
    this.keyboard,
    this.obscure = false,
    this.validator,
    this.autofill,
    this.focusNode,
    this.textInputAction,
    this.onFieldSubmitted,
    this.textCapitalization = TextCapitalization.none,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Colors.black54,
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          focusNode: focusNode,
          keyboardType: keyboard,
          obscureText: obscure,
          autofillHints: autofill,
          textInputAction: textInputAction,
          textCapitalization: textCapitalization,
          onFieldSubmitted: onFieldSubmitted,
          validator: validator,
          decoration: InputDecoration(
            isDense: true,
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 12,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide.none,
            ),
            errorStyle: const TextStyle(color: Color(0xFFFF6B6B)),
          ),
        ),
      ],
    );
  }
}
