part of 'buy_bloc.dart';

class BuyState extends Equatable {
  /// Holds the crypto coin that the user is buying
  final String cryptoCurrency;

  /// Will hold the approximate conversion from `fiat` currency to [cryptoCurrency]
  final String approxCryptoConversion;

  final ConversionStatus conversionStatus;

  const BuyState({
    required this.cryptoCurrency,
    this.approxCryptoConversion = '0.00000000',
    this.conversionStatus = ConversionStatus.initial,
  });

  BuyState copyWith({
    String? cryptoCurrency,
    String? approxCryptoConversion,
    ConversionStatus? conversionStatus,
  }) {
    return BuyState(
      cryptoCurrency: cryptoCurrency ?? this.cryptoCurrency,
      approxCryptoConversion:
          approxCryptoConversion ?? this.approxCryptoConversion,
      conversionStatus: conversionStatus ?? this.conversionStatus,
    );
  }

  @override
  List<Object?> get props =>
      [cryptoCurrency, approxCryptoConversion, conversionStatus];
}

enum ConversionStatus {
  initial,
  loading,
  success,
  error,
}
