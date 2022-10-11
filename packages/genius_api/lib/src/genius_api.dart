import 'dart:async';

import 'package:genius_api/models/transaction.dart';
import 'package:genius_api/models/user.dart';
import 'package:genius_api/models/wallet.dart';

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
        fromAddress: '0x0',
        toAddress: '0x1',
        timeStamp: '13:26, 10 oct 2022',
        transactionDirection: TransactionDirection.sent,
        amount: '0.0002 ETH',
      ),
      Transaction(
        fromAddress: '0x2',
        toAddress: '0x0',
        timeStamp: '15:20, 09 oct 2022',
        transactionDirection: TransactionDirection.received,
        amount: '0.0003 ETH',
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
}
