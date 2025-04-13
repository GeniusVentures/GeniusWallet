import 'package:flutter/material.dart';

class XAnimation extends StatefulWidget {
  const XAnimation({Key? key}) : super(key: key);

  @override
  XAnimationState createState() => XAnimationState();
}

class XAnimationState extends State<XAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800), // Duration of the animation
    );

    // Automatically start the animation when the widget is initialized
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: CustomPaint(
        size: const Size(25, 25),
        painter: XPainter(_animationController),
      ),
    );
  }
}

class XPainter extends CustomPainter {
  final Animation<double> animation;
  XPainter(this.animation) : super(repaint: animation);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.red
      ..strokeWidth = 3.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.square;

    final path = Path();
    double progress = animation.value;

    // Coordinates for the first line of the "X"
    double line1StartX = size.width * 0.2;
    double line1StartY = size.height * 0.2;

    double line1EndX = size.width * 0.8;
    double line1EndY = size.height * 0.8;

    // Coordinates for the second line of the "X"
    double line2StartX = size.width * 0.8;
    double line2StartY = size.height * 0.2;

    double line2EndX = size.width * 0.2;
    double line2EndY = size.height * 0.8;

    // Animate the first line of the "X"
    if (progress < 0.5) {
      double segmentProgress = progress / 0.5;
      path.moveTo(line1StartX, line1StartY);
      path.lineTo(
        line1StartX + (line1EndX - line1StartX) * segmentProgress,
        line1StartY + (line1EndY - line1StartY) * segmentProgress,
      );
    }
    // Animate the second line of the "X"
    else {
      path.moveTo(line1StartX, line1StartY);
      path.lineTo(line1EndX, line1EndY);

      double segmentProgress = (progress - 0.5) / 0.5;
      path.moveTo(line2StartX, line2StartY);
      path.lineTo(
        line2StartX + (line2EndX - line2StartX) * segmentProgress,
        line2StartY + (line2EndY - line2StartY) * segmentProgress,
      );
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
