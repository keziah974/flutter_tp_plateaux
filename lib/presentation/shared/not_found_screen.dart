import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/theme_context.dart';
import 'components/themed_background.dart';
import 'components/themed_button.dart';

/// Page 404 / erreur de navigation.
class NotFoundScreen extends StatelessWidget {
  const NotFoundScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final typography = context.appTypography;

    return Scaffold(
      body: ThemedBackground(
        child: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '404',
                    style: typography.displayLarge.copyWith(
                      fontSize: 72,
                      color: colors.primary,
                      shadows: [
                        Shadow(
                          color: colors.primary.withValues(alpha: 0.6),
                          blurRadius: 24,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Cette page a disparu du plateau...',
                    textAlign: TextAlign.center,
                    style: typography.bodyLarge,
                  ),
                  const SizedBox(height: 28),
                  ThemedButton(
                    label: "Retour à l'accueil",
                    icon: Icons.home_outlined,
                    onPressed: () => context.go('/home'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
