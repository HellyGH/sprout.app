import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/budget_api.dart';
import '../../l10n/app_localizations.dart';
import '../../state/budget_controller.dart';

class LoginForm extends StatefulWidget {
  const LoginForm({super.key});

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _passwordFocus = FocusNode();
  bool _submitting = false;
  AuthError? _serverError;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
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
      await context.read<BudgetController>().login(
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
            label: l.authFieldEmail,
            controller: _email,
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
            autofill: const [AutofillHints.password],
            textInputAction: TextInputAction.done,
            onFieldSubmitted: (_) => _submit(),
            validator: (v) =>
                (v == null || v.isEmpty) ? l.authPasswordRequired : null,
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
                    l.authLogIn,
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
