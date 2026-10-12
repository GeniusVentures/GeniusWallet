import 'package:flutter_test/flutter_test.dart';
import 'package:genius_wallet/utils/wallet_utils.dart';

void main() {
  test('a full or shortened address is address-like', () {
    expect(WalletUtils.isAddressLikeName('0xe28...d931'), isTrue);
    expect(WalletUtils.isAddressLikeName('0xe287...d931'), isTrue);
    expect(WalletUtils.isAddressLikeName('0XE28...D931'), isTrue);
    expect(
      WalletUtils.isAddressLikeName(
        '0xe287abc1234567890def1234567890abcdef1234',
      ),
      isTrue,
    );
  });

  test('a real name is kept, even one that starts with 0x or is long', () {
    expect(WalletUtils.isAddressLikeName('0x hot wallet'), isFalse);
    expect(WalletUtils.isAddressLikeName('0xSavings'), isFalse);
    expect(WalletUtils.isAddressLikeName('0xA...B'), isFalse);
    expect(WalletUtils.isAddressLikeName('ProcessingSubTaskQueue1'), isFalse);
    expect(WalletUtils.isAddressLikeName('Savings'), isFalse);
    expect(WalletUtils.isAddressLikeName(''), isFalse);
  });
}
