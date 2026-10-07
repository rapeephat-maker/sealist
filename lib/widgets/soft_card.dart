import 'package:flutter/material.dart';
import '../app/colors.dart';

/// The app's signature card: rounded, white (or tinted), with a soft blue
/// shadow. Ripples are drawn *above* the fill so taps are visible.
class SoftCard extends StatelessWidget {
  const SoftCard({
    super.key,
    required this.child,
    this.onTap,
    this.padding = const EdgeInsets.all(14),
    this.color = Colors.white,
    this.radius = 20,
  });

  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry padding;
  final Color color;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final shape = BorderRadius.circular(radius);
    return Container(
      decoration: BoxDecoration(
        color: color,
        borderRadius: shape,
        boxShadow: [
          BoxShadow(
            color: AppColors.deepOcean.withValues(alpha: 0.08),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: shape,
        child: InkWell(
          onTap: onTap,
          borderRadius: shape,
          child: Padding(padding: padding, child: child),
        ),
      ),
    );
  }
}
