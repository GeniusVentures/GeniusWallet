abstract class BuyCryptoButtonCustomState {
  var ovrTypesomething;
  var ovrTypesomethingCopy;
  var ovrRectangle2;

  BuyCryptoButtonCustomState(
    this.ovrTypesomething,
    this.ovrTypesomethingCopy,
    this.ovrRectangle2,
  );
}

/// TODO: @developer Add states that extend the abstract state above.
/// For example, if you are coding a counter, you may want to add something like:
///
/// class CounterInProgress extends CounterState{
///   CounterInProgress(int value): super(value);
/// }

class BuyCryptoButtonCustomInitial extends BuyCryptoButtonCustomState {
  BuyCryptoButtonCustomInitial()
      : super(
          'Type something',
          'Type something Copy',
          'Rectangle 2',
        );
}
