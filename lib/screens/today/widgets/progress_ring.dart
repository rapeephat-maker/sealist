import 'package:flutter/material.dart';
import '../../../app/colors.dart';

class ProgressRing extends StatelessWidget {
  const ProgressRing({super.key, required this.done, required this.total});

  final int done;
  final int total;

  @override
  Widget build(BuildContext context) {
    final pct = total == 0 ? 0.0 : done / total;
    return SizedBox(
      width: 52,
      height: 52,
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: 52,
            height: 52,
            // Fills up smoothly whenever a task is ticked off.
            child: TweenAnimationBuilder<double>(
              tween: Tween<double>(begin: 0, end: pct),
              duration: const Duration(milliseconds: 600),
              curve: Curves.easeOutCubic,
              builder: (context, value, _) => CircularProgressIndicator(
                value: value,
                strokeWidth: 6,
                strokeCap: StrokeCap.round,
                backgroundColor: const Color(0xFFD7ECEC),
                valueColor: const AlwaysStoppedAnimation(AppColors.turquoise),
              ),
            ),
          ),
          Container(
            width: 36,
            height: 36,
            decoration: const BoxDecoration(color: AppColors.sky, shape: BoxShape.circle),
            alignment: Alignment.center,
            child: Text(
              '$done/$total',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: AppColors.deepOcean,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
