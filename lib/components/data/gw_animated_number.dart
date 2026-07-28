import 'package:flutter/material.dart';
import 'package:genius_wallet/theme/genius_wallet_typography.dart';
import 'package:intl/intl.dart';

/// Numeric value that animates from its previous reading to a new one. Used
/// for balances, prices, percentages — anything where seeing the number tick
/// up makes the data feel live.
///
/// On first build it counts up from 0; subsequent value changes interpolate
/// from the previous value. Pair with [GeniusWalletTypography.numericDisplay]
/// (the default) for hero balances.
class GWAnimatedNumber extends StatefulWidget {
  const GWAnimatedNumber({
    super.key,
    required this.value,
    this.duration = const Duration(milliseconds: 700),
    this.curve = Curves.easeOutCubic,
    this.style,
    this.decimals = 2,
    this.prefix = '',
    this.suffix = '',
    this.locale,
    this.textAlign,
  });

  final num value;
  final Duration duration;
  final Curve curve;
  final TextStyle? style;
  final int decimals;
  final String prefix;
  final String suffix;
  final String? locale;
  final TextAlign? textAlign;

  @override
  State<GWAnimatedNumber> createState() => _GWAnimatedNumberState();
}

class _GWAnimatedNumberState extends State<GWAnimatedNumber> {
  double _from = 0;

  @override
  void didUpdateWidget(GWAnimatedNumber old) {
    super.didUpdateWidget(old);
    if (old.value != widget.value) {
      _from = old.value.toDouble();
    }
  }

  @override
  Widget build(BuildContext context) {
    final formatter = NumberFormat.decimalPatternDigits(
      locale: widget.locale,
      decimalDigits: widget.decimals,
    );
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: _from, end: widget.value.toDouble()),
      duration: widget.duration,
      curve: widget.curve,
      builder: (_, v, _) => Text(
        '${widget.prefix}${formatter.format(v)}${widget.suffix}',
        style: widget.style ?? GeniusWalletTypography.numericDisplay,
        textAlign: widget.textAlign,
      ),
    );
  }
}
