abstract class GnusAmountSelectorCustomState {
  var ovrType;
  var ovrPaste;

  GnusAmountSelectorCustomState(
    this.ovrType,
    this.ovrPaste,
  );
}

/// TODO: @developer Add states that extend the abstract state above.
/// For example, if you are coding a counter, you may want to add something like:
///
/// class CounterInProgress extends CounterState{
///   CounterInProgress(int value): super(value);
/// }

class GnusAmountSelectorCustomInitial extends GnusAmountSelectorCustomState {
  GnusAmountSelectorCustomInitial()
      : super(
          'Type',
          'Paste',
        );
}
