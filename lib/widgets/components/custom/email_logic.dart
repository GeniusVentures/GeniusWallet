import 'package:flutter/material.dart';
import 'package:genius_wallet/widgets/text_form_field_logic.g.dart';

class EmailLogic extends TextFormFieldLogic {
  EmailLogic(BuildContext context) : super(context);

  /// TODO: Override any logic method here. See example below
  /// See [TextFormFieldLogic] for overridable methods.
  @override
  ValueChanged<String>? get onChanged => (value) {
        //print('Value changed to $value');
      };

  @override
  String get hintText => 'Enter email';
}
