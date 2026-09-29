// Pure unit tests for `buildAccountTree`: nesting, dedup, cycle-safety and
// wallet/account merging, with no widget tree, no bloc and no SDK.
import 'package:flutter_test/flutter_test.dart';
import 'package:genius_api/ffi/trust_wallet_api_ffi.dart';
import 'package:genius_api/genius_api.dart';
import 'package:genius_api/types/wallet_type.dart';
import 'package:genius_wallet/account/account_tree.dart';
import 'package:genius_wallet/child_wallets/child_wallets_cubit.dart';
import 'package:local_secure_storage/local_secure_storage.dart';

const _mainA = '0xaaaa1111';
const _mainB = '0xbbbb2222';
const _mainC = '0xcccc3333';
const _foreignX = '0xdead0001';
const _foreignY = '0xdead0002';

ChildWallet _entry(String address) => ChildWallet(
  address: address,
  name: 'Unlinked',
  linkedWallet: null,
  balanceGnus: '0.000000',
);

Wallet _wallet(
  String name,
  String address, {
  WalletType type = WalletType.privateKey,
}) => Wallet(
  coinType: TWCoinType.TWCoinTypeEthereum,
  walletName: name,
  currencySymbol: 'ETH',
  walletType: type,
  balance: 0,
  address: address,
);

List<AccountTreeRow> _tree({
  List<Wallet> wallets = const [],
  required List<String> sdkAccounts,
  Map<String, SDKAccountLink> links = const {},
  required Map<String, List<ChildWallet>>? registrations,
}) => buildAccountTree(
  wallets: wallets,
  sdkAccounts: sdkAccounts,
  links: links,
  registrations: registrations,
);

