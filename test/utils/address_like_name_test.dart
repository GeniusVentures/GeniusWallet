import 'package:flutter_test/flutter_test.dart';
import 'package:genius_wallet/utils/wallet_utils.dart';

void main() {
  test(
    'an address, a shortened address and a long unbroken name are address-like',
    () {
      expect(WalletUtils.isAddressLikeName('0xe28...d931'), isTrue);
      expect(WalletUtils.isAddressLikeName('0xe287abc1234567890def'), isTrue);
      expect(WalletUtils.isAddressLikeName('ProcessingSubTaskQueue1'), isTrue);
    },
  );

  test('a real name that merely starts with 0x or has spaces is kept', () {
    expect(WalletUtils.isAddressLikeName('0x hot wallet'), isFalse);
    expect(WalletUtils.isAddressLikeName('Savings'), isFalse);
    expect(WalletUtils.isAddressLikeName(''), isFalse);
  });
}
