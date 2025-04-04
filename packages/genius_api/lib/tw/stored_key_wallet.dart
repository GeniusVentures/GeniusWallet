import 'package:genius_api/tw/account.dart';
import 'package:genius_api/tw/hd_wallet.dart';
import 'package:genius_api/tw/private_key.dart';
import 'package:genius_api/tw/stored_key.dart';

class StoredKeyWallet {
  late StoredKey storedKey;
  late String id;

  StoredKeyWallet(key) {
    storedKey = key;
    id = storedKey.identifier();
  }

  List<Account>? getAccountsForCoins(password, coins) {
    HDWallet? hdWallet = storedKey.wallet(password);
    if (hdWallet == null) {
      return null;
    }

    List<Account> accounts = List.empty();

    for (var coin in coins) {
      accounts.add(storedKey.accountForCoin(coin, hdWallet));
    }

    return accounts;
  }

  List<Account> getAccounts() {
    int numberOfAccounts = storedKey.accountCount();
    List<Account> accounts = List.empty();

    for (var i = 0; i < numberOfAccounts; i++) {
      accounts.add(storedKey.account(i));
    }

    return accounts;
  }

  Account? getAccount(password, coinType) {
    HDWallet? hdWallet = storedKey.wallet(password);
    if (hdWallet == null) {
      return null;
    }
    return storedKey.accountForCoin(coinType, hdWallet);
  }

  PrivateKey? privateKey(password, coinType) {
    return storedKey.privateKey(coinType, password);
  }
}
