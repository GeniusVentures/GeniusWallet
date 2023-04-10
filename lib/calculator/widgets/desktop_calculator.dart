import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genius_wallet/app/utils/formatters.dart';
import 'package:genius_wallet/calculator/bloc/calculator_bloc.dart';
import 'package:genius_wallet/calculator/bloc/calculator_event.dart';
import 'package:genius_wallet/calculator/bloc/calculator_state.dart';
import 'package:genius_wallet/calculator/widgets/calculator_numpad.dart';
import 'package:genius_wallet/widgets/components/currency_selector/mode_from.g.dart';
import 'package:genius_wallet/widgets/components/currency_selector/mode_to.g.dart';
import 'package:genius_wallet/widgets/components/enter_amount.g.dart';
import 'package:genius_wallet/widgets/desktop/desktop_conversion_result.g.dart';
import 'package:genius_wallet/widgets/desktop/transaction_arrows.g.dart';

class DesktopCalculator extends StatelessWidget {
  const DesktopCalculator({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            SizedBox(
              height: 120,
              width: 250,
              child: LayoutBuilder(
                builder: (BuildContext context, BoxConstraints constraints) {
                  return ModeFrom(constraints);
                },
              ),
            ),
            SizedBox(
              width: 80,
              height: 25,
              child: LayoutBuilder(
                builder: (BuildContext context, BoxConstraints constraints) {
                  return TransactionArrows(constraints);
                },
              ),
            ),
            SizedBox(
              height: 120,
              width: 250,
              child: LayoutBuilder(
                builder: (BuildContext context, BoxConstraints constraints) {
                  return ModeTo(constraints);
                },
              ),
            ),
          ],
        ),
        SizedBox(
          height: 120,
          child: LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
              return EnterAmount(constraints);
            },
          ),
        ),
        const SizedBox(height: 20),
        SizedBox(
          child: CalculatorNumpad(
            onNumPressed: (value) {
              final bloc = context.read<CalculatorBloc>();
              final newText = '${bloc.controller.text}$value';

              /// Need to manually format the text and update the [controller]'s [value].
              final formattedValue = Formatters.allowDecimals.formatEditUpdate(
                  bloc.controller.value,
                  bloc.controller.value.copyWith(text: newText));
              bloc.controller.value = formattedValue;

              /// Let [CalculatorBloc] know we have a new amount
              context
                  .read<CalculatorBloc>()
                  .add(AmountEntered(amount: formattedValue.text));
            },
            onClearPressed: () {
              context.read<CalculatorBloc>().add(ClearPressed());
            },
          ),
        ),
        const SizedBox(height: 20),
        SizedBox(
          height: 70,
          child: LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
              return BlocBuilder<CalculatorBloc, CalculatorState>(
                builder: (context, state) {
                  if (state.getResultStatus == CalculatorStatus.loading) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (state.conversionResult.isNotEmpty) {
                    return DesktopConversionResult(
                      constraints,
                      ovrResult:
                          '${state.conversionResult} ${state.currencyTo!.symbol}',
                      ovrAmountEntered:
                          '${state.amountToConvert} ${state.currencyFrom!.symbol}',
                    );
                  }
                  return const SizedBox();
                },
              );
            },
          ),
        )
      ],
    );
  }
}
