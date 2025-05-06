class SquidSwapParams {
  final int fromChain;
  final String fromToken;
  final String fromAmount;
  final int toChain;
  final String toToken;
  final String fromAddress;
  final String toAddress;
  final double slippage;
  final bool enableForecall;

  SquidSwapParams({
    required this.fromChain,
    required this.fromToken,
    required this.fromAmount,
    required this.toChain,
    required this.toToken,
    required this.fromAddress,
    required this.toAddress,
    this.slippage = 3.0,
    this.enableForecall = true,
  });

  Map<String, dynamic> toJson() {
    return {
      'fromChain': fromChain,
      'fromToken': fromToken,
      'fromAmount': fromAmount,
      'toChain': toChain,
      'toToken': toToken,
      'fromAddress': fromAddress,
      'toAddress': toAddress,
      'slippage': slippage,
      'enableForecall': enableForecall,
    };
  }

  @override
  String toString() => toJson().toString();
}
