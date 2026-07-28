import 'package:flutter/material.dart';
import 'package:genius_wallet/theme/genius_wallet_colors.dart';
import 'package:genius_wallet/theme/genius_wallet_consts.dart';
import 'package:genius_wallet/theme/genius_wallet_decorations.dart';
import 'package:genius_wallet/theme/genius_wallet_typography.dart';

class GWBottomSheet {
  GWBottomSheet._();

  static Future<T?> show<T>({
    required BuildContext context,
    required Widget child,
    String? title,
    bool isScrollControlled = true,
    bool showHandle = true,
  }) {
    return showModalBottomSheet<T>(
      context: context,
      isScrollControlled: isScrollControlled,
      backgroundColor: Colors.transparent,
      barrierColor: GeniusWalletColors.surfaceOverlay,
      builder: (_) =>
          _SheetContainer(title: title, showHandle: showHandle, child: child),
    );
  }
}

class _SheetContainer extends StatelessWidget {
  const _SheetContainer({
    required this.child,
    this.title,
    this.showHandle = true,
  });

  final Widget child;
  final String? title;
  final bool showHandle;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      decoration: BoxDecoration(
        gradient: GWDecorations.surfaceSheen,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(GeniusWalletConsts.radiusXl),
        ),
        border: Border(
          top: BorderSide(color: GeniusWalletColors.borderSubtle, width: 1),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (showHandle)
              Container(
                margin: const EdgeInsets.only(top: GeniusWalletConsts.space4),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: GeniusWalletColors.borderStrong,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            if (title != null) ...[
              const SizedBox(height: GeniusWalletConsts.space6),
              Text(title!, style: GeniusWalletTypography.titleLg),
            ],
            Flexible(
              child: Padding(
                padding: const EdgeInsets.all(GeniusWalletConsts.space8),
                child: child,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
