import 'dart:math';

class SquidBalance {
  final String balance;
  final String symbol;
  final String address;
  final int decimals;
  final String chainId;

  SquidBalance({
    required this.balance,
    required this.symbol,
    required this.address,
    required this.decimals,
    required this.chainId,
  });

  factory SquidBalance.fromJson(Map<String, dynamic> json) {
    return SquidBalance(
      balance: json['balance'] as String,
      symbol: json['symbol'] as String,
      address: json['address'] as String,
      decimals: json['decimals'] as int,
      chainId: json['chainId'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'balance': balance,
      'symbol': symbol,
      'address': address,
      'decimals': decimals,
      'chainId': chainId,
    };
  }

  double get amountAsDouble =>
      double.tryParse(balance)! / (pow(10, decimals) as double);

  @override
  String toString() =>
      '$symbol on chain $chainId: ${amountAsDouble.toStringAsFixed(4)}';
}

extension SquidBalanceFormatter on SquidBalance {
  String get formattedBalance {
    try {
      final decimalsFactor = BigInt.from(10).pow(decimals);
      final raw = BigInt.parse(balance);
      final value = raw / decimalsFactor;

      final doubleValue = value.toDouble();

      // If it's a whole number (e.g., 500.0), return as int
      if (doubleValue == doubleValue.roundToDouble()) {
        return doubleValue.toInt().toString();
      }

      // Otherwise, preserve full precision up to token decimals
      // Cap to max 18 digits after the decimal to avoid overflow
      final maxDecimals = decimals.clamp(1, 18);
      return doubleValue
          .toStringAsFixed(maxDecimals)
          .replaceFirst(RegExp(r'0+$'), '')
          .replaceFirst(RegExp(r'\.$'), '');
    } catch (_) {
      return '0';
    }
  }
}
