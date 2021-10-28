abstract class CryptoItemCustomState {
  var ovrLine;
  var ovrEllipse;
  var ovr2099;
  var ovr0BTC;
  var ovr418;
  var ovr4630950;
  var ovrCrypto;

  CryptoItemCustomState(
    this.ovrLine,
    this.ovrEllipse,
    this.ovr2099,
    this.ovr0BTC,
    this.ovr418,
    this.ovr4630950,
    this.ovrCrypto,
  );
}

/// TODO: @developer Add states that extend the abstract state above.
/// For example, if you are coding a counter, you may want to add something like:
///
/// class CounterInProgress extends CounterState{
///   CounterInProgress(int value): super(value);
/// }

class CryptoItemCustomInitial extends CryptoItemCustomState {
  CryptoItemCustomInitial()
      : super(
          'Line',
          'Ellipse',
          '\$20.99',
          '0 BTC',
          '+4.18%',
          '\$46,309.50',
          'Crypto',
        );
}
