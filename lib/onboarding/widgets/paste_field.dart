import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:genius_wallet/components/buttons/gw_button.dart';
import 'package:genius_wallet/theme/genius_wallet_colors.dart';
import 'package:genius_wallet/theme/genius_wallet_consts.dart';
import 'package:genius_wallet/theme/genius_wallet_decorations.dart';
import 'package:genius_wallet/theme/genius_wallet_typography.dart';
import 'package:genius_wallet/theme/gw_colors.dart';

class PasteField extends StatelessWidget {
  final String hintText;
  final Widget? additionalWidget;
  final String subtitle;
  final TextEditingController controller;

  /// DECLARED BUT DELIBERATELY UNREAD — see 06-04 §1.
  ///
  /// The address tab passes `height: 150` and it has never had any effect.
  /// Wiring it into the container below would be a layout change smuggled in
  /// under a re-skin. Left inert on purpose; 06-06 files a todo to either wire
  /// it or remove it.
  final double height;

  const PasteField({
    super.key,
    this.additionalWidget,
    this.subtitle = '',
    this.hintText = '',
    this.height = 200,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    final gw = Theme.of(context).extension<GWColors>() ?? GWColors.dark();

    return Column(
      spacing: 16.0,
      children: [
        Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                gradient: GWDecorations.surfaceSheen,
                border: Border.all(color: gw.borderSubtle),
                borderRadius: BorderRadius.circular(
                  GeniusWalletConsts.radius2xl,
                ),
              ),
              child: TextFormField(
                controller: controller,
                // SECURITY (06-04 §3.6) — this is where a user types or pastes
                // an EXISTING mnemonic or private key. Flutter defaults all
                // three booleans to true and textCapitalization to sentences,
                // which hands key material to the OS predictive-text,
                // spell-check, capitalization-assist and IME-learning stores.
                //
                // enableIMEPersonalizedLearning is the load-bearing one: it,
                // not autocorrect, maps to Android's
                // IME_FLAG_NO_PERSONALIZED_LEARNING — the actual switch on the
                // keyboard's learning store. Shipping the other three without
                // it looks hardened while leaving the real leak open.
                //
                // autofillHints is deliberately NOT set; its null default is
                // already correct for key material.
                autocorrect: false,
                enableSuggestions: false,
                enableIMEPersonalizedLearning: false,
                textCapitalization: TextCapitalization.none,
                style: GeniusWalletTypography.bodyLg,
                cursorColor: GeniusWalletColors.brandPrimary,
                decoration: InputDecoration(
                  hintText: hintText,
                  hintStyle: GeniusWalletTypography.bodyLg.copyWith(
                    color: gw.textSecondary,
                  ),
                ),
                minLines: 4,
                maxLines: 10,
              ),
            ),
            Positioned(
              bottom: 10,
              right: 10,
              child: GWButton(
                label: 'Paste',
                leading: const Icon(Icons.content_copy),
                variant: GWButtonVariant.secondary,
                size: GWButtonSize.sm,
                onPressed: () async {
                  final textValue =
                      (await Clipboard.getData(Clipboard.kTextPlain))?.text ??
                      "";
                  controller.text = textValue;
                },
              ),
            ),
          ],
        ),
        ?additionalWidget,
        ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.sizeOf(context).width,
          ),
          child: Text(
            subtitle,
            textAlign: TextAlign.left,
            style: GeniusWalletTypography.bodySm.copyWith(
              color: gw.textSecondary,
            ),
          ),
        ),
      ],
    );
  }
}
