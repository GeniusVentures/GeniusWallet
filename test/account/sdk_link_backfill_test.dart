// Pins the one-time backfill decision for accounts older than the link
// feature (LINK-03): a re-add's single new address links, a one-to-one
// leftover pair links, and anything wider is left honestly 'Unlinked'
// rather than guessed.
import 'package:flutter_test/flutter_test.dart';
import 'package:genius_api/ffi/genius_api_ffi.dart';
import 'package:genius_api/genius_api.dart';

typedef _Candidate = ({
  String walletAddress,
  String walletName,
  GeniusNodeReturnValue Function() reAdd,
});

void main() {
  group('GeniusApi.backfillLinks', () {
    test('a re-add that appends one address links that address to the '
        'wallet, lowercased', () {
      final accounts = <String>['0xexisting'];
      final result = GeniusApi.backfillLinks(
        unlinked: <_Candidate>[
          (
            walletAddress: '0xW1',
            walletName: 'Main',
            reAdd: () {
              accounts.add('0xNEW1');
              return GeniusNodeReturnValue.GENIUS_NODE_RET_OK;
            },
          ),
        ],
        accounts: () => accounts,
        linkedSDKAddresses: const {},
      );

      expect(result, {'0xnew1': (walletAddress: '0xW1', walletName: 'Main')});
    });

    test('one no-op re-add plus exactly one leftover address: linked', () {
      final accounts = <String>['0xexisting', '0xleftover'];
      final result = GeniusApi.backfillLinks(
        unlinked: <_Candidate>[
          (
            walletAddress: '0xW1',
            walletName: 'Main',
            reAdd: () => GeniusNodeReturnValue.GENIUS_NODE_RET_OK,
          ),
        ],
        accounts: () => accounts,
        linkedSDKAddresses: const {'0xexisting'},
      );

      expect(result, {
        '0xleftover': (walletAddress: '0xW1', walletName: 'Main'),
      });
    });

    test('two no-op re-adds and two leftover addresses: nothing is linked', () {
      final accounts = <String>['0xleftover1', '0xleftover2'];
      final result = GeniusApi.backfillLinks(
        unlinked: <_Candidate>[
          (
            walletAddress: '0xW1',
            walletName: 'Main',
            reAdd: () => GeniusNodeReturnValue.GENIUS_NODE_RET_OK,
          ),
          (
            walletAddress: '0xW2',
            walletName: 'Second',
            reAdd: () => GeniusNodeReturnValue.GENIUS_NODE_RET_OK,
          ),
        ],
        accounts: () => accounts,
        linkedSDKAddresses: const {},
      );

      expect(result, isEmpty);
    });

    test('a re-add that appends two addresses stops the pass: the next '
        "wallet's re-add never runs and nothing more is linked", () {
      final accounts = <String>['0xexisting'];
      var secondReAddCalled = false;
      final result = GeniusApi.backfillLinks(
        unlinked: <_Candidate>[
          (
            walletAddress: '0xW1',
            walletName: 'Main',
            reAdd: () {
              accounts.addAll(['0xnew1', '0xnew2']);
              return GeniusNodeReturnValue.GENIUS_NODE_RET_OK;
            },
          ),
          (
            walletAddress: '0xW2',
            walletName: 'Second',
            reAdd: () {
              secondReAddCalled = true;
              return GeniusNodeReturnValue.GENIUS_NODE_RET_OK;
            },
          ),
        ],
        accounts: () => accounts,
        linkedSDKAddresses: const {},
      );

      expect(result, isEmpty);
      expect(secondReAddCalled, isFalse);
    });

    test('a re-add error never becomes an elimination candidate', () {
      final accounts = <String>['0xleftover'];
      final result = GeniusApi.backfillLinks(
        unlinked: <_Candidate>[
          (
            walletAddress: '0xW1',
            walletName: 'Main',
            reAdd: () =>
                GeniusNodeReturnValue.GENIUS_NODE_ERROR_NOT_INITIALIZED,
          ),
        ],
        accounts: () => accounts,
        linkedSDKAddresses: const {},
      );

      expect(result, isEmpty);
    });

    test('the leftover pool for elimination excludes linkedSDKAddresses', () {
      final accounts = <String>['0xlinked', '0xleftover'];
      final result = GeniusApi.backfillLinks(
        unlinked: <_Candidate>[
          (
            walletAddress: '0xW1',
            walletName: 'Main',
            reAdd: () => GeniusNodeReturnValue.GENIUS_NODE_RET_OK,
          ),
        ],
        accounts: () => accounts,
        linkedSDKAddresses: const {'0xlinked'},
      );

      expect(result, {
        '0xleftover': (walletAddress: '0xW1', walletName: 'Main'),
      });
    });

    test('empty wallets and an empty account list: empty result, no '
        'exception', () {
      final result = GeniusApi.backfillLinks(
        unlinked: const <_Candidate>[],
        accounts: () => const [],
        linkedSDKAddresses: const {},
      );

      expect(result, isEmpty);
    });
  });
}
