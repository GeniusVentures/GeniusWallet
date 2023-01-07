import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genius_wallet/app/widgets/currency_dropdown.dart';
import 'package:genius_wallet/calculator/bloc/calculator_cubit.dart';
import 'package:genius_wallet/calculator/bloc/calculator_state.dart';

class CurrencyDropdownFromCustom extends StatefulWidget {
  final Widget? child;
  CurrencyDropdownFromCustom({
    Key? key,
    this.child,
  }) : super(key: key);

  @override
  _CurrencyDropdownFromCustomState createState() =>
      _CurrencyDropdownFromCustomState();
}

class _CurrencyDropdownFromCustomState
    extends State<CurrencyDropdownFromCustom> {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CalculatorCubit, CalculatorState>(
      builder: (context, state) {
        return CurrencyDropdown(
          currencies: state.currencies,
          onChanged: context.read<CalculatorCubit>().fromCurrencySelected,
          value: state.currencyFrom,
        );
      },
    );
  }
}
