import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../../theme/theme_controller.dart';

class WavePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..shader = ui.Gradient.linear(
        Offset(size.width * 0.2, size.height * 0.7),
        Offset(size.width * 0.8, size.height * 0.2),
          [ Color(0xFF9584FF), Color(0xFFFF3e89),]
      )
      ..style = PaintingStyle.fill;

    final Path path = Path()
      ..moveTo(size.width, size.height)
      ..lineTo(size.width, size.height * 0.5)
      ..quadraticBezierTo(
          size.width * 0.7, size.height * 0.3, size.width * 0.4, size.height * 0.6)
      ..quadraticBezierTo(size.width * 0.2, size.height * 0.85, 0, size.height * 0.7)
      ..lineTo(0, size.height)
      ..close();

    canvas.drawPath(path, paint);

    // Draw the small floating circle
    final Paint circlePaint = Paint()
      ..shader = ui.Gradient.linear(
        Offset(size.width * 0.7, size.height * 0.2),
        Offset(size.width * 0.8, size.height * 0.1),
          [ Color(0xFF9584FF), Color(0xFFFF3e89),]
      );

    canvas.drawCircle(Offset(size.width * 0.8, size.height * 0.2), 10, circlePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}


class GradientBlobScreen extends StatelessWidget {
  const GradientBlobScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: SizedBox(
          width: 300,
          height: 300,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Main blob
              CustomPaint(
                size: const Size(300, 300),
                painter: BlobPainter(),
              ),

              // Small purple circle at top
              Positioned(
                top: 0,
                child: Container(
                  width: 20,
                  height: 20,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color(0xFFB668E6),
                  ),
                ),
              ),

              // Small purple circle at right
              Positioned(
                right: 0,
                top: 80,
                child: Container(
                  width: 30,
                  height: 30,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color(0xFF9A7EE6),
                  ),
                ),
              ),

              // Small purple circle at bottom
              Positioned(
                bottom: 20,
                left: 120,
                child: Container(
                  width: 15,
                  height: 15,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color(0xFFB668E6),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class BlobPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);

    // Define the gradient from pink to purple
    final gradient = LinearGradient(
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
      colors: [
        const Color(0xFFFF4D94), // Pink
        const Color(0xFFB668E6), // Purple
      ],
    );

    final paint = Paint()
      ..shader = gradient.createShader(rect)
      ..style = PaintingStyle.fill;

    // Create a path for the blob shape
    final path = Path();

    // Starting point
    path.moveTo(size.width * 0.2, size.height * 0.4);

    // Top left curve
    path.quadraticBezierTo(
        size.width * 0.05, size.height * 0.2,
        size.width * 0.2, size.height * 0.15
    );

    // Top curve
    path.quadraticBezierTo(
        size.width * 0.35, size.height * 0.05,
        size.width * 0.5, size.height * 0.15
    );

    // Top right curve
    path.quadraticBezierTo(
        size.width * 0.65, size.height * 0.25,
        size.width * 0.8, size.height * 0.15
    );

    // Right curve
    path.quadraticBezierTo(
        size.width * 0.95, size.height * 0.05,
        size.width * 0.85, size.height * 0.4
    );

    // Bottom right curve
    path.quadraticBezierTo(
        size.width * 0.95, size.height * 0.6,
        size.width * 0.8, size.height * 0.75
    );

    // Bottom curve
    path.quadraticBezierTo(
        size.width * 0.65, size.height * 0.9,
        size.width * 0.5, size.height * 0.8
    );

    // Bottom left curve
    path.quadraticBezierTo(
        size.width * 0.35, size.height * 0.7,
        size.width * 0.2, size.height * 0.8
    );

    // Left curve to close the path
    path.quadraticBezierTo(
        size.width * 0.05, size.height * 0.9,
        size.width * 0.2, size.height * 0.4
    );

    // Draw the blob
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}


class TopLeftBlobPainter extends CustomPainter {


  @override
  void paint(Canvas canvas, Size size) {

    final paint = Paint()
      ..shader = LinearGradient(
        colors: [
          const Color(0xFFFF6B9D).withOpacity(0.4),
          const Color(0xFFFF8A80).withOpacity(0.3),
          const Color(0xFFFFAB91).withOpacity(0.2),
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..style = PaintingStyle.fill;

    final path = Path();

    // Create organic blob shape matching the design
    path.moveTo(size.width * 0.1, size.height * 0.3);

    // Top curve
    path.quadraticBezierTo(
        size.width * 0.3, size.height * 0.05,
        size.width * 0.6, size.height * 0.15
    );

    // Right curve
    path.quadraticBezierTo(
        size.width * 0.9, size.height * 0.25,
        size.width * 0.85, size.height * 0.5
    );

    // Bottom right curve
    path.quadraticBezierTo(
        size.width * 0.8, size.height * 0.75,
        size.width * 0.6, size.height * 0.8
    );

    // Bottom curve
    path.quadraticBezierTo(
        size.width * 0.4, size.height * 0.85,
        size.width * 0.2, size.height * 0.75
    );

    // Left curve back to start
    path.quadraticBezierTo(
        size.width * 0.05, size.height * 0.6,
        size.width * 0.1, size.height * 0.3
    );

    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
