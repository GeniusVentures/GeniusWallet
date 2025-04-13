import 'package:flutter/material.dart';
import 'package:genius_wallet/theme/genius_wallet_colors.g.dart';
import 'package:genius_wallet/theme/genius_wallet_font_size.dart';
import 'package:genius_wallet/components/custom/type_existing_custom.dart';
import 'package:auto_size_text/auto_size_text.dart';

class TypeExisting extends StatefulWidget {
  final BoxConstraints constraints;
  final String? ovrIalreadyhaveawallet;

  const TypeExisting(
    this.constraints, {
    Key? key,
    this.ovrIalreadyhaveawallet,
  }) : super(key: key);

  @override
  _TypeExisting createState() => _TypeExisting();
}

class _TypeExisting extends State<TypeExisting> {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(48),
        border: Border.all(
          width: 1.0,
          color: GeniusWalletColors.lightGreenPrimary,
        ),
      ),
      child: TypeExistingCustom(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
            child: AutoSizeText(
              widget.ovrIalreadyhaveawallet ?? 'I already have a wallet',
              style: const TextStyle(
                fontFamily: 'Roboto',
                fontSize: GeniusWalletFontSize.base,
                fontWeight: FontWeight.w400,
                letterSpacing: 0.1375,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
              maxLines: 1, // Ensures no line breaks
              minFontSize: 12, // Minimum readable font size
              overflow:
                  TextOverflow.ellipsis, // Show ellipsis if text overflows
            ),
          ),
        ),
      ),
    );
  }
}
