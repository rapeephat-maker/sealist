import 'package:flutter/material.dart';
import '../app/colors.dart';

/// A soft sky-to-seafoam header with two gentle layered waves and a few
/// floating bubbles, used behind the Today screen's greeting.
class WaveHeader extends StatelessWidget {
  const WaveHeader({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.passthrough,
      children: [
        const Positioned.fill(child: CustomPaint(painter: _WavePainter())),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 46),
          child: child,
        ),
      ],
    );
  }
}

class _WavePainter extends CustomPainter {
  const _WavePainter();

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // back wave (seafoam)
    final back = Path()
      ..moveTo(0, 0)
      ..lineTo(0, h - 10)
      ..quadraticBezierTo(w * 0.28, h - 42, w * 0.58, h - 18)
      ..quadraticBezierTo(w * 0.85, h, w, h - 30)
      ..lineTo(w, 0)
      ..close();
    canvas.drawPath(back, Paint()..color = AppColors.seafoam.withValues(alpha: 0.8));

    // front wave (sky gradient)
    final front = Path()
      ..moveTo(0, 0)
      ..lineTo(0, h - 26)
      ..quadraticBezierTo(w * 0.22, h + 2, w * 0.5, h - 20)
      ..quadraticBezierTo(w * 0.76, h - 40, w, h - 16)
      ..lineTo(w, 0)
      ..close();
    canvas.drawPath(
      front,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [AppColors.sky, Color(0xFFE9FAF6)],
        ).createShader(Rect.fromLTWH(0, 0, w, h)),
    );

    // floating bubbles
    final bubbleFill = Paint()..color = Colors.white.withValues(alpha: 0.55);
    final bubbleRing = Paint()
      ..color = AppColors.oceanBlue.withValues(alpha: 0.18)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;
    const bubbles = [
      [0.10, 0.22, 9.0],
      [0.17, 0.46, 5.0],
      [0.62, 0.14, 6.0],
      [0.93, 0.10, 8.0],
      [0.88, 0.52, 12.0],
    ];
    for (final b in bubbles) {
      final c = Offset(w * b[0], h * b[1]);
      canvas.drawCircle(c, b[2], bubbleFill);
      canvas.drawCircle(c, b[2], bubbleRing);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
