// Pure unit tests for `buildAccountTree`: nesting, dedup and cycle-safety,
// with no widget tree, no bloc and no SDK.
import 'package:flutter_test/flutter_test.dart';
import 'package:genius_wallet/account/account_tree.dart';
import 'package:genius_wallet/child_wallets/child_wallets_cubit.dart';

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

void main() {
  test('null registrations renders one depth-0 row per account, in order, '
      'no foreign rows', () {
    final rows = buildAccountTree(
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
    final rows = buildAccountTree(
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
    final rows = buildAccountTree(
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
      final rows = buildAccountTree(
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
    final rows = buildAccountTree(
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
    final rows = buildAccountTree(
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
    final rows = buildAccountTree(
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
      final rows = buildAccountTree(
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
      final rows = buildAccountTree(
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
}
