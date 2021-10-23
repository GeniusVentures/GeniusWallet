abstract class BuyButtonCustomState {
  var ovrBuy;
  var ovrVector;

  BuyButtonCustomState(
    this.ovrBuy,
    this.ovrVector,
  );
}

/// TODO: @developer Add states that extend the abstract state above.
/// For example, if you are coding a counter, you may want to add something like:
///
/// class CounterInProgress extends CounterState{
///   CounterInProgress(int value): super(value);
/// }

class BuyButtonCustomInitial extends BuyButtonCustomState {
  BuyButtonCustomInitial()
      : super(
          'Buy',
          'Vector',
        );
}
