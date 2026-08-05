import 'package:flutter/material.dart';
import 'package:genius_wallet/components/bottom_drawer/responsive_drawer.dart';
import 'package:genius_wallet/components/buttons/gw_button.dart';
import 'package:genius_wallet/theme/genius_wallet_consts.dart';
import 'package:genius_wallet/theme/genius_wallet_typography.dart';
import 'package:genius_wallet/theme/gw_context_extension.dart';

class ApproveDappConnectionDrawer {
  static Future<bool?> show({
    required BuildContext context,
    required String dappName,
    required String dappUrl,
    String? dappDescription,
    String? iconUrl,
  }) {
    final gw = context.gw;
    return ResponsiveDrawer.show<bool>(
      context: context,
      title: "Connection Request",
      child: ListView(
        children: [
          // 033-B1: the dApp identity is borderless -- favicon, name over url,
          // a hairline under it, no pill, no box. The Container this used to
          // sit in only ever supplied padding (never a border); it is gone and
          // the shell's own inset does that job now.
          Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(999),
                // The errorBuilder collapsing to nothing is a mitigation
                // (T-21-12), not decoration: it stops a hostile dApp placing a
                // broken-image glyph or an oversized failed-load box on a
                // signing prompt.
                child: Image.network(
                  iconUrl ?? "",
                  height: 28,
                  width: 28,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return const SizedBox.shrink();
                  },
                ),
              ),
              const SizedBox(width: GeniusWalletConsts.space6),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      dappName,
                      style: GeniusWalletTypography.titleMd.copyWith(
                        color: gw.textPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      dappUrl,
                      style: GeniusWalletTypography.bodySm.copyWith(
                        color: gw.textSecondary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: GeniusWalletConsts.space4),
          Container(height: 1, color: gw.borderSubtle),
          const SizedBox(height: GeniusWalletConsts.space10),
          if (dappDescription != null && dappDescription.isNotEmpty) ...[
            Text(
              dappDescription,
              style: GeniusWalletTypography.bodySm.copyWith(
                color: gw.textPrimary70,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: GeniusWalletConsts.space6),
          ],
          // Moved from the footer (a footer holds actions, not a question) --
          // dappName is remote and unbounded, so it stays ellipsised with a
          // 2-line cap rather than pushing the buttons off screen (T-21-13).
          Text(
            "Allow $dappName to connect to your wallet?",
            style: GeniusWalletTypography.bodyMd.copyWith(
              color: gw.textPrimary,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
      footer: Row(
        children: [
          Expanded(
            child: GWButton(
              label: "Deny",
              variant: GWButtonVariant.gradientOutline,
              size: GWButtonSize.lg,
              expand: true,
              onPressed: () => Navigator.of(context).pop(false),
            ),
          ),
          const SizedBox(width: GeniusWalletConsts.space6),
          Expanded(
            child: GWButton(
              label: "Allow",
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
