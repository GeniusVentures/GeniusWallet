import 'package:equatable/equatable.dart';
import 'package:genius_api/genius_api.dart';

class CalculatorState extends Equatable {
  final List<Currency> currencies;

  final Currency? currencyFrom;

  final Currency? currencyTo;

  final CalculatorStatus getCurrenciesStatus;

  final CalculatorStatus getResultStatus;

  final String amountToConvert;

  final String conversionResult;

  const CalculatorState({
    this.currencyFrom,
    this.currencyTo,
    this.currencies = const [],
    this.getCurrenciesStatus = CalculatorStatus.initial,
    this.getResultStatus = CalculatorStatus.initial,
    this.amountToConvert = '0',
    this.conversionResult = '',
  });

  CalculatorState copyWith({
    List<Currency>? currencies,
    Currency? currencyFrom,
    Currency? currencyTo,
    CalculatorStatus? getCurrenciesStatus,
    CalculatorStatus? getResultStatus,
    String? amountToConvert,
    String? conversionResult,
  }) {
    return CalculatorState(
      currencies: currencies ?? this.currencies,
      currencyFrom: currencyFrom ?? this.currencyFrom,
      currencyTo: currencyTo ?? this.currencyTo,
      getCurrenciesStatus: getCurrenciesStatus ?? this.getCurrenciesStatus,
      amountToConvert: amountToConvert ?? this.amountToConvert,
      getResultStatus: getResultStatus ?? this.getResultStatus,
      conversionResult: conversionResult ?? this.conversionResult,
    );
  }

  @override
  List<Object?> get props => [
        currencyFrom,
        currencyTo,
        currencies,
        getCurrenciesStatus,
        getResultStatus,
        amountToConvert,
        conversionResult,
      ];
}

enum CalculatorStatus { initial, loading, loaded, error }
