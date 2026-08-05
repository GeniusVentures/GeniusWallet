import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:genius_wallet/theme/gw_colors.dart';
import 'package:genius_wallet/theme/gw_context_extension.dart';

/// Branded loading spinner — a sweep-gradient arc rotating through cyan and
/// mint. Replace ad-hoc [CircularProgressIndicator] usages with this so the
/// loading state feels like the rest of the brand.
class GWSpinner extends StatefulWidget {
  const GWSpinner({
    super.key,
    this.size = 32,
    this.strokeWidth = 3,
    this.duration = const Duration(milliseconds: 900),
  });

  final double size;
  final double strokeWidth;
  final Duration duration;

  @override
  State<GWSpinner> createState() => _GWSpinnerState();
}

class _GWSpinnerState extends State<GWSpinner>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration)
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
      child: RotationTransition(
        turns: _controller,
        child: CustomPaint(
          painter: _SpinnerPainter(
            strokeWidth: widget.strokeWidth,
            gw: context.gw,
          ),
        ),
      ),
    );
  }
}

class _SpinnerPainter extends CustomPainter {
  _SpinnerPainter({required this.strokeWidth, required this.gw});
  final double strokeWidth;

  /// Threaded in from the nearest caller with a `BuildContext`
  /// (`_GWSpinnerState.build`) -- a `CustomPainter` never has one of its
  /// own. Every field read below is a mode-invariant fixed token, so this is
  /// a pure access-path move: same values as the legacy `GeniusWalletColors`
  /// statics, just read through the migrated token.
  final GWColors gw;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final inset = rect.deflate(strokeWidth / 2);

    // Background ring at low opacity so the gradient arc reads as progress.
    final trackPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..color = gw.borderSubtle;
    canvas.drawOval(inset, trackPaint);

    final shader = SweepGradient(
      startAngle: 0,
      endAngle: 2 * math.pi,
      colors: [gw.brandPrimary, gw.brandSecondary, gw.brandSecondaryBright],
      stops: const [0.0, 0.6, 1.0],
    ).createShader(rect);

    final arcPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..shader = shader;

    // 80% sweep — the visible "comet" of the spinner.
    canvas.drawArc(inset, 0, 2 * math.pi * 0.8, false, arcPaint);
  }

  @override
  bool shouldRepaint(_SpinnerPainter oldDelegate) =>
      oldDelegate.strokeWidth != strokeWidth || oldDelegate.gw != gw;
}
