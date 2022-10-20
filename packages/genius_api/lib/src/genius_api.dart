import 'dart:async';

import 'package:genius_api/models/transaction.dart';
import 'package:genius_api/models/user.dart';
import 'package:genius_api/models/wallet.dart';
import 'package:genius_api/src/constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GeniusApi {
  const GeniusApi();
  Future<List<String>> getRecoveryPhrase() async {
    ///TODO: Implement recovery phrase generation here with API or proper gen.
    return List.generate(12, (index) => 'word${index + 1}');
  }

  ///
  Future<List<Transaction>> getTransactionsFor(String address) async {
    //TODO: Implement getting these from Genius API
    return [
      Transaction(
        hash:
            '5f16f4c7f149ac4f9510d9cf8cf384038ad348b3bcdc01915f95de12df9d1b02',
        fromAddress: '0x0',
        toAddress: '0x1',
        timeStamp: '13:26, 10 oct 2022',
        transactionDirection: TransactionDirection.sent,
        amount: '0.0002 ETH',
        fees: '',
      ),
      Transaction(
        hash:
            '7f5979fb78f082e8b1c676635db8795c4ac6faba03525fb708cb5fd68fd40c5e',
        fromAddress: '0x2',
        toAddress: '0x0',
        timeStamp: '15:20, 09 oct 2022',
        transactionDirection: TransactionDirection.received,
        amount: '0.0003 ETH',
        fees: '',
      ),
    ];
  }

  Future<List<Wallet>> getUserWallets(String id) async {
    //TODO: Implement this with the Genius API
    return [
      Wallet(
        walletName: 'My Ethereum Wallet',
        currencyName: 'Ethereum',
        currencySymbol: 'ETH',
        address: '0x0',
        balance: 2000,
        transactions: await getTransactionsFor('0x0'),
      ),
    ];
  }

  Future<User> getUser() async {
    //TODO: Implement this with Genius API. At the time of implementing,
    //no authentication method was specified so mocking the method for now.

    return User(
      firstName: 'John',
      lastName: 'Doe',
      nickname: 'jdoe',
      email: 'jdoe@email.com',
      dateOfBirth: '01/01/1990',
      profilePictureUrl: '',
      wallets: await getUserWallets('some_id?'),
    );
  }

  Future<int> getGasFees() async {
    return 100;
  }

  Future<void> storeUserPin(String pin) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString(gnusPin, pin);
  }

  Future<String> getUserPin() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      return prefs.getString(gnusPin) ?? '';
    } catch (e) {
      //TODO: Throw error for FE?
      return '';
    }
  }
}
