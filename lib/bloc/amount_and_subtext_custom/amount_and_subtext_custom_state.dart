abstract class AmountAndSubtextCustomState {
  var ovrAmount;
  var ovrText;

  AmountAndSubtextCustomState(
    this.ovrAmount,
    this.ovrText,
  );
}

/// TODO: @developer Add states that extend the abstract state above.
/// For example, if you are coding a counter, you may want to add something like:
///
/// class CounterInProgress extends CounterState{
///   CounterInProgress(int value): super(value);
/// }

class AmountAndSubtextCustomInitial extends AmountAndSubtextCustomState {
  AmountAndSubtextCustomInitial()
      : super(
          'Amount',
          'Text',
        );
}
