import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:genius_wallet/components/buttons/gw_button.dart';
import 'package:genius_wallet/theme/genius_wallet_consts.dart';
import 'package:genius_wallet/theme/genius_wallet_decorations.dart';
import 'package:genius_wallet/theme/genius_wallet_typography.dart';
import 'package:genius_wallet/theme/gw_colors.dart';
import 'package:genius_wallet/theme/gw_context_extension.dart';

/// A paste target for sensitive text. Pass [obscure] for key material
/// (recovery phrase, private key): it then renders as dots behind the same
/// show/hide control the password fields use, and the words are never on
/// screen unless the user asks for them.
class PasteField extends StatefulWidget {
  final String hintText;
  final Widget? additionalWidget;
  final String subtitle;
  final TextEditingController controller;
  final bool obscure;

  const PasteField({
    super.key,
    this.additionalWidget,
    this.subtitle = '',
    this.hintText = '',
    required this.controller,
    this.obscure = false,
  });

  @override
  State<PasteField> createState() => _PasteFieldState();
}

class _PasteFieldState extends State<PasteField> {
  late bool _obscured = widget.obscure;

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
                controller: widget.controller,
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
                obscureText: _obscured,
                style: GeniusWalletTypography.bodyLg,
                cursorColor: context.gw.brandPrimary,
                decoration: InputDecoration(
                  hintText: widget.hintText,
                  hintStyle: GeniusWalletTypography.bodyLg.copyWith(
                    color: gw.textSecondary,
                  ),
                ),
                // Obscured fields must be single-line, so the dots view is a
                // compact strip; Show returns the multiline layout.
                minLines: _obscured ? 1 : 4,
                maxLines: _obscured ? 1 : 10,
              ),
            ),
            Positioned(
              bottom: 10,
              right: 10,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                spacing: 4.0,
                children: [
                  if (widget.obscure)
                    IconButton(
                      tooltip: _obscured ? 'Show' : 'Hide',
                      icon: Icon(
                        _obscured
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                        size: 20,
                        color: gw.textSecondary,
                      ),
                      onPressed: () => setState(() {
                        _obscured = !_obscured;
                      }),
                    ),
                  GWButton(
                    label: 'Paste',
                    leading: const Icon(Icons.content_copy),
                    variant: GWButtonVariant.secondary,
                    size: GWButtonSize.sm,
                    onPressed: () async {
                      final textValue =
                          (await Clipboard.getData(
                            Clipboard.kTextPlain,
                          ))?.text ??
                          "";
                      widget.controller.text = textValue;
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
        ?widget.additionalWidget,
        ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.sizeOf(context).width,
          ),
          child: Text(
            widget.subtitle,
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
