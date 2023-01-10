import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genius_api/genius_api.dart';
import 'package:genius_wallet/calculator/bloc/calculator_event.dart';
import 'package:genius_wallet/calculator/bloc/calculator_state.dart';

class CalculatorBloc extends Bloc<CalculatorEvent, CalculatorState> {
  final GeniusApi geniusApi;
  CalculatorBloc({
    CalculatorState initialState = const CalculatorState(),
    required this.geniusApi,
  }) : super(initialState) {
    on<FromCurrencySelected>(_onfromCurrencySelected);
    on<ToCurrencySelected>(_onToCurrencySelected);
    on<AmountEntered>(
      _onAmountEntered,
      transformer: restartable(),
    );
    on<GetCurrencies>(_onGetCurrencies);
  }

  bool _canRunConversion(CalculatorState state) =>
      state.currencyFrom != null && state.currencyTo != null;

  /// Runs a conversion from [state.currencyFrom] to [state.currencyTo] and
  /// emits a new state.
  Future<void> _runConversion(CalculatorState state, Emitter emit) async {
    if (_canRunConversion(state)) {
      emit(state.copyWith(getResultStatus: CalculatorStatus.loading));

      try {
        final result = await geniusApi.convertCurrencies(
          fromCurrency: state.currencyFrom!,
          toCurrency: state.currencyTo!,
        );

        emit(state.copyWith(
          getResultStatus: CalculatorStatus.loaded,
          conversionResult: result,
        ));
      } catch (e) {
        emit(state.copyWith(getResultStatus: CalculatorStatus.error));
      }
    }
  }

  Future<void> _onfromCurrencySelected(
      FromCurrencySelected event, Emitter emit) async {
    final newState = state.copyWith(
      currencyFrom: event.currency,
    );
    emit(newState);

    await _runConversion(newState, emit);
  }

  Future<void> _onToCurrencySelected(
      ToCurrencySelected event, Emitter emit) async {
    final newState = state.copyWith(
      currencyTo: event.currency,
    );
    emit(newState);

    await _runConversion(newState, emit);
  }

  Future<void> _onAmountEntered(AmountEntered event, Emitter emit) async {
    final newState = state.copyWith(
      amountToConvert: event.amount,
    );
    emit(newState);

    await _runConversion(newState, emit);
  }

  Future<void> _onGetCurrencies(GetCurrencies event, Emitter emit) async {
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
