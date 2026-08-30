import 'package:flutter/material.dart';

import '../../core/l10n/app_texts.dart';
import '../../core/momento_controller.dart';
import '../../core/theme/momento_colors.dart';
import '../../core/theme/momento_theme.dart';
import '../../data/repositories/auth_repository.dart';
import '../../widgets/common.dart';
import '../../widgets/momento_logo.dart';

/// Anmelden und Registrieren - im Businessplan sind dafuer E-Mail und
/// Passwort vorgesehen.
class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _passwordRepeat = TextEditingController();

  bool _registerMode = false;
  bool _busy = false;
  bool _obscure = true;
  String? _serverError;

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _password.dispose();
    _passwordRepeat.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final t = AppTexts.of(context);
    setState(() => _serverError = null);
    if (!_formKey.currentState!.validate()) return;

    setState(() => _busy = true);
    final controller = AppScope.read(context);
    try {
      if (_registerMode) {
        await controller.register(
          email: _email.text,
          password: _password.text,
          displayName: _name.text,
        );
      } else {
        await controller.signIn(
          email: _email.text,
          password: _password.text,
        );
      }
    } on AuthException catch (error) {
      if (!mounted) return;
      setState(() {
        _serverError = switch (error.error) {
          AuthError.emailTaken => t.errorEmailTaken,
          AuthError.wrongCredentials => t.errorWrongCredentials,
        };
      });
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = AppTexts.of(context);
    final theme = Theme.of(context);

    return Scaffold(
      body: Stack(
        children: [
          // Farbverlauf-Kopf wie auf der Startseite im Konzeptbild. Nach unten
          // blendet er weich in den Hintergrund, damit keine Kante entsteht.
          SizedBox(
            height: MediaQuery.sizeOf(context).height * 0.46,
            width: double.infinity,
            child: Stack(
              fit: StackFit.expand,
              children: [
                const DecoratedBox(
                  decoration: BoxDecoration(gradient: MomentoGradients.header),
                ),
                DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        theme.scaffoldBackgroundColor.withValues(alpha: 0),
                        theme.scaffoldBackgroundColor.withValues(alpha: 0),
                        theme.scaffoldBackgroundColor,
                      ],
                      stops: const [0.0, 0.52, 1.0],
                    ),
                  ),
                ),
              ],
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 30, 20, 32),
              child: Column(
                children: [
                  MomentoWordmark(height: 74, tint: Colors.white),
                  const SizedBox(height: 10),
                  Text(
                    t.vision,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: Colors.white.withValues(alpha: 0.95),
                    ),
                  ),
                  const SizedBox(height: 30),
                  SoftCard(
                    padding: const EdgeInsets.fromLTRB(20, 22, 20, 24),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _ModeSwitch(
                            registerMode: _registerMode,
                            onChanged: (value) => setState(() {
                              _registerMode = value;
                              _serverError = null;
                              _formKey.currentState?.reset();
                            }),
                          ),
                          const SizedBox(height: 22),
                          Text(
                            _registerMode ? t.createAccount : t.greetingBack,
                            style: theme.textTheme.headlineSmall,
                          ),
                          const SizedBox(height: 16),
                          if (_registerMode) ...[
                            TextFormField(
                              controller: _name,
                              textInputAction: TextInputAction.next,
                              textCapitalization: TextCapitalization.words,
                              decoration: InputDecoration(
                                labelText: t.displayName,
                                hintText: t.displayNameHint,
                                prefixIcon: const Icon(Icons.person_outline_rounded),
                              ),
                              validator: (value) =>
                                  (value == null || value.trim().isEmpty)
                                      ? t.errorNameRequired
                                      : null,
                            ),
                            const SizedBox(height: 14),
                          ],
                          TextFormField(
                            controller: _email,
                            keyboardType: TextInputType.emailAddress,
                            textInputAction: TextInputAction.next,
                            autocorrect: false,
                            decoration: InputDecoration(
                              labelText: t.email,
                              prefixIcon: const Icon(Icons.alternate_email_rounded),
                            ),
                            validator: (value) {
                              final text = value?.trim() ?? '';
                              final valid = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$')
                                  .hasMatch(text);
                              return valid ? null : t.errorEmailInvalid;
                            },
                          ),
                          const SizedBox(height: 14),
                          TextFormField(
                            controller: _password,
                            obscureText: _obscure,
                            textInputAction: _registerMode
                                ? TextInputAction.next
                                : TextInputAction.done,
                            decoration: InputDecoration(
                              labelText: t.password,
                              prefixIcon: const Icon(Icons.lock_outline_rounded),
                              suffixIcon: IconButton(
                                onPressed: () =>
                                    setState(() => _obscure = !_obscure),
                                icon: Icon(_obscure
                                    ? Icons.visibility_outlined
                                    : Icons.visibility_off_outlined),
                              ),
                            ),
                            validator: (value) => (value ?? '').length < 6
                                ? t.errorPasswordShort
                                : null,
                            onFieldSubmitted: (_) {
                              if (!_registerMode) _submit();
                            },
                          ),
                          if (_registerMode) ...[
                            const SizedBox(height: 14),
                            TextFormField(
                              controller: _passwordRepeat,
                              obscureText: _obscure,
                              textInputAction: TextInputAction.done,
                              decoration: InputDecoration(
                                labelText: t.passwordRepeat,
                                prefixIcon: const Icon(Icons.lock_outline_rounded),
                              ),
                              validator: (value) => value == _password.text
                                  ? null
                                  : t.errorPasswordsDiffer,
                              onFieldSubmitted: (_) => _submit(),
                            ),
                          ],
                          if (_serverError != null) ...[
                            const SizedBox(height: 14),
                            _ErrorNote(message: _serverError!),
                          ],
                          const SizedBox(height: 22),
                          GradientButton(
                            label: _registerMode ? t.signUp : t.signIn,
                            busy: _busy,
                            onPressed: _submit,
                          ),
                          const SizedBox(height: 12),
                          TextButton(
                            onPressed: () => setState(() {
                              _registerMode = !_registerMode;
                              _serverError = null;
                            }),
                            child: Text(_registerMode
                                ? t.alreadyHaveAccount
                                : t.noAccountYet),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.lock_person_outlined,
                          size: 17, color: theme.colorScheme.onSurfaceVariant),
                      const SizedBox(width: 9),
                      Expanded(
                        child: Text(
                          t.privacyNote,
                          style: theme.textTheme.bodySmall,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ModeSwitch extends StatelessWidget {
  const _ModeSwitch({required this.registerMode, required this.onChanged});

  final bool registerMode;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final t = AppTexts.of(context);
    final theme = Theme.of(context);

    Widget tab(String label, bool isRegister) {
      final selected = registerMode == isRegister;
      return Expanded(
        child: GestureDetector(
          onTap: () => onChanged(isRegister),
          behavior: HitTestBehavior.opaque,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 240),
            curve: Curves.easeOut,
            padding: const EdgeInsets.symmetric(vertical: 11),
            decoration: BoxDecoration(
              gradient: selected ? MomentoGradients.action : null,
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              label,
              textAlign: TextAlign.center,
              style: theme.textTheme.labelLarge?.copyWith(
                color: selected ? Colors.white : theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(children: [tab(t.signIn, false), tab(t.signUp, true)]),
    );
  }
}

class _ErrorNote extends StatelessWidget {
  const _ErrorNote({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: theme.colorScheme.errorContainer,
        borderRadius: BorderRadius.circular(MomentoRadii.tile),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline_rounded,
              size: 19, color: MomentoColors.danger),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onErrorContainer,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
