import 'package:flutter/material.dart';

class VereinslogoPainter extends CustomPainter {
  final Color fillColor;
  final Color textColor;
  final String label;

  VereinslogoPainter({
    required this.fillColor,
    required this.textColor,
    required this.label,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = fillColor
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;

    final shield = Path()
      ..moveTo(size.width * 0.5, 0)
      ..lineTo(size.width * 0.1, size.height * 0.25)
      ..lineTo(size.width * 0.1, size.height * 0.6)
      ..quadraticBezierTo(
        size.width * 0.1,
        size.height * 0.9,
        size.width * 0.5,
        size.height,
      )
      ..quadraticBezierTo(
        size.width * 0.9,
        size.height * 0.9,
        size.width * 0.9,
        size.height * 0.6,
      )
      ..lineTo(size.width * 0.9, size.height * 0.25)
      ..close();

    canvas.drawPath(shield, paint);

    final stripePaint = Paint()
      ..color = Colors.white.withValues(alpha: 51)
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;

    final stripe = Path()
      ..moveTo(size.width * 0.05, size.height * 0.15)
      ..lineTo(size.width * 0.95, size.height * 0.15)
      ..lineTo(size.width * 0.85, size.height * 0.27)
      ..lineTo(size.width * 0.15, size.height * 0.27)
      ..close();

    canvas.drawPath(stripe, stripePaint);

    final textPainter = TextPainter(
      text: TextSpan(
        text: label,
        style: TextStyle(
          color: textColor,
          fontSize: size.width * 0.17,
          fontWeight: FontWeight.bold,
          height: 1.1,
        ),
      ),
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
      maxLines: 3,
    );

    textPainter.layout(maxWidth: size.width * 0.8);
    textPainter.paint(
      canvas,
      Offset(
        size.width * 0.1,
        size.height * 0.38 - textPainter.height / 2,
      ),
    );
  }

  @override
  bool shouldRepaint(covariant VereinslogoPainter oldDelegate) {
    return oldDelegate.fillColor != fillColor ||
        oldDelegate.textColor != textColor ||
        oldDelegate.label != label;
  }
}
