import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genius_wallet/app/utils/formatters.dart';
import 'package:genius_wallet/calculator/bloc/calculator_bloc.dart';
import 'package:genius_wallet/calculator/bloc/calculator_event.dart';
import 'package:genius_wallet/widgets/text_form_field_logic.g.dart';

class EnterAmountLogic extends TextFormFieldLogic {
  EnterAmountLogic(BuildContext context) : super(context);

  @override
  ValueChanged<String>? get onChanged => ((value) {
        context.read<CalculatorBloc>().add(AmountEntered(amount: value));
      });

  @override
  TextEditingController? get controller =>
      context.read<CalculatorBloc>().controller;

  @override
  List<TextInputFormatter>? get inputFormatters => [Formatters.allowDecimals];

  @override
  String get hintText => '0.000000000000';

  @override
  TextInputType? get keyboardType => const TextInputType.numberWithOptions(
        decimal: true,
      );
}
