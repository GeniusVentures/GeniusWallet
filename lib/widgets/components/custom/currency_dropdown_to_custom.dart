import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genius_wallet/app/widgets/currency_dropdown.dart';
import 'package:genius_wallet/calculator/bloc/calculator_cubit.dart';
import 'package:genius_wallet/calculator/bloc/calculator_state.dart';
import 'package:genius_wallet/calculator/view/calculator_screen.dart';

class CurrencyDropdownToCustom extends StatefulWidget {
  final Widget? child;
  CurrencyDropdownToCustom({
    Key? key,
    this.child,
  }) : super(key: key);

  @override
  _CurrencyDropdownToCustomState createState() =>
      _CurrencyDropdownToCustomState();
}

class _CurrencyDropdownToCustomState extends State<CurrencyDropdownToCustom> {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CalculatorCubit, CalculatorState>(
      builder: (context, state) {
        return CurrencyDropdown(
          currencies: state.currencies,
          onChanged: context.read<CalculatorCubit>().toCurrencySelected,
          value: state.currencyTo,
        );
      },
    );
  }
}
