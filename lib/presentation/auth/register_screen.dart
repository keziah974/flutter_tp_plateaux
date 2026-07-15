import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/theme_context.dart';
import '../shared/components/app_logo.dart';
import '../shared/components/themed_background.dart';
import '../shared/components/themed_button.dart';
import '../shared/components/themed_card.dart';

/// Écran d'inscription en mode MOCK : simule un chargement d'une
/// seconde puis navigue vers /home.
class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _pseudoController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _loading = false;
  bool _obscure = true;

  @override
  void dispose() {
    _pseudoController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    setState(() => _loading = true);
    // Simuler inscription réussie après 1 seconde.
    await Future.delayed(const Duration(seconds: 1));
    if (!mounted) return;
    context.go('/home');
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final typography = context.appTypography;

    return Scaffold(
      body: ThemedBackground(
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 420),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const AppLogo(fontSize: 28),
                    const SizedBox(height: 28),
                    ThemedCard(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            'Inscription',
                            textAlign: TextAlign.center,
                            style: typography.displayMedium,
                          ),
                          const SizedBox(height: 24),
                          TextField(
                            controller: _pseudoController,
                            style: typography.bodyLarge,
                            decoration: const InputDecoration(
                              labelText: 'Pseudo',
                              prefixIcon: Icon(Icons.person_outline),
                            ),
                          ),
                          const SizedBox(height: 16),
                          TextField(
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            style: typography.bodyLarge,
                            decoration: const InputDecoration(
                              labelText: 'Email',
                              prefixIcon: Icon(Icons.alternate_email),
                            ),
                          ),
                          const SizedBox(height: 16),
                          TextField(
                            controller: _passwordController,
                            obscureText: _obscure,
                            style: typography.bodyLarge,
                            decoration: InputDecoration(
                              labelText: 'Mot de passe',
                              prefixIcon: const Icon(Icons.lock_outline),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscure
                                      ? Icons.visibility_outlined
                                      : Icons.visibility_off_outlined,
                                ),
                                onPressed: () =>
                                    setState(() => _obscure = !_obscure),
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),
                          _loading
                              ? Center(
                                  child: CircularProgressIndicator(
                                    color: colors.primary,
                                  ),
                                )
                              : ThemedButton(
                                  label: "S'inscrire",
                                  expanded: true,
                                  onPressed: _register,
                                ),
                          const SizedBox(height: 12),
                          TextButton(
                            onPressed:
                                _loading ? null : () => context.go('/login'),
                            child: Text(
                              'Déjà un compte ? Se connecter',
                              style: typography.bodyLarge.copyWith(
                                color: colors.accent,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
