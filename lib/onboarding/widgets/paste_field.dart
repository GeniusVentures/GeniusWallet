import 'package:clipboard/clipboard.dart';
import 'package:flutter/material.dart';
import 'package:genius_wallet/components/buttons/gw_button.dart';
import 'package:genius_wallet/theme/genius_wallet_colors.dart';
import 'package:genius_wallet/theme/genius_wallet_consts.dart';
import 'package:genius_wallet/theme/genius_wallet_text.dart';
import 'package:genius_wallet/theme/genius_wallet_typography.dart';

class PasteField extends StatelessWidget {
  final String hintText;
  final Widget? additionalWidget;
  final String subtitle;
  final TextEditingController controller;
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          decoration: BoxDecoration(
            color: GeniusWalletColors.surfaceElevated,
            border: Border.all(color: GeniusWalletColors.borderSubtle),
            borderRadius:
                BorderRadius.circular(GeniusWalletConsts.radius2xl),
          ),
          width: MediaQuery.of(context).size.width * 0.9,
          height: height,
          child: Stack(
            children: [
              Padding(
                padding:
                    const EdgeInsets.all(GeniusWalletConsts.space6),
                child: TextFormField(
                  controller: controller,
                  style: GeniusWalletTypography.bodyLg,
                  cursorColor: GeniusWalletColors.brandPrimary,
                  decoration: InputDecoration(
                    isCollapsed: true,
                    border: InputBorder.none,
                    hintText: hintText,
                    hintStyle: GeniusWalletTypography.bodyLg.copyWith(
                      color: GeniusWalletColors.textSecondary,
                    ),
                  ),
                  minLines: 10,
                  maxLines: 10,
                ),
              ),
              Positioned(
                bottom: GeniusWalletConsts.space4,
                right: GeniusWalletConsts.space4,
                child: GWButton(
                  label: GeniusWalletText.btnPaste,
                  leading: const Icon(Icons.content_copy),
                  variant: GWButtonVariant.secondary,
                  size: GWButtonSize.sm,
                  onPressed: () async {
                    final textValue = await FlutterClipboard.paste();
                    controller.text = textValue;
                  },
                ),
              ),
            ],
          ),
        ),
        if (additionalWidget != null) ...[
          const SizedBox(height: GeniusWalletConsts.space10),
          additionalWidget!,
        ],
        const SizedBox(height: GeniusWalletConsts.space10),
        SizedBox(
          width: MediaQuery.of(context).size.width,
          child: Text(
            subtitle,
            textAlign: TextAlign.left,
            style: GeniusWalletTypography.bodySm,
          ),
        ),
      ],
    );
  }
}
