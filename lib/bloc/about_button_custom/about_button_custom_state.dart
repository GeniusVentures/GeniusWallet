abstract class AboutButtonCustomState {
  var ovrTypesomething;
  var ovrRectangle2;

  AboutButtonCustomState(
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

class AboutButtonCustomInitial extends AboutButtonCustomState {
  AboutButtonCustomInitial()
      : super(
          'Type something',
          'Rectangle 2',
        );
}
