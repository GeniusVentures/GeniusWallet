import 'package:flutter/material.dart';
import 'package:genius_api/genius_api.dart';

final symbolImageMap = {
  'ETH': Image.asset(
    'assets/images/crypto/eth.png',
  ),
  'BTC': Image.asset('assets/images/crypto/btc.png'),
  null: const SizedBox()
};

class WalletUtils {
  /// Iterates [wallets] and returns the number of transactions as an [int].
  static int getTransactionNumber(List<Wallet> wallets) {
    int counter = 0;
    for (var wallet in wallets) {
      counter += wallet.transactions.length;
    }
    return counter;
  }

  static double totalBalance(
    GeniusApi geniusApi,
    List<Wallet> wallets,
  ) {
    // TODO: Need to take into account preferred user currency and likely convert all currencies to preferred user currency.
    double total = 0;

    for (var wallet in wallets) {
      total += wallet.balance;
    }

    return total;
  }

  /// Takes in a [String symbol] of the currency and returns an image of the currency.
  ///
  /// Will return empty Widget if the currency was not found.
  ///
  /// Example:
  /// ```
  /// currencySymbolToImage('ETH') -> Image.asset('path/to/ETH.png')
  /// ```
  static Widget? currencySymbolToImage(String symbol) {
    return symbolImageMap[symbol.trim()];
  }

  static String getAddressForDisplay(String address) {
    if (address.length >= 6) {
      return "${address.substring(0, 6)}...${address.substring(address.length - 4)}";
    }

    return address;
  }

  static String truncateToDecimals(String input, [int decimalPlaces = 5]) {
    int decimalIndex = input.indexOf('.');
    if (decimalIndex != -1 && input.length > decimalIndex + decimalPlaces + 1) {
      return input.substring(0, decimalIndex + decimalPlaces + 1);
    }
    return input;
  }
}
