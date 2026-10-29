import 'dart:ui';
import 'package:flutter/material.dart';

/// Reusable offline photo card. Only one licensed local photograph is shipped,
/// deliberately cropped and tinted differently across screens.
class CinematicCard extends StatelessWidget {
  const CinematicCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.label,
    this.height = 260,
    this.tint = const Color(0xFF057EA2),
    this.alignment = Alignment.center,
    this.onTap,
    this.action,
    this.semanticLabel,
  });

  final String title;
  final String subtitle;
  final String label;
  final double height;
  final Color tint;
  final Alignment alignment;
  final VoidCallback? onTap;
  final Widget? action;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final child = SizedBox(
      height: height,
      child: Stack(
        fit: StackFit.expand,
        clipBehavior: Clip.hardEdge,
        children: [
          RepaintBoundary(
            child: ColorFiltered(
              colorFilter: ColorFilter.mode(
                tint.withValues(alpha: .28),
                BlendMode.overlay,
              ),
              child: Image.asset(
                'assets/images/mountain.jpg',
                fit: BoxFit.cover,
                alignment: alignment,
                cacheWidth: 950,
                errorBuilder: (context, error, stack) =>
                    ColoredBox(color: tint),
              ),
            ),
          ),
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                stops: [0, .38, 1],
                colors: [
                  Color(0x330B0B0D),
                  Color(0x110B0B0D),
                  Color(0xCC090A0E),
                ],
              ),
            ),
          ),
          Positioned(
            left: 16,
            top: 16,
            child: FrostedChip(label: label),
          ),
          Positioned(
            right: 15,
            top: 14,
            child: action ?? const FrostedChip(
              label: '',
              icon: Icons.more_horiz_rounded,
            ),
          ),
          Positioned(
            left: 15,
            right: 10,
            bottom: -13,
            child: FittedBox(
              alignment: Alignment.bottomLeft,
              fit: BoxFit.scaleDown,
              child: Text(
                title,
                maxLines: 1,
                style: TextStyle(
                  fontSize: height > 200 ? 103 : 58,
                  fontWeight: FontWeight.w700,
                  height: 1,
                  letterSpacing: -5,
                  color: Colors.white.withValues(alpha: .76),
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 64,
            left: 20,
            right: 16,
            child: Text(
              subtitle,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w600,
                shadows: [Shadow(blurRadius: 16, color: Colors.black)],
              ),
            ),
          ),
        ],
      ),
    );

    return Semantics(
      label: semanticLabel ?? '$title. $subtitle',
      button: onTap != null,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: Material(
          color: const Color(0xFF171B20),
          child: InkWell(
            onTap: onTap,
            child: child,
          ),
        ),
      ),
    );
  }
}

class FrostedChip extends StatelessWidget {
  const FrostedChip({
    super.key,
    required this.label,
    this.icon,
    this.onTap,
  });
  final String label;
  final IconData? icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) => ClipRRect(
    borderRadius: BorderRadius.circular(50),
    child: BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
      child: Material(
        color: Colors.white.withValues(alpha: .13),
        shape: StadiumBorder(
          side: BorderSide(color: Colors.white.withValues(alpha: .30)),
        ),
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 9),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (icon != null) ...[
                  Icon(icon, size: 14, color: Colors.white),
                  const SizedBox(width: 5),
                ],
                Text(
                  label,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}

class EditorialSectionTitle extends StatelessWidget {
  const EditorialSectionTitle({
    super.key,
    required this.title,
    this.trailing,
  });
  final String title;
  final Widget? trailing;
  @override
  Widget build(BuildContext context) => Row(
    children: [
      Expanded(
        child: Text(title, style: Theme.of(context).textTheme.titleLarge),
      ),
      if (trailing != null) trailing!,
    ],
  );
}
