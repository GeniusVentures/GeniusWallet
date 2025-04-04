// *********************************************************************************
// PARABEAC-GENERATED CODE. DO NOT MODIFY.
//
// FOR MORE INFORMATION ON HOW TO USE PARABEAC, PLEASE VISIT docs.parabeac.com
// *********************************************************************************

import 'package:flutter/material.dart';
import 'package:genius_wallet/theme/genius_wallet_colors.g.dart';
import 'package:genius_wallet/theme/genius_wallet_consts.dart';
import 'package:genius_wallet/widgets/text_form_field_logic.g.dart';

class TextEntryFieldWidget extends StatelessWidget {
  final TextFormFieldLogic logic;

  const TextEntryFieldWidget({
    Key? key,
    required this.logic,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      style: const TextStyle(
        fontFamily: 'Roboto',
        fontSize: 14.0,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.0,
        color: Colors.white,
      ),
      decoration: InputDecoration(
          hintText: logic.hintText,
          hintStyle: const TextStyle(
            fontFamily: 'Roboto',
            fontSize: 14.0,
            fontWeight: FontWeight.w400,
            letterSpacing: 0.0,
            color: GeniusWalletColors.gray500,
          ),
          prefixIcon: null,
          focusedBorder: OutlineInputBorder(
            borderSide: const BorderSide(
              color: GeniusWalletColors.lightGreenPrimary,
              width: 1.0,
            ),
            borderRadius:
                BorderRadius.circular(GeniusWalletConsts.borderRadiusCard),
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: const BorderSide(
              color: GeniusWalletColors.borderGrey,
              width: 1.0,
            ),
            borderRadius:
                BorderRadius.circular(GeniusWalletConsts.borderRadiusCard),
          ),
          filled: true,
          fillColor: GeniusWalletColors.grayPrimary,
          suffixIcon: null,
          contentPadding: const EdgeInsets.all(16)),
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
