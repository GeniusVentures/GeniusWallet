abstract class ProtocolSelectorCustomState {
  var ovrType;
  var ovrTriangle;

  ProtocolSelectorCustomState(
    this.ovrType,
    this.ovrTriangle,
  );
}

/// TODO: @developer Add states that extend the abstract state above.
/// For example, if you are coding a counter, you may want to add something like:
///
/// class CounterInProgress extends CounterState{
///   CounterInProgress(int value): super(value);
/// }

class ProtocolSelectorCustomInitial extends ProtocolSelectorCustomState {
  ProtocolSelectorCustomInitial()
      : super(
          'Type',
          'Triangle',
        );
}
