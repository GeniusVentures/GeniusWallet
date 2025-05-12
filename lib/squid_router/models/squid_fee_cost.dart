import 'package:genius_wallet/squid_router/models/squid_token_info.dart';

class SquidFeeCost {
  final String name;
  final String description;
  final String percentage;
  final SquidTokenInfo token;
  final String amount;
  final String amountUSD;

  SquidFeeCost({
    required this.name,
    required this.description,
    required this.percentage,
    required this.token,
    required this.amount,
    required this.amountUSD,
  });

  factory SquidFeeCost.fromJson(Map<String, dynamic> json) {
    return SquidFeeCost(
      name: json['name'],
      description: json['description'],
      percentage: json['percentage'],
      token: SquidTokenInfo.fromJson(json['token']),
      amount: json['amount'],
      amountUSD: json['amountUSD'],
    );
  }
}
