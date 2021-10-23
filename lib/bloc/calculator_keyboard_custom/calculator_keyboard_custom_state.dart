abstract class CalculatorKeyboardCustomState {
  var ovr9;
  var ovr0;
  var ovr;
  var ovr8;
  var ovr7;
  var ovr6;
  var ovr5;
  var ovr4;
  var ovr3;
  var ovr2;
  var ovr1;

  CalculatorKeyboardCustomState(
    this.ovr9,
    this.ovr0,
    this.ovr,
    this.ovr8,
    this.ovr7,
    this.ovr6,
    this.ovr5,
    this.ovr4,
    this.ovr3,
    this.ovr2,
    this.ovr1,
  );
}

/// TODO: @developer Add states that extend the abstract state above.
/// For example, if you are coding a counter, you may want to add something like:
///
/// class CounterInProgress extends CounterState{
///   CounterInProgress(int value): super(value);
/// }

class CalculatorKeyboardCustomInitial extends CalculatorKeyboardCustomState {
  CalculatorKeyboardCustomInitial()
      : super(
          '9',
          '0',
          '.',
          '8',
          '7',
          '6',
          '5',
          '4',
          '3',
          '2',
          '1',
        );
}
