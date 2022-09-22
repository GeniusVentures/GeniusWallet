// *********************************************************************************
// PARABEAC-GENERATED CODE. DO NOT MODIFY.
//
// FOR MORE INFORMATION ON HOW TO USE PARABEAC, PLEASE VISIT docs.parabeac.com
// *********************************************************************************

import 'package:flutter/material.dart';
import 'package:genius_wallet/widgets/components/custom/text_entry_field_logic.dart';
import 'package:genius_wallet/widgets/text_form_field_logic.g.dart';

class TextEntryFieldWidget extends StatelessWidget {
  late final TextFormFieldLogic _logic;

  TextEntryFieldWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    _logic = TextEntryFieldLogic(context);
    return TextFormField(
      style: TextStyle(
        fontFamily: 'Roboto',
        fontSize: 14.0,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.0,
        color: Colors.white,
      ),
      decoration: InputDecoration(
        hintText: _logic.hintText,
        hintStyle: TextStyle(
          fontFamily: 'Roboto',
          fontSize: 14.0,
          fontWeight: FontWeight.w400,
          letterSpacing: 0.0,
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
      controller: _logic.controller,
      initialValue: _logic.initialValue,
      keyboardType: _logic.keyboardType,
      textCapitalization: _logic.textCapitalization,
      autofocus: _logic.autofocus,
      readOnly: _logic.readOnly,
      obscureText: _logic.obscureText,
      maxLengthEnforcement: _logic.maxLengthEnforcement,
      minLines: _logic.minLines,
      maxLines: _logic.maxLines,
      expands: _logic.expands,
      maxLength: _logic.maxLength,
      onChanged: _logic.onChanged,
      onTap: _logic.onTap,
      onEditingComplete: _logic.onEditingComplete,
      onFieldSubmitted: _logic.onFieldSubmitted,
      onSaved: _logic.onSaved,
      validator: _logic.validator,
      inputFormatters: _logic.inputFormatters,
      enabled: _logic.enabled,
      scrollPhysics: _logic.scrollPhysics,
      autovalidateMode: _logic.autovalidateMode,
      scrollController: _logic.scrollController,
    );
  }
}
