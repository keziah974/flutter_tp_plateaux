import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/theme_context.dart';
import '../../core/theme/theme_cubit.dart';
import '../../core/theme/theme_model.dart';
import '../shared/components/app_logo.dart';
import '../shared/components/themed_background.dart';
import '../shared/components/themed_button.dart';
import '../shared/components/themed_card.dart';

/// Écran de connexion en mode MOCK : simule un chargement d'une
/// seconde puis navigue vers /home.
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _loading = false;
  bool _obscure = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _signIn() async {
    setState(() => _loading = true);
    // Simuler connexion réussie après 1 seconde.
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
                    const AppLogo(fontSize: 32),
                    const SizedBox(height: 32),
                    ThemedCard(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            'Connexion',
                            textAlign: TextAlign.center,
                            style: typography.displayMedium,
                          ),
                          const SizedBox(height: 24),
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
                                  label: 'Se connecter',
                                  expanded: true,
                                  onPressed: _signIn,
                                ),
                          const SizedBox(height: 12),
                          TextButton(
                            onPressed: _loading
                                ? null
                                : () => context.go('/register'),
                            child: Text(
                              "S'inscrire",
                              style: typography.bodyLarge.copyWith(
                                color: colors.accent,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 28),
                    const ThemeSelector(),
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

/// Sélecteur de thème : 3 icônes cliquables.
class ThemeSelector extends StatelessWidget {
  const ThemeSelector({super.key});

  @override
  Widget build(BuildContext context) {
    final current = context.appThemeType;
    final colors = context.appColors;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (final type in AppThemeType.values)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: GestureDetector(
              onTap: () => context.read<ThemeCubit>().switchTheme(type),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: colors.surface.withValues(
                    alpha: type == current ? 0.9 : 0.4,
                  ),
                  border: Border.all(
                    color: type == current
                        ? colors.primary
                        : colors.primary.withValues(alpha: 0.25),
                    width: type == current ? 2 : 1,
                  ),
                  boxShadow: type == current
                      ? [
                          BoxShadow(
                            color: colors.primary.withValues(alpha: 0.4),
                            blurRadius: 12,
                          ),
                        ]
                      : const [],
                ),
                child: Text(
                  type.emoji,
                  style: const TextStyle(fontSize: 22),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
