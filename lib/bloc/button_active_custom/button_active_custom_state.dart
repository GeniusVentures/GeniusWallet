abstract class ButtonActiveCustomState {
  var ovrTypesomething;

  ButtonActiveCustomState(
    this.ovrTypesomething,
  );
}

/// TODO: @developer Add states that extend the abstract state above.
/// For example, if you are coding a counter, you may want to add something like:
///
/// class CounterInProgress extends CounterState{
///   CounterInProgress(int value): super(value);
/// }

class ButtonActiveCustomInitial extends ButtonActiveCustomState {
  ButtonActiveCustomInitial()
      : super(
          'Type something',
        );
}
