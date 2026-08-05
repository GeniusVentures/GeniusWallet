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

  /// The balance as a number, or **null** when [balance] is not parseable.
  ///
  /// Nullable rather than `0`, because the one consumer that reasons about the
  /// value - the swap CTA - must not say "Insufficient ETH" on data it never
  /// received. `swap_screen.dart`'s `fromBalanceAmount` already declares that
  /// rule; this getter is what makes it true.
  ///
  /// `pow(int, int)` returns a `num` that is an **int** at runtime whenever the
  /// result fits in an int64, i.e. for every `decimals <= 18` - which is every
  /// real token. So the old `as double` cast threw
  /// `type 'int' is not a subtype of type 'double'` on literally every call.
  /// It read as data-dependent only because two of the three callers swallow it
  /// in a `catch` and print `0`; `swap_screen`'s `fromBalanceAmount` did not,
  /// and threw during build.
  ///
  /// **Merge note (2026-07-28):** this defect was found and fixed independently
  /// on both branches. The other fix was
  /// `double.tryParse(balance)! / pow(10, decimals).toDouble()` - same
  /// arithmetic, but the `!` swaps a TypeError for a null-check error on an
  /// unparseable balance. The nullable form is kept because a balance that did
  /// not arrive and a balance of zero are different facts, and the CTA reads
  /// them differently.
  double? get amountAsDouble {
    final raw = double.tryParse(balance);
    return raw == null ? null : raw / pow(10, decimals).toDouble();
  }

  @override
  String toString() =>
      '$symbol on chain $chainId: ${amountAsDouble?.toStringAsFixed(4) ?? '?'}';
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

  /// [formattedBalance] for READING. Never for MAX.
  ///
  /// [formattedBalance] renders the token's full precision, so an 18-decimal
  /// token shows its float error verbatim: 0.01 DAI reaches the token picker
  /// as `0.010000000000000221`. That is not a rounding preference, it is
  /// eighteen significant digits of noise in a row a person is scanning.
  ///
  /// This is deliberately NOT a fix to [formattedBalance]: the MAX affordance
  /// puts that string straight into the amount field, so rounding it there
  /// would either strand dust or ask for more than the wallet holds. The exact
  /// value keeps its getter; this one is for eyes only.
  ///
  /// ponytail: 6 decimals is a readability choice, not a token property.
  /// Ceiling: a token whose meaningful unit is smaller than 1e-6 would read as
  /// `0`. The `< 1e-6` branch below catches exactly that case and says
  /// "less than" instead of lying.
  String get displayBalance {
    try {
      final value = amountAsDouble;
      if (value == null || value == 0) {
        return '0';
      }
      if (value < 0.000001) {
        return '<0.000001';
      }
      if (value == value.roundToDouble()) {
        return value.toInt().toString();
      }
      return value
          .toStringAsFixed(6)
          .replaceFirst(RegExp(r'0+$'), '')
          .replaceFirst(RegExp(r'\.$'), '');
    } catch (_) {
      return '0';
    }
  }
}
