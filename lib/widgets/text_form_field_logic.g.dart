// *********************************************************************************
// PARABEAC-GENERATED CODE. DO NOT MODIFY.
//
// FOR MORE INFORMATION ON HOW TO USE PARABEAC, PLEASE VISIT docs.parabeac.com
// *********************************************************************************

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Class that serves as a base for all logic classes that are used by the TextField widget.
///
/// The use of this class is that it provides a common interface for all logic classes that are used by the TextField widget.
/// Therefore, any developer-owned TextField widget can extend the specific logic that it needs.
class TextFormFieldLogic {
  TextFormFieldLogic(
    this.context, {
    this.controller,
    this.initialValue,
    this.keyboardType,
    this.textCapitalization = TextCapitalization.none,
    this.autofocus = false,
    this.readOnly = false,
    this.obscureText = false,
    this.maxLengthEnforcement,
    this.minLines,
    this.maxLines = 1,
    this.expands = false,
    this.maxLength,
    this.onChanged,
    this.onTap,
    this.onEditingComplete,
    this.onFieldSubmitted,
    this.onSaved,
    this.validator,
    this.inputFormatters,
    this.enabled,
    this.scrollPhysics,
    this.autovalidateMode,
    this.scrollController,
    this.hintText = '',
    this.textAlign = TextAlign.start,
    this.textAlignVertical,
  });

  final BuildContext context;

  final TextEditingController? controller;

  final String? initialValue;

  final TextInputType? keyboardType;

  final TextCapitalization textCapitalization;

  final bool autofocus;

  final bool readOnly;

  final bool obscureText;

  final MaxLengthEnforcement? maxLengthEnforcement;

  final int? minLines;

  final int? maxLines;

  final bool expands;

  final int? maxLength;

  final ValueChanged<String>? onChanged;

  final GestureTapCallback? onTap;

  final VoidCallback? onEditingComplete;

  final ValueChanged<String>? onFieldSubmitted;

  final FormFieldSetter<String>? onSaved;

  final FormFieldValidator<String>? validator;

  final List<TextInputFormatter>? inputFormatters;

  final bool? enabled;

  final ScrollPhysics? scrollPhysics;

  final AutovalidateMode? autovalidateMode;

  final ScrollController? scrollController;

  final String hintText;

  final TextAlign textAlign;

  final TextAlignVertical? textAlignVertical;
}
