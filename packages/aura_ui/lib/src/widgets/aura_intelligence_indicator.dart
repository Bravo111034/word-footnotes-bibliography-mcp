import 'dart:math';

import 'package:flutter/material.dart';

import '../theme/aura_tokens.dart';

/// The 7 states Aura's animated intelligence indicator can be in.
enum AuraState { idle, thinking, searching, creating, executing, complete, error }

/// Aura's animated signature orb. Renders differently per [AuraState]:
/// a slow idle breathe, a spinning arc while thinking/searching/executing,
/// a pulsing gradient while creating, a settled check on complete, and a
/// static warning ring on error.
class AuraIntelligenceIndicator extends StatefulWidget {
  const AuraIntelligenceIndicator({
    super.key,
    this.state = AuraState.idle,
    this.size = 40,
  });

  final AuraState state;
  final double size;

  @override
  State<AuraIntelligenceIndicator> createState() =>
      _AuraIntelligenceIndicatorState();
}

class _AuraIntelligenceIndicatorState extends State<AuraIntelligenceIndicator>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: AuraMotion.breathing)
      ..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          return CustomPaint(
            painter: _AuraIndicatorPainter(
              state: widget.state,
              t: _controller.value,
            ),
          );
        },
      ),
    );
  }
}

class _AuraIndicatorPainter extends CustomPainter {
  _AuraIndicatorPainter({required this.state, required this.t});

  final AuraState state;
  final double t;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = size.shortestSide / 2;

    switch (state) {
      case AuraState.idle:
        _paintBreathing(canvas, center, radius);
        break;
      case AuraState.thinking:
      case AuraState.searching:
      case AuraState.executing:
        _paintSpinningArc(canvas, center, radius);
        break;
      case AuraState.creating:
        _paintPulsingGradient(canvas, center, radius);
        break;
      case AuraState.complete:
        _paintComplete(canvas, center, radius);
        break;
      case AuraState.error:
        _paintError(canvas, center, radius);
        break;
    }
  }

  void _paintBreathing(Canvas canvas, Offset center, double radius) {
    final scale = 0.85 + 0.15 * sin(t * 2 * pi);
    final paint = Paint()
      ..shader = AuraColors.brandGradient
          .createShader(Rect.fromCircle(center: center, radius: radius))
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, radius * scale, paint);
  }

  void _paintSpinningArc(Canvas canvas, Offset center, double radius) {
    final paint = Paint()
      ..shader = AuraColors.brandGradient
          .createShader(Rect.fromCircle(center: center, radius: radius))
      ..style = PaintingStyle.stroke
      ..strokeWidth = radius * 0.28
      ..strokeCap = StrokeCap.round;
    final startAngle = t * 2 * pi;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius * 0.8),
      startAngle,
      pi * 1.3,
      false,
      paint,
    );
  }

  void _paintPulsingGradient(Canvas canvas, Offset center, double radius) {
    final opacity = 0.5 + 0.5 * sin(t * 2 * pi);
    final paint = Paint()
      ..shader = AuraColors.brandGradient
          .createShader(Rect.fromCircle(center: center, radius: radius))
      ..style = PaintingStyle.fill
      ..color = Colors.white.withOpacity(opacity);
    canvas.drawCircle(center, radius, paint);
  }

  void _paintComplete(Canvas canvas, Offset center, double radius) {
    final fill = Paint()
      ..color = AuraColors.success
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, radius, fill);

    final checkPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = radius * 0.22
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    final path = Path()
      ..moveTo(center.dx - radius * 0.45, center.dy)
      ..lineTo(center.dx - radius * 0.1, center.dy + radius * 0.35)
      ..lineTo(center.dx + radius * 0.5, center.dy - radius * 0.35);
    canvas.drawPath(path, checkPaint);
  }

  void _paintError(Canvas canvas, Offset center, double radius) {
    final fill = Paint()
      ..color = AuraColors.error
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, radius, fill);

    final markPaint = Paint()
      ..color = Colors.white
      ..strokeWidth = radius * 0.2
      ..strokeCap = StrokeCap.round;
    final offset = radius * 0.35;
    canvas.drawLine(
      center.translate(-offset, -offset),
      center.translate(offset, offset),
      markPaint,
    );
    canvas.drawLine(
      center.translate(offset, -offset),
      center.translate(-offset, offset),
      markPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _AuraIndicatorPainter oldDelegate) {
    return oldDelegate.state != state || oldDelegate.t != t;
  }
}
