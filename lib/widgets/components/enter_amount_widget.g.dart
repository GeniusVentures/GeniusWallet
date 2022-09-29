// *********************************************************************************
// PARABEAC-GENERATED CODE. DO NOT MODIFY.
//
// FOR MORE INFORMATION ON HOW TO USE PARABEAC, PLEASE VISIT docs.parabeac.com
// *********************************************************************************

import 'package:flutter/material.dart';
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
        fontSize: 30.0,
        fontWeight: FontWeight.w300,
        letterSpacing: 0.45000001788139343,
        color: Colors.white,
      ),
      decoration: InputDecoration(
        hintText: logic.hintText,
        hintStyle: TextStyle(
          fontFamily: 'Roboto',
          fontSize: 30.0,
          fontWeight: FontWeight.w300,
          letterSpacing: 0.45000001788139343,
          color: Colors.white,
        ),
        prefixIcon: null,
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: Color(
              0x00ffffff,
            ),
            width: 1.0,
          ),
          borderRadius: BorderRadius.circular(1),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: Color(
              0x00ffffff,
            ),
            width: 1.0,
          ),
          borderRadius: BorderRadius.circular(1),
        ),
        filled: true,
        fillColor: Color(0xff2a2b31),
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
    );
  }
}
