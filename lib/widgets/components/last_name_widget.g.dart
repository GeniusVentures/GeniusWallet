// *********************************************************************************
// PARABEAC-GENERATED CODE. DO NOT MODIFY.
//
// FOR MORE INFORMATION ON HOW TO USE PARABEAC, PLEASE VISIT docs.parabeac.com
// *********************************************************************************

import 'package:flutter/material.dart';
import 'package:genius_wallet/widgets/components/custom/last_name_logic.dart';
import 'package:genius_wallet/widgets/text_form_field_logic.g.dart';

class LastNameWidget extends StatelessWidget {
  final TextFormFieldLogic logic;

  LastNameWidget({
    Key? key,
    required this.logic,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      style: TextStyle(
        fontFamily: 'Roboto',
        fontSize: 12.0,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.30000001192092896,
        color: Color(0xff85858a),
      ),
      decoration: InputDecoration(
        hintText: logic.hintText,
        hintStyle: TextStyle(
          fontFamily: 'Roboto',
          fontSize: 12.0,
          fontWeight: FontWeight.w400,
          letterSpacing: 0.30000001192092896,
          color: Color(0xff85858a),
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
      textAlign: logic.textAlign,
      textAlignVertical: logic.textAlignVertical,
    );
  }
}
