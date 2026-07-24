import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/theme_context.dart';
import '../shared/components/themed_background.dart';
import '../shared/components/themed_button.dart';
import '../shared/components/themed_card.dart';

const _avatarChoices = [
  '🎮', '🎲', '🕹️', '👾', '🤖', '🦊', '🐼', '🐸',
  '🦁', '🐯', '🐙', '🦄', '🚀', '⭐', '🔥', '⚡',
  '🌙', '🎯', '🏆', '💎', '👑', '🎩', '🥷', '🧙',
];

/// Profil (mock) : avatar emoji modifiable, pseudo éditable inline,
/// lien vers les stats et déconnexion.
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String _avatar = '🎮';
  bool _editingPseudo = false;
  late final TextEditingController _pseudoController =
      TextEditingController(text: 'Joueur1');

  @override
  void dispose() {
    _pseudoController.dispose();
    super.dispose();
  }

  void _pickAvatar() {
    showModalBottomSheet<void>(
      context: context,
      builder: (sheetContext) {
        final typography = context.appTypography;
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Choisis ton avatar', style: typography.displayMedium),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 4,
                  runSpacing: 4,
                  children: [
                    for (final emoji in _avatarChoices)
                      InkWell(
                        borderRadius: BorderRadius.circular(12),
                        onTap: () {
                          setState(() => _avatar = emoji);
                          Navigator.of(sheetContext).pop();
                        },
                        child: Container(
                          width: 52,
                          height: 52,
                          alignment: Alignment.center,
                          decoration: emoji == _avatar
                              ? BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: context.appColors.primary,
                                    width: 2,
                                  ),
                                )
                              : null,
                          child: Text(emoji,
                              style: const TextStyle(fontSize: 28)),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final typography = context.appTypography;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil'),
        leading: BackButton(onPressed: () => context.pop()),
      ),
      extendBodyBehindAppBar: true,
      body: ThemedBackground(
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                const SizedBox(height: 12),
                GestureDetector(
                  onTap: _pickAvatar,
                  child: Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(22),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: colors.surface.withValues(alpha: 0.7),
                          border: Border.all(
                            color: colors.primary.withValues(alpha: 0.7),
                            width: 2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color:
                                  colors.primary.withValues(alpha: 0.3),
                              blurRadius: 22,
                            ),
                          ],
                        ),
                        child: Text(
                          _avatar,
                          style: const TextStyle(fontSize: 56),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: colors.primary,
                        ),
                        child: Icon(
                          Icons.edit,
                          size: 16,
                          color: colors.background,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                // Pseudo éditable inline.
                _editingPseudo
                    ? ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 260),
                        child: TextField(
                          controller: _pseudoController,
                          autofocus: true,
                          textAlign: TextAlign.center,
                          style: typography.displayMedium,
                          onSubmitted: (_) =>
                              setState(() => _editingPseudo = false),
                          decoration: InputDecoration(
                            suffixIcon: IconButton(
                              icon: const Icon(Icons.check),
                              onPressed: () =>
                                  setState(() => _editingPseudo = false),
                            ),
                          ),
                        ),
                      )
                    : GestureDetector(
                        onTap: () =>
                            setState(() => _editingPseudo = true),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              _pseudoController.text,
                              style: typography.displayMedium,
                            ),
                            const SizedBox(width: 8),
                            Icon(
                              Icons.edit_outlined,
                              size: 18,
                              color: colors.textSecondary,
                            ),
                          ],
                        ),
                      ),
                const SizedBox(height: 32),
                ThemedCard(
                  onTap: () => context.push('/stats'),
                  child: Row(
                    children: [
                      Icon(Icons.bar_chart, color: colors.primary),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Text(
                          'Mes statistiques',
                          style: typography.bodyLarge,
                        ),
                      ),
                      Icon(Icons.chevron_right, color: colors.primary),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                ThemedButton(
                  label: 'Déconnexion',
                  icon: Icons.logout,
                  variant: ThemedButtonVariant.outline,
                  expanded: true,
                  onPressed: () => context.go('/login'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
