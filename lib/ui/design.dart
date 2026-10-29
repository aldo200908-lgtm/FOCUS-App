import 'dart:ui';
import 'package:flutter/material.dart';

const ink = Color(0xFF0B0B0D);
const accent = Color(0xFFFF8A3D);
const muted = Color(0x99FFFFFF);

Duration motion(BuildContext context) => MediaQuery.disableAnimationsOf(context)
    ? Duration.zero
    : const Duration(milliseconds: 300);

ThemeData focusTheme() => ThemeData(
  brightness: Brightness.dark,
  scaffoldBackgroundColor: ink,
  fontFamily: 'Inter',
  colorScheme: const ColorScheme.dark(
    primary: accent,
    secondary: accent,
    surface: Color(0xFF19191C),
    onPrimary: ink,
  ),
  textTheme: const TextTheme(
    headlineLarge: TextStyle(
      fontSize: 38,
      height: 1.12,
      fontWeight: FontWeight.w600,
      letterSpacing: -1.5,
      color: Colors.white,
    ),
    headlineMedium: TextStyle(
      fontSize: 30,
      height: 1.15,
      fontWeight: FontWeight.w600,
      letterSpacing: -1,
      color: Colors.white,
    ),
    titleLarge: TextStyle(
      fontSize: 21,
      fontWeight: FontWeight.w600,
      letterSpacing: -.5,
    ),
    bodyLarge: TextStyle(fontSize: 15, height: 1.6),
    bodyMedium: TextStyle(fontSize: 13, height: 1.5),
  ),
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: Colors.white.withValues(alpha: .05),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(18),
      borderSide: const BorderSide(color: Color(0x2EFFFFFF)),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(18),
      borderSide: const BorderSide(color: Color(0x2EFFFFFF)),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(18),
      borderSide: const BorderSide(color: accent),
    ),
    contentPadding: const EdgeInsets.all(18),
  ),
  filledButtonTheme: FilledButtonThemeData(
    style: FilledButton.styleFrom(
      backgroundColor: accent,
      foregroundColor: ink,
      minimumSize: const Size(48, 54),
      textStyle: const TextStyle(
        fontFamily: 'Inter',
        fontSize: 14,
        fontWeight: FontWeight.w600,
      ),
      shape: const StadiumBorder(),
    ),
  ),
  chipTheme: ChipThemeData(
    labelStyle: const TextStyle(color: Colors.white, fontSize: 12),
    secondaryLabelStyle: const TextStyle(color: Colors.white, fontSize: 12),
    checkmarkColor: accent,
    shape: const StadiumBorder(),
    side: const BorderSide(color: Color(0x24FFFFFF)),
    selectedColor: accent.withValues(alpha: .18),
    backgroundColor: Colors.white.withValues(alpha: .04),
  ),
  dividerColor: Colors.white.withValues(alpha: .1),
  bottomSheetTheme: const BottomSheetThemeData(
    backgroundColor: Color(0xFF151517),
    showDragHandle: true,
  ),
);

class GlassCard extends StatelessWidget {
  const GlassCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(22),
    this.blur = false,
    this.radius = 28,
  });
  final Widget child;
  final EdgeInsetsGeometry padding;
  final bool blur;
  final double radius;
  @override
  Widget build(BuildContext context) {
    Widget content = Container(
      padding: padding,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(radius),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withValues(alpha: .10),
            Colors.white.withValues(alpha: .055),
          ],
        ),
        border: Border.all(
          color: Colors.white.withValues(alpha: .18),
          width: .7,
        ),
      ),
      child: child,
    );
    if (blur) {
      content = BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
        child: content,
      );
    }
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(radius),
        boxShadow: const [
          BoxShadow(
            color: Color(0x24000000),
            blurRadius: 22,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(radius),
        child: content,
      ),
    );
  }
}

class PressButton extends StatefulWidget {
  const PressButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon = Icons.arrow_forward_rounded,
  });
  final String label;
  final VoidCallback onPressed;
  final IconData icon;
  @override
  State<PressButton> createState() => _PressButtonState();
}

class _PressButtonState extends State<PressButton> {
  bool pressed = false;
  @override
  Widget build(BuildContext context) => Listener(
    onPointerDown: (_) => setState(() => pressed = true),
    onPointerUp: (_) => setState(() => pressed = false),
    onPointerCancel: (_) => setState(() => pressed = false),
    child: AnimatedScale(
      scale: pressed ? .98 : 1,
      duration: motion(context),
      curve: Curves.easeOut,
      child: FilledButton(
        onPressed: widget.onPressed,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 15),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Flexible(child: Text(widget.label, textAlign: TextAlign.center)),
              const SizedBox(width: 12),
              Icon(widget.icon, size: 20),
            ],
          ),
        ),
      ),
    ),
  );
}

class Eyebrow extends StatelessWidget {
  const Eyebrow(this.text, {super.key, this.color = muted});
  final String text;
  final Color color;
  @override
  Widget build(BuildContext context) => Text(
    text,
    style: TextStyle(
      fontSize: 10,
      letterSpacing: 2,
      fontWeight: FontWeight.w600,
      color: color,
    ),
  );
}

class PageHeading extends StatelessWidget {
  const PageHeading({
    super.key,
    required this.kicker,
    required this.title,
    required this.subtitle,
  });
  final String kicker, title, subtitle;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(24, 28, 24, 26),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Eyebrow(kicker, color: accent),
        const SizedBox(height: 14),
        Text(title, style: Theme.of(context).textTheme.headlineLarge),
        const SizedBox(height: 12),
        Text(
          subtitle,
          style: const TextStyle(color: muted, height: 1.6, fontSize: 14),
        ),
      ],
    ),
  );
}

class Landscape extends StatelessWidget {
  const Landscape({
    super.key,
    this.opacity = 1,
    this.imageAsset = 'assets/images/mountain.jpg',
  });
  final double opacity;
  final String imageAsset;
  @override
  Widget build(BuildContext context) => ExcludeSemantics(
    child: RepaintBoundary(
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            imageAsset,
            fit: BoxFit.cover,
            alignment: const Alignment(.25, 0),
            opacity: AlwaysStoppedAnimation(opacity),
            cacheWidth: 900,
            gaplessPlayback: true,
          ),
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                stops: [0, .38, 1],
                colors: [
                  Color(0x550B0B0D),
                  Color(0x660B0B0D),
                  Color(0xFF0B0B0D),
                ],
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    required this.title,
    required this.message,
    this.action,
  });
  final String title, message;
  final Widget? action;
  @override
  Widget build(BuildContext context) => GlassCard(
    child: Column(
      children: [
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: accent.withValues(alpha: .1),
          ),
          child: const Icon(Icons.checklist_rounded, color: accent, size: 30),
        ),
        const SizedBox(height: 20),
        Text(
          title,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 10),
        Text(
          message,
          textAlign: TextAlign.center,
          style: const TextStyle(color: muted, height: 1.6),
        ),
        if (action != null) ...[const SizedBox(height: 22), action!],
      ],
    ),
  );
}
