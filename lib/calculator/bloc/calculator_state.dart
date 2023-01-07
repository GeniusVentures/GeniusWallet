import 'package:equatable/equatable.dart';
import 'package:genius_api/genius_api.dart';

class CalculatorState extends Equatable {
  final List<Currency> currencies;

  final Currency? currencyFrom;

  final Currency? currencyTo;

  final CalculatorStatus getCurrenciesStatus;

  const CalculatorState({
    this.currencyFrom,
    this.currencyTo,
    this.currencies = const [],
    this.getCurrenciesStatus = CalculatorStatus.initial,
  });

  CalculatorState copyWith({
    List<Currency>? currencies,
    Currency? currencyFrom,
    Currency? currencyTo,
    CalculatorStatus? getCurrenciesStatus,
  }) {
    return CalculatorState(
      currencies: currencies ?? this.currencies,
      currencyFrom: currencyFrom ?? this.currencyFrom,
      currencyTo: currencyTo ?? this.currencyTo,
      getCurrenciesStatus: getCurrenciesStatus ?? this.getCurrenciesStatus,
    );
  }

  @override
  List<Object?> get props => [
        currencyFrom,
        currencyTo,
        currencies,
        getCurrenciesStatus,
      ];
}

enum CalculatorStatus { initial, loading, loaded, error }
