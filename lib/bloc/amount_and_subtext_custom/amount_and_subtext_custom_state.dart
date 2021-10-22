import 'package:intl/intl.dart';

abstract class AmountAndSubtextCustomState {
  double Amount;
  String SubText;

  String GetAmount() {
    if (Amount == null)
      return '';

    NumberFormat formatter = NumberFormat();
    formatter.minimumFractionDigits = 1;
    formatter.maximumFractionDigits = 7;
    return formatter.format(Amount);
  }

}

/// TODO: @developer Add states that extend the abstract state above.
/// For example, if you are coding a counter, you may want to add something like:
///
/// class CounterInProgress extends CounterState{
///   CounterInProgress(int value): super(value);
/// }

class AmountAndSubtextCustomInitial extends AmountAndSubtextCustomState {

  AmountAndSubtextCustomInitial() {
    Amount = 1000.0000001000;
    SubText = "Ethereum";
  }

}
