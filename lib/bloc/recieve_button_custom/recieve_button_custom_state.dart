abstract class RecieveButtonCustomState {
  var ovrReceive;
  var ovrVector;

  RecieveButtonCustomState(
    this.ovrReceive,
    this.ovrVector,
  );
}

/// TODO: @developer Add states that extend the abstract state above.
/// For example, if you are coding a counter, you may want to add something like:
///
/// class CounterInProgress extends CounterState{
///   CounterInProgress(int value): super(value);
/// }

class RecieveButtonCustomInitial extends RecieveButtonCustomState {
  RecieveButtonCustomInitial()
      : super(
          'Receive',
          'Vector',
        );
}
