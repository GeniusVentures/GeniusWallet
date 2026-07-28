// The ONE check the SDK section owes (sketch 069-A).
//
// The row menu now shows the same four items on every row and gates them by
// state. Two of those gates are security rules rather than tidiness:
//
//  * `GeniusSDKGetMnemonic` returns the SELECTED account's phrase. Offering
//    Copy or Show QR on any other row would put one account's recovery phrase
//    on screen under a different account's address.
//  * An account imported from a private key has no phrase at all, so
//    "has a mnemonic" is not the same question as "is selected".
//
// Both are one boolean away from being wrong, and neither would look wrong on
// screen - the menu would simply have an extra enabled item. So the rules live
// in `sdkRowActions` and are pinned here across all four combinations.
import 'package:flutter_test/flutter_test.dart';
import 'package:genius_wallet/account/sdk_account_manager.dart';

void main() {
  group('sdkRowActions', () {
    test('the active account with a phrase: everything but delete', () {
      final can = sdkRowActions(isSelected: true, hasMnemonic: true);
      expect(can.payout, isTrue);
      expect(can.phrase, isTrue);
      expect(can.qr, isTrue);
      // The SDK refuses to delete the account it is using.
      expect(can.delete, isFalse);
    });

    test(
      'the active account imported from a private key: no phrase, no QR',
      () {
        final can = sdkRowActions(isSelected: true, hasMnemonic: false);
        expect(can.payout, isTrue);
        expect(can.phrase, isFalse);
        expect(can.qr, isFalse);
        expect(can.delete, isFalse);
      },
    );

    test('any other account: delete only, never the phrase', () {
      // The load-bearing case. `hasMnemonic` is true here because the SDK is
      // reporting the SELECTED account's phrase - which is exactly why this
      // row must not offer it.
      final can = sdkRowActions(isSelected: false, hasMnemonic: true);
      expect(can.phrase, isFalse, reason: 'that phrase belongs to another row');
      expect(can.qr, isFalse, reason: 'that phrase belongs to another row');
      expect(
        can.payout,
        isFalse,
        reason: 'payout applies to the active account',
      );
      expect(can.delete, isTrue);
    });

    test('every row has at least one action, so the menu is never dead', () {
      for (final selected in [true, false]) {
        for (final mnemonic in [true, false]) {
          final can = sdkRowActions(
            isSelected: selected,
            hasMnemonic: mnemonic,
          );
          expect(
            can.payout || can.phrase || can.qr || can.delete,
            isTrue,
            reason: 'selected=$selected mnemonic=$mnemonic',
          );
        }
      }
    });
  });

  group('isEvmAddress', () {
    test('accepts a real address in either case', () {
      expect(
        isEvmAddress('0x71C7656EC7ab88b098defB751B7401B5f6d8976F'),
        isTrue,
      );
      expect(
        isEvmAddress('0x71c7656ec7ab88b098defb751b7401b5f6d8976f'),
        isTrue,
      );
      // Surrounding whitespace is a paste artefact, not a mistake.
      expect(
        isEvmAddress('  0x71c7656ec7ab88b098defb751b7401b5f6d8976f  '),
        isTrue,
      );
    });

    test('refuses the shapes the field used to post straight to the SDK', () {
      expect(isEvmAddress(''), isFalse);
      expect(isEvmAddress('0x'), isFalse);
      // One character short - the failure a human eye does not catch.
      expect(
        isEvmAddress('0x71c7656ec7ab88b098defb751b7401b5f6d8976'),
        isFalse,
      );
      // One too long.
      expect(
        isEvmAddress('0x71c7656ec7ab88b098defb751b7401b5f6d8976ff'),
        isFalse,
      );
      // Right length, no prefix.
      expect(isEvmAddress('71c7656ec7ab88b098defb751b7401b5f6d8976f'), isFalse);
      // Right length and prefix, not hex.
      expect(
        isEvmAddress('0x71c7656ec7ab88b098defb751b7401b5f6d8976z'),
        isFalse,
      );
    });
  });
}
