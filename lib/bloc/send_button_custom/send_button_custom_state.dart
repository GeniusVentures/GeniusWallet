abstract class SendButtonCustomState {
  var ovrSend;

  SendButtonCustomState(
    this.ovrSend,
  );
}

/// TODO: @developer Add states that extend the abstract state above.
/// For example, if you are coding a counter, you may want to add something like:
///
/// class CounterInProgress extends CounterState{
///   CounterInProgress(int value): super(value);
/// }

class SendButtonCustomInitial extends SendButtonCustomState {
  SendButtonCustomInitial()
      : super(
          'Send',
        );
}
