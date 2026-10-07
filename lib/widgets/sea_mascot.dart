import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../app/colors.dart';

enum SeaMood { calm, happy, sleepy }

/// "Sea" — SeaList's little seal mascot, drawn with plain Flutter paths
/// (no image assets, no emoji fonts needed). Gently bobs up and down.
class SeaMascot extends StatefulWidget {
  const SeaMascot({
    super.key,
    this.size = 72,
    this.mood = SeaMood.calm,
    this.bob = true,
  });

  final double size;
  final SeaMood mood;
  final bool bob;

  @override
  State<SeaMascot> createState() => _SeaMascotState();
}

class _SeaMascotState extends State<SeaMascot> with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2600),
  );

  @override
  void initState() {
    super.initState();
    if (widget.bob) _controller.repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final painted = CustomPaint(
      size: Size.square(widget.size),
      painter: _SeaPainter(widget.mood),
    );
    if (!widget.bob) return painted;

    return AnimatedBuilder(
      animation: _controller,
      child: painted,
      builder: (context, child) {
        final t = Curves.easeInOut.transform(_controller.value);
        return Transform.translate(
          offset: Offset(0, -widget.size * 0.05 * t),
          child: child,
        );
      },
    );
  }
}

class _SeaPainter extends CustomPainter {
  _SeaPainter(this.mood);

  final SeaMood mood;

  static const _body = Color(0xFFBFE3F5);
  static const _shade = Color(0xFF9CCBE6);
  static const _ink = Color(0xFF164E63);

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    Offset p(double x, double y) => Offset(w * x, h * y);

    Paint fill(Color c) => Paint()..color = c;

    // soft ground shadow
    canvas.drawOval(
      Rect.fromCenter(center: p(0.5, 0.94), width: w * 0.6, height: h * 0.07),
      fill(AppColors.deepOcean.withValues(alpha: 0.10)),
    );

    // little flippers
    canvas.drawOval(
      Rect.fromCenter(center: p(0.10, 0.70), width: w * 0.22, height: h * 0.14),
      fill(_shade),
    );
    canvas.drawOval(
      Rect.fromCenter(center: p(0.90, 0.70), width: w * 0.22, height: h * 0.14),
      fill(_shade),
    );

    // round body / head
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(w * 0.10, h * 0.08, w * 0.80, h * 0.82),
        Radius.circular(w * 0.42),
      ),
      fill(_body),
    );

    // shiny highlight
    canvas.drawOval(
      Rect.fromCenter(center: p(0.33, 0.22), width: w * 0.20, height: h * 0.10),
      fill(Colors.white.withValues(alpha: 0.45)),
    );

    // creamy muzzle
    canvas.drawOval(
      Rect.fromCenter(center: p(0.5, 0.63), width: w * 0.54, height: h * 0.34),
      fill(Colors.white),
    );

    // eyes
    final eyeY = 0.47;
    for (final x in [0.35, 0.65]) {
      switch (mood) {
        case SeaMood.calm:
          canvas.drawCircle(p(x, eyeY), w * 0.052, fill(_ink));
          canvas.drawCircle(
            p(x, eyeY) + Offset(w * 0.016, -h * 0.016),
            w * 0.018,
            fill(Colors.white),
          );
        case SeaMood.happy:
        case SeaMood.sleepy:
          final arc = Paint()
            ..color = _ink
            ..style = PaintingStyle.stroke
            ..strokeWidth = w * 0.032
            ..strokeCap = StrokeCap.round;
          canvas.drawArc(
            Rect.fromCenter(center: p(x, eyeY + 0.01), width: w * 0.10, height: h * 0.08),
            mood == SeaMood.happy ? math.pi : 0, // ∩ happy, ∪ sleepy
            math.pi,
            false,
            arc,
          );
      }
    }

    // rosy cheeks
    canvas.drawCircle(p(0.24, 0.60), w * 0.055, fill(AppColors.coral.withValues(alpha: 0.55)));
    canvas.drawCircle(p(0.76, 0.60), w * 0.055, fill(AppColors.coral.withValues(alpha: 0.55)));

    // nose
    canvas.drawOval(
      Rect.fromCenter(center: p(0.5, 0.555), width: w * 0.12, height: h * 0.075),
      fill(_ink),
    );

    // smile
    final smile = Paint()
      ..color = _ink
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.022
      ..strokeCap = StrokeCap.round;
    final mouth = Path()
      ..moveTo(w * 0.44, h * 0.625)
      ..quadraticBezierTo(w * 0.47, h * 0.685, w * 0.50, h * 0.63)
      ..quadraticBezierTo(w * 0.53, h * 0.685, w * 0.56, h * 0.625);
    canvas.drawPath(mouth, smile);

    // whisker freckles
    final freckle = fill(_ink.withValues(alpha: 0.30));
    for (final pt in [
      p(0.36, 0.60), p(0.34, 0.645),
      p(0.64, 0.60), p(0.66, 0.645),
    ]) {
      canvas.drawCircle(pt, w * 0.011, freckle);
    }
  }

  @override
  bool shouldRepaint(covariant _SeaPainter oldDelegate) => oldDelegate.mood != mood;
}
