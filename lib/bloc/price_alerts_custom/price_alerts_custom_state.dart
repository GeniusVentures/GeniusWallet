abstract class PriceAlertsCustomState {
  var ovrTypesomething;
  var ovrRectangle2;

  PriceAlertsCustomState(
    this.ovrTypesomething,
    this.ovrRectangle2,
  );
}

/// TODO: @developer Add states that extend the abstract state above.
/// For example, if you are coding a counter, you may want to add something like:
///
/// class CounterInProgress extends CounterState{
///   CounterInProgress(int value): super(value);
/// }

class PriceAlertsCustomInitial extends PriceAlertsCustomState {
  PriceAlertsCustomInitial()
      : super(
          'Type something',
          'Rectangle 2',
        );
}
