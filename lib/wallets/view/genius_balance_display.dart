import 'dart:async';
import 'package:flutter/material.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:genius_api/genius_api.dart';
import 'package:provider/provider.dart';
import 'package:genius_wallet/theme/genius_wallet_colors.g.dart';

class GeniusBalanceDisplay extends StatefulWidget {
  final bool useMinions;
  final double? fontSize;
  final bool? isShowSuffix;
  final Color? fontColor;

  const GeniusBalanceDisplay(
      {super.key,
      required this.useMinions,
      this.fontSize,
      this.isShowSuffix,
      this.fontColor});

  @override
  State<GeniusBalanceDisplay> createState() => _GeniusBalanceDisplayState();
}

class _GeniusBalanceDisplayState extends State<GeniusBalanceDisplay> {
  late String _balance;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _balance = widget.useMinions
        ? context.read<GeniusApi>().getMinionsBalance()
        : context.read<GeniusApi>().getSGNUSBalance();
    _fetchBalance();
    _startPolling();
  }

  @override
  void didUpdateWidget(covariant GeniusBalanceDisplay oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.useMinions != widget.useMinions) {
      _fetchBalance();
    }
  }

  void _fetchBalance() {
    final newBalance = widget.useMinions
        ? context.read<GeniusApi>().getMinionsBalance()
        : context.read<GeniusApi>().getSGNUSBalance();
    if (mounted) {
      setState(() => _balance = newBalance);
      // debugPrint(
      //     '🅱️ Fetched New ${widget.useMinions ? 'Minions' : 'Gnus'} Balance: $_balance');
    }
  }

  void _startPolling() {
    _timer =
        Timer.periodic(const Duration(seconds: 10), (_) => _fetchBalance());
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      mainAxisSize: MainAxisSize.min,
      children: [
        Flexible(
          child: AutoSizeText(
            _balance,
            style: TextStyle(
              fontSize: widget.fontSize ?? 48,
              fontWeight: FontWeight.w500,
              color: widget.fontColor ?? Colors.white,
            ),
            maxLines: 1,
          ),
        ),
        if (widget.isShowSuffix ?? false) ...[
          const SizedBox(width: 4),
          AutoSizeText(
            widget.useMinions ? "min" : "gnus",
            maxLines: 1,
            style: TextStyle(
              fontSize: widget.fontSize ?? 16,
              fontWeight: FontWeight.w500,
              color: widget.fontColor ?? GeniusWalletColors.gray500,
            ),
          )
        ]
      ],
    );
  }
}
