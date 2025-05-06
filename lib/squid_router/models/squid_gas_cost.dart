import 'package:genius_wallet/squid_router/models/squid_token_info.dart';

class SquidGasCost {
  final String type;
  final SquidTokenInfo token;
  final String amount;
  final String amountUSD;
  final String gasPrice;
  final String maxFeePerGas;
  final String maxPriorityFeePerGas;
  final String estimate;
  final String limit;

  SquidGasCost({
    required this.type,
    required this.token,
    required this.amount,
    required this.amountUSD,
    required this.gasPrice,
    required this.maxFeePerGas,
    required this.maxPriorityFeePerGas,
    required this.estimate,
    required this.limit,
  });

  factory SquidGasCost.fromJson(Map<String, dynamic> json) {
    return SquidGasCost(
      type: json['type'],
      token: SquidTokenInfo.fromJson(json['token']),
      amount: json['amount'],
      amountUSD: json['amountUSD'],
      gasPrice: json['gasPrice'],
      maxFeePerGas: json['maxFeePerGas'],
      maxPriorityFeePerGas: json['maxPriorityFeePerGas'],
      estimate: json['estimate'],
      limit: json['limit'],
    );
  }
}
