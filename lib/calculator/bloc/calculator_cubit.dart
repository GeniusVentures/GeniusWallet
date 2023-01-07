import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genius_api/genius_api.dart';
import 'package:genius_wallet/calculator/bloc/calculator_state.dart';

class CalculatorCubit extends Cubit<CalculatorState> {
  final GeniusApi geniusApi;
  CalculatorCubit({
    CalculatorState initialState = const CalculatorState(),
    required this.geniusApi,
  }) : super(initialState);

  void fromCurrencySelected(Currency currency) {
    emit(state.copyWith(
      currencyFrom: currency,
    ));
  }

  void toCurrencySelected(Currency currency) {
    emit(state.copyWith(
      currencyTo: currency,
    ));
  }

  Future<void> amountEntered(String amount) async {}

  Future<void> getCurrencies() async {
    emit(state.copyWith(getCurrenciesStatus: CalculatorStatus.loading));

    try {
      final currencies = await geniusApi.getCalculatorCurrencies();
      emit(state.copyWith(
        getCurrenciesStatus: CalculatorStatus.loaded,
        currencies: currencies,
      ));
    } catch (e) {
      emit(state.copyWith(getCurrenciesStatus: CalculatorStatus.error));
    }
  }
}