void main() {
  test('null registrations renders one depth-0 row per account, in order, '
      'no foreign rows', () {
    final rows = _tree(
      sdkAccounts: const [_mainA, _mainB, _mainC],
      registrations: null,
    );

    expect(rows, hasLength(3));
    for (final row in rows) {
      expect(row.kind, AccountRowKind.account);
      expect(row.depth, 0);
      expect(row.hasChildren, isFalse);
    }
    expect(rows.map((r) => r.sdkAddress), [_mainA, _mainB, _mainC]);
  });

  test('an own child nests once under its main, matched case-insensitively, '
      'and never repeats at the top level', () {
    final rows = _tree(
      sdkAccounts: const [_mainA, _mainB],
      registrations: {
        _mainA.toLowerCase(): [_entry(_mainB.toUpperCase())],
      },
    );

    expect(rows, hasLength(2));
    expect(rows[0].kind, AccountRowKind.account);
    expect(rows[0].sdkAddress, _mainA);
    expect(rows[0].depth, 0);
    expect(rows[0].hasChildren, isTrue);
    expect(rows[1].kind, AccountRowKind.account);
    expect(rows[1].sdkAddress, _mainB);
    expect(rows[1].depth, 1);
    expect(rows[1].hasChildren, isFalse);
  });

  test('a grandchild nests at depth 2, with hasChildren true on both '
      'ancestors', () {
    final rows = _tree(
      sdkAccounts: const [_mainA, _mainB, _mainC],
      registrations: {
        _mainA.toLowerCase(): [_entry(_mainB)],
        _mainB.toLowerCase(): [_entry(_mainC)],
      },
    );

    expect(rows, hasLength(3));
    expect(rows[0].sdkAddress, _mainA);
    expect(rows[0].depth, 0);
    expect(rows[0].hasChildren, isTrue);
    expect(rows[1].sdkAddress, _mainB);
    expect(rows[1].depth, 1);
    expect(rows[1].hasChildren, isTrue);
    expect(rows[2].sdkAddress, _mainC);
    expect(rows[2].depth, 2);
    expect(rows[2].hasChildren, isFalse);
  });

  test(
    'an own child listed by two mains stays under the first main walked',
    () {
      final rows = _tree(
        sdkAccounts: const [_mainA, _mainB, _mainC],
        registrations: {
          _mainA.toLowerCase(): [_entry(_mainC)],
          _mainB.toLowerCase(): [_entry(_mainC)],
        },
      );

      expect(rows, hasLength(3));
      expect(rows[0].sdkAddress, _mainA);
      expect(rows[0].hasChildren, isTrue);
      expect(rows[1].sdkAddress, _mainC);
      expect(rows[1].depth, 1);
      expect(rows[2].sdkAddress, _mainB);
      expect(rows[2].depth, 0);
      expect(rows[2].hasChildren, isFalse);
    },
  );

  test('a foreign child listed by two mains appears once, under the first '
      'main walked', () {
    final rows = _tree(
      sdkAccounts: const [_mainA, _mainB],
      registrations: {
        _mainA.toLowerCase(): [_entry(_foreignX)],
        _mainB.toLowerCase(): [_entry(_foreignX)],
      },
    );

    expect(rows, hasLength(3));
    expect(rows[0].sdkAddress, _mainA);
    expect(rows[0].hasChildren, isTrue);
    expect(rows[1].kind, AccountRowKind.foreignChild);
    expect(rows[1].parentMain, _mainA);
    expect(rows[1].child!.address, _foreignX);
    expect(rows[2].sdkAddress, _mainB);
    expect(rows[2].hasChildren, isFalse);
  });

  test('a 2-cycle places both accounts once, the first at depth 0 and the '
      'second nested under it', () {
    final rows = _tree(
      sdkAccounts: const [_mainA, _mainB],
      registrations: {
        _mainA.toLowerCase(): [_entry(_mainB)],
        _mainB.toLowerCase(): [_entry(_mainA)],
      },
    );

    expect(rows, hasLength(2));
    expect(rows[0].sdkAddress, _mainA);
    expect(rows[0].depth, 0);
    expect(rows[0].hasChildren, isTrue);
    expect(rows[1].sdkAddress, _mainB);
    expect(rows[1].depth, 1);
    expect(rows[1].hasChildren, isFalse);
  });

  test('a three-account cycle places each account once, nested in walk '
      'order', () {
    final rows = _tree(
      sdkAccounts: const [_mainA, _mainB, _mainC],
      registrations: {
        _mainA.toLowerCase(): [_entry(_mainB)],
        _mainB.toLowerCase(): [_entry(_mainC)],
        _mainC.toLowerCase(): [_entry(_mainA)],
      },
    );

    expect(rows, hasLength(3));
    expect(rows[0].sdkAddress, _mainA);
    expect(rows[0].depth, 0);
    expect(rows[1].sdkAddress, _mainB);
    expect(rows[1].depth, 1);
    expect(rows[2].sdkAddress, _mainC);
    expect(rows[2].depth, 2);
  });

  test(
    'an account listing itself appears once, as a childless depth-0 root',
    () {
      final rows = _tree(
        sdkAccounts: const [_mainA, _mainB],
        registrations: {
          _mainA.toLowerCase(): [_entry(_mainA)],
        },
      );

      expect(rows, hasLength(2));
      expect(rows[0].sdkAddress, _mainA);
      expect(rows[0].depth, 0);
      expect(rows[0].hasChildren, isFalse);
      expect(rows[1].sdkAddress, _mainB);
      expect(rows[1].depth, 0);
    },
  );

  test(
    'every main listing the same fixture children, as the dev mock does '
    'with no selected account, keeps each child under only the first main',
    () {
      final rows = _tree(
        sdkAccounts: const [_mainA, _mainB, _mainC],
        registrations: {
          _mainA.toLowerCase(): [_entry(_foreignX), _entry(_foreignY)],
          _mainB.toLowerCase(): [_entry(_foreignX), _entry(_foreignY)],
          _mainC.toLowerCase(): [_entry(_foreignX), _entry(_foreignY)],
        },
      );

      expect(rows, hasLength(5));
      expect(rows[0].sdkAddress, _mainA);
      expect(rows[0].hasChildren, isTrue);
      expect(rows[1].child!.address, _foreignX);
      expect(rows[1].parentMain, _mainA);
      expect(rows[2].child!.address, _foreignY);
      expect(rows[2].parentMain, _mainA);
      expect(rows[3].sdkAddress, _mainB);
      expect(rows[3].hasChildren, isFalse);
      expect(rows[4].sdkAddress, _mainC);
      expect(rows[4].hasChildren, isFalse);
    },
  );

  group('wallet/account merging', () {
    test('an SDK account linked to an own wallet merges onto that row, in '
        'wallet order, then unmerged accounts follow', () {
      final walletA = _wallet('Wallet A', '0xw111');
      final walletB = _wallet('Wallet B', '0xw222');
      final links = <String, SDKAccountLink>{
        _mainA.toLowerCase(): (walletAddress: '0xw111', walletName: 'Wallet A'),
      };

      final rows = _tree(
        wallets: [walletA, walletB],
        sdkAccounts: const [_mainA, _mainB],
        links: links,
        registrations: null,
      );

      expect(rows, hasLength(3));
      expect(rows[0].kind, AccountRowKind.merged);
      expect(rows[0].wallet, walletA);
      expect(rows[0].sdkAddress, _mainA);
      expect(rows[1].kind, AccountRowKind.wallet);
      expect(rows[1].wallet, walletB);
      expect(rows[2].kind, AccountRowKind.account);
      expect(rows[2].sdkAddress, _mainB);
    });

    test('a tracking (watch-only) wallet never merges, even sharing an '
        'address with a linked account', () {
      final tracking = _wallet('Watched', '0xw111', type: WalletType.tracking);
      final links = <String, SDKAccountLink>{
        _mainA.toLowerCase(): (walletAddress: '0xw111', walletName: 'Watched'),
      };

      final rows = _tree(
        wallets: [tracking],
        sdkAccounts: const [_mainA],
        links: links,
        registrations: null,
      );

      expect(rows, hasLength(2));
      expect(rows[0].kind, AccountRowKind.wallet);
      expect(rows[1].kind, AccountRowKind.account);
      expect(rows[1].sdkAddress, _mainA);
    });

    test('a link to a removed wallet gives an unmerged account row', () {
      final walletA = _wallet('Wallet A', '0xw111');
      final links = <String, SDKAccountLink>{
        _mainA.toLowerCase(): (walletAddress: '0xremoved', walletName: 'Gone'),
      };

      final rows = _tree(
        wallets: [walletA],
        sdkAccounts: const [_mainA],
        links: links,
        registrations: null,
      );

      expect(rows, hasLength(2));
      expect(rows[0].kind, AccountRowKind.wallet);
      expect(rows[1].kind, AccountRowKind.account);
      expect(rows[1].sdkAddress, _mainA);
    });

    test('a second account linked to the same wallet stays its own account '
        'row', () {
      final walletA = _wallet('Wallet A', '0xw111');
      final links = <String, SDKAccountLink>{
        _mainA.toLowerCase(): (walletAddress: '0xw111', walletName: 'Wallet A'),
        _mainB.toLowerCase(): (walletAddress: '0xw111', walletName: 'Wallet A'),
      };

      final rows = _tree(
        wallets: [walletA],
        sdkAccounts: const [_mainA, _mainB],
        links: links,
        registrations: null,
      );

      expect(rows, hasLength(2));
      expect(rows[0].kind, AccountRowKind.merged);
      expect(rows[0].sdkAddress, _mainA);
      expect(rows[1].kind, AccountRowKind.account);
      expect(rows[1].sdkAddress, _mainB);
    });

    test('a merged row nests and acts as a main exactly like an account '
        'row, and the nested wallet is not duplicated at the top level', () {
      final walletA = _wallet('Wallet A', '0xw111');
      final walletB = _wallet('Wallet B', '0xw222');
      final links = <String, SDKAccountLink>{
        _mainA.toLowerCase(): (walletAddress: '0xw111', walletName: 'Wallet A'),
        _mainB.toLowerCase(): (walletAddress: '0xw222', walletName: 'Wallet B'),
      };

      final rows = _tree(
        wallets: [walletA, walletB],
        sdkAccounts: const [_mainA, _mainB],
        links: links,
        registrations: {
          _mainA.toLowerCase(): [_entry(_mainB)],
        },
      );

      expect(rows, hasLength(2));
      expect(rows[0].kind, AccountRowKind.merged);
      expect(rows[0].sdkAddress, _mainA);
      expect(rows[0].wallet, walletA);
      expect(rows[0].depth, 0);
      expect(rows[0].hasChildren, isTrue);
      expect(rows[1].kind, AccountRowKind.merged);
      expect(rows[1].sdkAddress, _mainB);
      expect(rows[1].wallet, walletB);
      expect(rows[1].depth, 1);
    });

    test('a linked child nests under its main even when its wallet comes '
        'first and the main has no wallet', () {
      final walletB = _wallet('Wallet B', '0xw222');
      final rows = _tree(
        wallets: [walletB],
        sdkAccounts: const [_mainA, _mainB],
        links: <String, SDKAccountLink>{
          _mainB.toLowerCase(): (
            walletAddress: '0xw222',
            walletName: 'Wallet B',
          ),
        },
        registrations: {
          _mainA.toLowerCase(): [_entry(_mainB)],
        },
      );

      expect(rows.map((r) => (r.sdkAddress, r.depth)), [
        (_mainA, 0),
        (_mainB, 1),
      ]);
      expect(rows[1].kind, AccountRowKind.merged);
      expect(rows[1].wallet, walletB);
    });
  });
}
