import 'package:flutter/material.dart';
import '../app/colors.dart';

/// Ocean-gradient "+" button. (Not a stock FloatingActionButton on purpose:
/// two stock FABs alive in the tab stack share a Hero tag and can clash
/// during page transitions.)
class GradientFab extends StatelessWidget {
  const GradientFab({
    super.key,
    required this.onPressed,
    this.icon = Icons.add_rounded,
    this.tooltip = 'เพิ่ม',
  });

  final VoidCallback onPressed;
  final IconData icon;
  final String tooltip;

  @override
  Widget build(BuildContext context) {
    final shape = BorderRadius.circular(22);
    return Tooltip(
      message: tooltip,
      child: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          borderRadius: shape,
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColors.oceanBlue, AppColors.turquoise],
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.oceanBlue.withValues(alpha: 0.35),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: shape,
          child: InkWell(
            borderRadius: shape,
            onTap: onPressed,
            child: Icon(icon, color: Colors.white, size: 32),
          ),
        ),
      ),
    );
  }
}
