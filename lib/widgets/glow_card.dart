import 'package:flutter/material.dart';

import '../core/constants.dart';

/// Surface card with a soft neon glow shadow and 18px+ rounded corners.
class GlowCard extends StatelessWidget {
  const GlowCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(20),
    this.glow = false,
    this.borderColor,
    this.gradient,
    this.onTap,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final bool glow;
  final Color? borderColor;
  final Gradient? gradient;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final BorderRadius radius = BorderRadius.circular(22);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: radius,
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            borderRadius: radius,
            color: gradient == null ? AppColors.card : null,
            gradient: gradient,
            border: Border.all(
              color: borderColor ?? AppColors.border,
            ),
            boxShadow: <BoxShadow>[
              if (glow)
                const BoxShadow(
                  color: AppColors.accentGlow,
                  blurRadius: 28,
                  spreadRadius: -8,
                  offset: Offset(0, 8),
                ),
              const BoxShadow(
                color: Colors.black54,
                blurRadius: 16,
                offset: Offset(0, 6),
              ),
            ],
          ),
          child: child,
        ),
      ),
    );
  }
}
