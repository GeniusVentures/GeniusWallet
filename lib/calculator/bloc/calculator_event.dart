import 'package:genius_api/genius_api.dart';

abstract class CalculatorEvent {}

class FromCurrencySelected extends CalculatorEvent {
  final Currency currency;

  FromCurrencySelected({required this.currency});
}

class ToCurrencySelected extends CalculatorEvent {
  final Currency currency;

  ToCurrencySelected({required this.currency});
}

class AmountEntered extends CalculatorEvent {
  final String amount;

  AmountEntered({required this.amount});
}

class GetCurrencies extends CalculatorEvent {}

class ClearPressed extends CalculatorEvent {}
