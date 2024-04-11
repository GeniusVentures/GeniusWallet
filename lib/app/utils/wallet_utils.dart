import 'package:flutter/material.dart';
import 'package:genius_api/genius_api.dart';
import 'package:genius_api/models/wallet.dart';

class WalletUtils {
  /// Iterates [wallets] and returns the number of transactions as an [int].
  static int getTransactionNumber(List<Wallet> wallets) {
    int counter = 0;
    for (var wallet in wallets) {
      counter += wallet.transactions.length;
    }
    return counter;
  }

  static int totalBalance(
    GeniusApi geniusApi,
    List<Wallet> wallets,
  ) {
    // TODO: Need to take into account preferred user currency and likely convert all currencies to preferred user currency.
    int total = 0;

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
  static Widget currencySymbolToImage(String symbol) {
    switch (symbol) {
      case 'ETH':
        return Image.asset(
          'assets/images/ethereum_icon.png',
          package: 'genius_wallet',
        );
      case 'BTC':
        return Image.asset(
          'assets/images/bitcoin_icon.png',
          package: 'genius_wallet',
        );
      default:
        return const SizedBox();
    }
  }
}
