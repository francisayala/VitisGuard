import 'dart:ui';
import 'package:flutter/material.dart';

class DottedBorderContainer extends StatelessWidget {
  final Widget child;
  final Color color;
  final double strokeWidth;
  final List<double> dashPattern;
  final double borderRadius;

  const DottedBorderContainer({
    super.key,
    required this.child,
    this.color = Colors.black,
    this.strokeWidth = 1,
    this.dashPattern = const [3, 3],
    this.borderRadius = 0,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _DottedBorderPainter(
        color: color,
        strokeWidth: strokeWidth,
        dashPattern: dashPattern,
        borderRadius: borderRadius,
      ),
      child: child,
    );
  }
}

class _DottedBorderPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final List<double> dashPattern;
  final double borderRadius;

  _DottedBorderPainter({
    required this.color,
    required this.strokeWidth,
    required this.dashPattern,
    required this.borderRadius,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final Path path = Path();
    path.addRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 0, size.width, size.height),
        Radius.circular(borderRadius),
      ),
    );

    final Path dashedPath = Path();
    final double dashWidth = dashPattern[0];
    final double gapWidth = dashPattern[1];

    for (final PathMetric pathMetric in path.computeMetrics()) {
      double distance = 0;
      bool draw = true;
      while (distance < pathMetric.length) {
        final double len = draw ? dashWidth : gapWidth;
        if (draw) {
          dashedPath.addPath(
            pathMetric.extractPath(distance, distance + len),
            Offset.zero,
          );
        }
        distance += len;
        draw = !draw;
      }
    }
    canvas.drawPath(dashedPath, paint);
  }

  @override
  bool shouldRepaint(_DottedBorderPainter oldDelegate) {
    return oldDelegate.color != color ||
        oldDelegate.strokeWidth != strokeWidth ||
        oldDelegate.borderRadius != borderRadius;
  }
}
