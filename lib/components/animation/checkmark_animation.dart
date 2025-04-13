import 'package:flutter/material.dart';

class CheckmarkAnimation extends StatefulWidget {
  const CheckmarkAnimation({Key? key}) : super(key: key);

  @override
  CheckmarkAnimationState createState() => CheckmarkAnimationState();
}

class CheckmarkAnimationState extends State<CheckmarkAnimation>
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
        painter: CheckmarkPainter(_animationController),
      ),
    );
  }
}

class CheckmarkPainter extends CustomPainter {
  final Animation<double> animation;
  CheckmarkPainter(this.animation) : super(repaint: animation);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.greenAccent
      ..strokeWidth = 4.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.square;

    final path = Path();
    double progress = animation.value;

    // Define the checkmark path
    double checkStartX = size.width * 0.2;
    double checkStartY = size.height * 0.5;

    double checkMidX = size.width * 0.4;
    double checkMidY = size.height * 0.7;

    double checkEndX = size.width * 0.8;
    double checkEndY = size.height * 0.3;

    // Animate the first segment of the checkmark
    if (progress < 0.5) {
      double segmentProgress = progress / 0.5;
      path.moveTo(checkStartX, checkStartY);
      path.lineTo(
        checkStartX + (checkMidX - checkStartX) * segmentProgress,
        checkStartY + (checkMidY - checkStartY) * segmentProgress,
      );
    }
    // Animate the second segment of the checkmark
    else {
      path.moveTo(checkStartX, checkStartY);
      path.lineTo(checkMidX, checkMidY);
      double segmentProgress = (progress - 0.5) / 0.5;
      path.lineTo(
        checkMidX + (checkEndX - checkMidX) * segmentProgress,
        checkMidY + (checkEndY - checkMidY) * segmentProgress,
      );
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
