import 'package:flutter/material.dart';

import '../../../core/theme/theme_context.dart';
import '../../../core/theme/theme_model.dart';

enum ThemedButtonVariant { primary, outline }

/// Bouton principal de l'app, adapté au thème actif.
/// Animation press : scale 0.95.
class ThemedButton extends StatefulWidget {
  final String label;
  final VoidCallback? onPressed;
  final ThemedButtonVariant variant;
  final IconData? icon;
  final bool expanded;

  const ThemedButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.variant = ThemedButtonVariant.primary,
    this.icon,
    this.expanded = false,
  });

  @override
  State<ThemedButton> createState() => _ThemedButtonState();
}

class _ThemedButtonState extends State<ThemedButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final type = context.appThemeType;
    final colors = context.appColors;
    final typography = context.appTypography;
    final isPrimary = widget.variant == ThemedButtonVariant.primary;
    final enabled = widget.onPressed != null;

    Gradient? gradient;
    Color? borderColor;
    List<BoxShadow> shadows = const [];
    Color labelColor;

    switch (type) {
      case AppThemeType.futuriste:
        gradient = isPrimary
            ? LinearGradient(colors: [colors.primary, colors.secondary])
            : null;
        borderColor = isPrimary ? null : colors.primary;
        labelColor = isPrimary ? colors.background : colors.primary;
        if (isPrimary && enabled) {
          shadows = [
            BoxShadow(
              color: colors.primary.withValues(alpha: 0.45),
              blurRadius: 16,
              spreadRadius: 1,
            ),
          ];
        }
      case AppThemeType.ancien:
        gradient = isPrimary
            ? LinearGradient(
                colors: [colors.primary, colors.secondary],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              )
            : null;
        borderColor = colors.primary;
        labelColor = isPrimary ? const Color(0xFF241206) : colors.primary;
        if (isPrimary && enabled) {
          shadows = [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.5),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ];
        }
      case AppThemeType.cosmos:
        gradient = isPrimary
            ? LinearGradient(colors: [colors.primary, colors.accent])
            : null;
        borderColor = isPrimary ? null : colors.primary;
        labelColor = isPrimary ? colors.background : colors.primary;
        if (isPrimary && enabled) {
          shadows = [
            BoxShadow(
              color: colors.primary.withValues(alpha: 0.35),
              blurRadius: 14,
            ),
          ];
        }
    }

    final content = Row(
      mainAxisSize: widget.expanded ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (widget.icon != null) ...[
          Icon(widget.icon, size: 20, color: labelColor),
          const SizedBox(width: 8),
        ],
        Flexible(
          child: Text(
            widget.label,
            overflow: TextOverflow.ellipsis,
            style: typography.labelLarge.copyWith(color: labelColor),
          ),
        ),
      ],
    );

    return GestureDetector(
      onTapDown: enabled ? (_) => setState(() => _pressed = true) : null,
      onTapUp: enabled ? (_) => setState(() => _pressed = false) : null,
      onTapCancel: enabled ? () => setState(() => _pressed = false) : null,
      onTap: widget.onPressed,
      child: AnimatedScale(
        scale: _pressed ? 0.95 : 1.0,
        duration: const Duration(milliseconds: 100),
        child: Opacity(
          opacity: enabled ? 1 : 0.5,
          child: Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            decoration: BoxDecoration(
              gradient: gradient,
              borderRadius: BorderRadius.circular(
                type == AppThemeType.ancien ? 8 : 14,
              ),
              border: borderColor != null
                  ? Border.all(color: borderColor, width: 1.5)
                  : null,
              boxShadow: shadows,
            ),
            child: content,
          ),
        ),
      ),
    );
  }
}

/// Bouton icône circulaire adapté au thème.
class ThemedIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final String? tooltip;

  const ThemedIconButton({
    super.key,
    required this.icon,
    required this.onPressed,
    this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final button = Material(
      color: colors.surface.withValues(alpha: 0.7),
      shape: CircleBorder(
        side: BorderSide(color: colors.primary.withValues(alpha: 0.5)),
      ),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onPressed,
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Icon(icon, size: 22, color: colors.primary),
        ),
      ),
    );
    if (tooltip == null) return button;
    return Tooltip(message: tooltip!, child: button);
  }
}
