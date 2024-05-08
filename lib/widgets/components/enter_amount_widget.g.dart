import 'package:flutter/material.dart';
import 'package:genius_wallet/theme/genius_wallet_colors.g.dart';
import 'package:genius_wallet/theme/genius_wallet_consts.dart';
import 'package:genius_wallet/widgets/components/custom/enter_amount_logic.dart';
import 'package:genius_wallet/widgets/text_form_field_logic.g.dart';

class EnterAmountWidget extends StatelessWidget {
  final TextFormFieldLogic logic;

  EnterAmountWidget({
    Key? key,
    required this.logic,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      style: TextStyle(
        fontFamily: 'Roboto',
        fontSize: 20.0,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.3,
        color: Colors.white,
      ),
      decoration: InputDecoration(
        hintText: logic.hintText,
        hintStyle: TextStyle(
          fontFamily: 'Roboto',
          fontSize: 20,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.3,
          color: Colors.white,
        ),
        prefixIcon: null,
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: GeniusWalletColors.containerGray,
            width: 1.0,
          ),
          borderRadius:
              BorderRadius.circular(GeniusWalletConsts.borderRadiusCard),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: GeniusWalletColors.containerGray,
            width: 1.0,
          ),
          borderRadius:
              BorderRadius.circular(GeniusWalletConsts.borderRadiusCard),
        ),
        filled: true,
        fillColor: GeniusWalletColors.containerGray,
        suffixIcon: null,
      ),
      controller: logic.controller,
      initialValue: logic.initialValue,
      keyboardType: logic.keyboardType,
      textCapitalization: logic.textCapitalization,
      autofocus: logic.autofocus,
      readOnly: logic.readOnly,
      obscureText: logic.obscureText,
      maxLengthEnforcement: logic.maxLengthEnforcement,
      minLines: logic.minLines,
      maxLines: logic.maxLines,
      expands: logic.expands,
      maxLength: logic.maxLength,
      onChanged: logic.onChanged,
      onTap: logic.onTap,
      onEditingComplete: logic.onEditingComplete,
      onFieldSubmitted: logic.onFieldSubmitted,
      onSaved: logic.onSaved,
      validator: logic.validator,
      inputFormatters: logic.inputFormatters,
      enabled: logic.enabled,
      scrollPhysics: logic.scrollPhysics,
      autovalidateMode: logic.autovalidateMode,
      scrollController: logic.scrollController,
      textAlign: logic.textAlign,
      textAlignVertical: logic.textAlignVertical,
    );
  }
}
