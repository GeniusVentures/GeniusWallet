import 'package:flutter/widgets.dart';
import 'package:genius_wallet/theme/genius_wallet_colors.dart';

class PulsingSkeleton extends StatefulWidget {
  final double height;
  final double width;

  const PulsingSkeleton({
    Key? key,
    this.height = 24,
    this.width = double.infinity,
  }) : super(key: key);

  @override
  State<PulsingSkeleton> createState() => _PulsingSkeletonState();
}

class _PulsingSkeletonState extends State<PulsingSkeleton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacityAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);

    _opacityAnim = Tween<double>(begin: 0.3, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _opacityAnim,
      builder: (context, child) => Opacity(
        opacity: _opacityAnim.value,
        child: Container(
          height: widget.height,
          width: widget.width,
          margin: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: GeniusWalletColors.deepBlue,
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
    );
  }
}
