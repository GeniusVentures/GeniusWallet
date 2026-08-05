import 'package:flutter/material.dart';
import 'package:genius_wallet/components/buttons/gw_button.dart';
import 'package:genius_wallet/theme/genius_wallet_consts.dart';
import 'package:genius_wallet/theme/genius_wallet_decorations.dart';
import 'package:genius_wallet/theme/genius_wallet_elevation.dart';
import 'package:genius_wallet/theme/genius_wallet_typography.dart';
import 'package:genius_wallet/theme/gw_colors.dart';
import 'package:genius_wallet/theme/gw_context_extension.dart';

class GWDialog extends StatelessWidget {
  const GWDialog({
    super.key,
    required this.title,
    this.message,
    this.content,
    this.actions = const [],
    this.icon,
  });

  final String title;
  final String? message;
  final Widget? content;
  final List<GWDialogAction> actions;
  final IconData? icon;

  static Future<T?> show<T>({
    required BuildContext context,
    required String title,
    String? message,
    Widget? content,
    List<GWDialogAction> actions = const [],
    IconData? icon,
    bool barrierDismissible = true,
  }) {
    return showDialog<T>(
      context: context,
      barrierDismissible: barrierDismissible,
      barrierColor: context.gw.surfaceOverlay,
      builder: (_) => GWDialog(
        title: title,
        message: message,
        content: content,
        actions: actions,
        icon: icon,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Fail-soft read: registers the InheritedWidget dependency that forces
    // this widget to rebuild on a live appearance toggle.
    final gw = Theme.of(context).extension<GWColors>() ?? GWColors.dark();
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: const EdgeInsets.all(GeniusWalletConsts.space8),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 440),
        child: Container(
          padding: const EdgeInsets.all(GeniusWalletConsts.space10),
          decoration: BoxDecoration(
            gradient: GWDecorations.surfaceSheen,
            borderRadius: BorderRadius.circular(GeniusWalletConsts.radiusXl),
            boxShadow: GeniusWalletElevation.dialog,
            border: Border.all(color: gw.borderSubtle),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 32, color: context.gw.brandGreen),
                const SizedBox(height: GeniusWalletConsts.space6),
              ],
              Text(
                title,
                style: GeniusWalletTypography.titleLg,
                textAlign: icon != null ? TextAlign.center : TextAlign.start,
              ),
              if (message != null) ...[
                const SizedBox(height: GeniusWalletConsts.space4),
                Text(
                  message!,
                  style: GeniusWalletTypography.bodyMd.copyWith(
                    color: gw.textSecondary,
                  ),
                ),
              ],
              if (content != null) ...[
                const SizedBox(height: GeniusWalletConsts.space8),
                content!,
              ],
              if (actions.isNotEmpty) ...[
                const SizedBox(height: GeniusWalletConsts.space10),
                Wrap(
                  alignment: WrapAlignment.end,
                  spacing: GeniusWalletConsts.space4,
                  runSpacing: GeniusWalletConsts.space4,
                  children: actions
                      .map(
                        (a) => GWButton(
                          label: a.label,
                          onPressed: a.onPressed,
                          variant: a.variant,
                          isLoading: a.isLoading,
                        ),
                      )
                      .toList(),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class GWDialogAction {
  const GWDialogAction({
    required this.label,
    required this.onPressed,
    this.variant = GWButtonVariant.ghost,
    this.isLoading = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final GWButtonVariant variant;
  final bool isLoading;
}
