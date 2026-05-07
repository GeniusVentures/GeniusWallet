import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:genius_wallet/theme/genius_wallet_colors.dart';

/// Animated brand-color mesh that lives behind a screen's content. Three
/// large radial blobs (cyan, mint, purple) drift on independent loops over
/// the dark teal canvas, giving every screen a subtle sense of motion
/// without distracting from foreground UI.
///
/// Use [GWMeshBackground] as the immediate child of [Scaffold.body] (or
/// wrap a Stack) and then place your real content above it. Defaults are
/// tuned for the Landing / hero screens — drop [intensity] for denser
/// content surfaces.
class GWMeshBackground extends StatefulWidget {
  const GWMeshBackground({
    super.key,
    required this.child,
    this.intensity = 1.0,
    this.duration = const Duration(seconds: 36),
    this.baseColor = GeniusWalletColors.surfaceBase,
  });

  final Widget child;

  /// Strength of the colored blobs (0..1). 1.0 is the full hero treatment;
  /// 0.5 is a quieter version for content-heavy screens.
  final double intensity;

  /// Single full-cycle duration. The default (36s) is long enough that the
  /// motion reads as ambient rather than animated.
  final Duration duration;

  /// Solid colour painted underneath the mesh. Defaults to the brand canvas
  /// teal — override only if you need a different base.
  final Color baseColor;

  @override
  State<GWMeshBackground> createState() => _GWMeshBackgroundState();
}

class _GWMeshBackgroundState extends State<GWMeshBackground>
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
    return Stack(
      fit: StackFit.expand,
      children: [
        ColoredBox(color: widget.baseColor),
        RepaintBoundary(
          child: AnimatedBuilder(
            animation: _controller,
            builder: (_, __) => CustomPaint(
              painter: _MeshPainter(
                t: _controller.value,
                intensity: widget.intensity.clamp(0.0, 1.0),
              ),
              size: Size.infinite,
            ),
          ),
        ),
        widget.child,
      ],
    );
  }
}

class _MeshPainter extends CustomPainter {
  _MeshPainter({required this.t, required this.intensity});

  final double t;
  final double intensity;

  @override
  void paint(Canvas canvas, Size size) {
    if (intensity <= 0) return;

    final w = size.width;
    final h = size.height;
    final maxDim = math.max(w, h);
    final rect = Offset.zero & size;

    void drawBlob({
      required Color color,
      required double phase,
      double radiusScale = 0.95,
      double driftScale = 0.35,
    }) {
      final angle = (t + phase) * 2 * math.pi;
      // Two harmonics give a less-circular drift path
      final cx = w * (0.5 + driftScale * math.sin(angle));
      final cy = h * (0.5 + driftScale * math.cos(angle * 0.78));
      final radius = maxDim * radiusScale;
      // srcOver (default) with low alpha — additive blending was blowing out
      // to near-white where blobs overlapped, producing a too-bright wash.
      final paint = Paint()
        ..shader = RadialGradient(
          colors: [
            color.withAlpha((110 * intensity).round()),
            color.withAlpha(0),
          ],
          stops: const [0.0, 1.0],
        ).createShader(
          Rect.fromCircle(center: Offset(cx, cy), radius: radius),
        );
      canvas.drawRect(rect, paint);
    }

    drawBlob(color: GeniusWalletColors.brandPrimary, phase: 0.00);
    drawBlob(color: GeniusWalletColors.brandSecondary, phase: 0.33);
    drawBlob(
      color: GeniusWalletColors.brandTertiary,
      phase: 0.66,
      radiusScale: 0.80,
    );

    // Vignette-style dim overlay that's stronger toward the center to anchor
    // foreground content without flattening the blobs at the edges.
    canvas.drawRect(
      rect,
      Paint()..color = Colors.black.withAlpha((38 * intensity).round()),
    );
  }

  @override
  bool shouldRepaint(_MeshPainter old) =>
      old.t != t || old.intensity != intensity;
}
