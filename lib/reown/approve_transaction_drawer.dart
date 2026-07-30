import 'package:flutter/material.dart';
import 'package:genius_wallet/components/bottom_drawer/responsive_drawer.dart';
import 'package:genius_wallet/components/buttons/gw_button.dart';
import 'package:genius_wallet/theme/genius_wallet_consts.dart';
import 'package:genius_wallet/theme/genius_wallet_typography.dart';
import 'package:genius_wallet/theme/gw_context_extension.dart';

class ApproveTransactionDrawer {
  static Future<bool?> show({
    required BuildContext context,
    required Widget content,
    required String dappName,
    required String dappUrl,
    String? iconUrl,
  }) async {
    final gw = context.gw;
    return ResponsiveDrawer.show<bool>(
      context: context,
      title: "Transaction Request",
      child: ListView(
        children: [
          // `Flexible(child: content)` below needs a Flex ancestor -- a bare
          // `ListView.children` list is a sliver list, not a Flex, so this
          // Column (not the deleted zero-inset Padding) is what the shell's
          // single scrolling body item actually is.
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 033-B1: the dApp identity is borderless -- favicon, url, a
              // hairline under it, no pill, no box. The bordered Container
              // this used to sit in is gone.
              Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(999),
                    // The errorBuilder collapsing to nothing is a mitigation
                    // (T-21-12), not decoration: it stops a hostile dApp
                    // placing a broken-image glyph or an oversized
                    // failed-load box on a signing prompt.
                    child: Image.network(
                      iconUrl ?? "",
                      height: 24,
                      width: 24,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return const SizedBox.shrink();
                      },
                    ),
                  ),
                  const SizedBox(width: GeniusWalletConsts.space6),
                  Flexible(
                    child: Text(
                      dappUrl,
                      style: GeniusWalletTypography.bodyMd.copyWith(
                        color: gw.textSecondary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: GeniusWalletConsts.space4),
              Container(height: 1, color: gw.borderSubtle),
              const SizedBox(height: GeniusWalletConsts.space6),
              // `content` is caller-supplied (`handle_dapp_requests.dart:116`)
              // and must keep rendering whatever it is handed, including the
              // debug-dump branch -- this drawer does not know or care which.
              Flexible(fit: FlexFit.loose, child: content),
            ],
          ),
        ],
      ),
      footer: Row(
        children: [
          Expanded(
            child: GWButton(
              label: "Reject",
              variant: GWButtonVariant.gradientOutline,
              size: GWButtonSize.lg,
              expand: true,
              onPressed: () => Navigator.of(context).pop(false),
            ),
          ),
          const SizedBox(width: GeniusWalletConsts.space6),
          Expanded(
            child: GWButton(
              label: "Approve",
              variant: GWButtonVariant.gradient,
              size: GWButtonSize.lg,
              expand: true,
              onPressed: () => Navigator.of(context).pop(true),
            ),
          ),
        ],
      ),
    );
  }
}
