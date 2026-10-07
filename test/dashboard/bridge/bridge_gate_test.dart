import 'package:flutter_test/flutter_test.dart';
import 'package:genius_api/ffi/trust_wallet_api_ffi.dart';
import 'package:genius_api/models/coin.dart';
import 'package:genius_api/models/wallet.dart';
import 'package:genius_api/types/wallet_type.dart';
import 'package:genius_wallet/dashboard/bridge/bridge_gate.dart';

/// Every input says "enabled" until a rung overrides one.
class _Inputs {
  bool hasWallet = true;
  bool walletCanSign = true;
  bool isChild = false;
  bool isSwitching = false;
  String? earningAccount = '0xsdk';
  bool isEarningWallet = true;
  bool networkCanSign = true;
  bool coinsReady = true;
  double? gnusBalance = 10;
  bool? gnusElsewhere = false;

  BridgeGateState resolve() => resolveBridgeGate(
    hasWallet: hasWallet,
    walletCanSign: walletCanSign,
    isChild: isChild,
    isSwitching: isSwitching,
    earningAccount: earningAccount,
    isEarningWallet: isEarningWallet,
    networkCanSign: networkCanSign,
    coinsReady: coinsReady,
    gnusBalance: gnusBalance,
    gnusElsewhere: gnusElsewhere,
  );
}

/// Highest rank first. Each entry breaks exactly the input its state names.
final _rungs = <(BridgeGateState, void Function(_Inputs))>[
  (BridgeGateState.noWallet, (i) => i.hasWallet = false),
  (BridgeGateState.viewOnly, (i) => i.walletCanSign = false),
  (BridgeGateState.child, (i) => i.isChild = true),
  (BridgeGateState.switching, (i) => i.isSwitching = true),
  (
    BridgeGateState.notStarted,
    (i) {
      i.earningAccount = null;
      i.isEarningWallet = false;
    },
  ),
  (BridgeGateState.notEarning, (i) => i.isEarningWallet = false),
  (BridgeGateState.wrongNetwork, (i) => i.networkCanSign = false),
  (BridgeGateState.checking, (i) => i.coinsReady = false),
  (
    BridgeGateState.gnusElsewhere,
    (i) {
      i.gnusBalance = 0;
      i.gnusElsewhere = true;
    },
  ),
  (BridgeGateState.noGnus, (i) => i.gnusBalance = 0),
];

Wallet _wallet(String address) => Wallet(
  coinType: TWCoinType.TWCoinTypeEthereum,
  walletName: 'w',
  currencySymbol: 'ETH',
  walletType: WalletType.mnemonic,
  balance: 0,
  address: address,
);

void main() {
  group('resolveBridgeGate', () {
    test('every input saying enabled resolves to enabled', () {
      expect(_Inputs().resolve(), BridgeGateState.enabled);
    });

    for (final (state, breakIt) in _rungs) {
      test('${state.name} wins when every lower input says enabled', () {
        final inputs = _Inputs();
        breakIt(inputs);
        expect(inputs.resolve(), state);
      });
    }

    test('each rung beats every rung below it', () {
      for (var high = 0; high < _rungs.length; high++) {
        for (var low = high + 1; low < _rungs.length; low++) {
          // Both last rungs set the same probe input, so there is no pair.
          if (high == _rungs.length - 2 && low == _rungs.length - 1) {
            continue;
          }
          final inputs = _Inputs();
          _rungs[low].$2(inputs);
          _rungs[high].$2(inputs);
          expect(
            inputs.resolve(),
            _rungs[high].$1,
            reason: '${_rungs[high].$1.name} over ${_rungs[low].$1.name}',
          );
        }
      }
    });

    group('balance and the other-network probe', () {
      for (final balance in <double?>[null, 0]) {
        test('balance $balance: probe pending reads checking', () {
          final inputs = _Inputs()
            ..gnusBalance = balance
            ..gnusElsewhere = null;
          expect(inputs.resolve(), BridgeGateState.checking);
        });
        test('balance $balance: GNUS elsewhere is named', () {
          final inputs = _Inputs()
            ..gnusBalance = balance
            ..gnusElsewhere = true;
          expect(inputs.resolve(), BridgeGateState.gnusElsewhere);
        });
        test('balance $balance: nothing anywhere is no GNUS', () {
          final inputs = _Inputs()
            ..gnusBalance = balance
            ..gnusElsewhere = false;
          expect(inputs.resolve(), BridgeGateState.noGnus);
        });
      }

      for (final probe in <bool?>[null, true, false]) {
        test('a balance here wins whatever the probe says ($probe)', () {
          final inputs = _Inputs()
            ..gnusBalance = 0.5
            ..gnusElsewhere = probe;
          expect(inputs.resolve(), BridgeGateState.enabled);
        });
      }
    });
  });

  group('bridgeGateCaption', () {
    test('only enabled has no caption', () {
      for (final state in BridgeGateState.values) {
        final caption = bridgeGateCaption(state, network: 'Base');
        if (state == BridgeGateState.enabled) {
          expect(caption, isNull);
        } else {
          expect(caption, isNotEmpty, reason: state.name);
        }
      }
    });

    test('captions are distinct', () {
      final captions = {
        for (final state in BridgeGateState.values)
          bridgeGateCaption(state, network: 'Base'),
      };
      expect(captions.length, BridgeGateState.values.length);
    });

    test('static captions fit one line and avoid internal terms', () {
      for (final state in BridgeGateState.values) {
        final caption = bridgeGateCaption(state, network: 'Base');
        if (caption == null) {
          continue;
        }
        if (state != BridgeGateState.gnusElsewhere) {
          expect(caption.length, lessThanOrEqualTo(36), reason: state.name);
        }
        expect(caption.toLowerCase(), isNot(contains('node')));
        expect(caption.toLowerCase(), isNot(contains('sdk')));
        expect(caption.toLowerCase(), isNot(contains('mint')));
      }
    });

    test('the other-network caption names the network', () {
      expect(
        bridgeGateCaption(BridgeGateState.gnusElsewhere, network: 'Base'),
        'GNUS is on Base. Switch network.',
      );
    });

    test('without a network name the caption stays generic', () {
      for (final name in <String?>[null, '']) {
        expect(
          bridgeGateCaption(BridgeGateState.gnusElsewhere, network: name),
          'GNUS is on another network.',
        );
      }
    });

    test('a gate reads its own caption and enabled flag', () {
      expect(const BridgeGate(BridgeGateState.enabled).enabled, isTrue);
      expect(const BridgeGate(BridgeGateState.enabled).caption, isNull);
      expect(kBridgeGateUnknown.enabled, isFalse);
      expect(
        const BridgeGate(
          BridgeGateState.gnusElsewhere,
          elsewhereNetwork: 'Base',
        ).caption,
        'GNUS is on Base. Switch network.',
      );
    });
  });

  group('isEarningWallet', () {
    const sdk = '0xAAAA';
    const wallet = '0xAbC123';

    test('matches whatever the case on either side', () {
      final links = {'0xaaaa': (walletAddress: '0xabc123', walletName: 'n')};
      expect(isEarningWallet(_wallet(wallet), sdk, links), isTrue);
    });

    test('an earning account with no link matches nothing', () {
      expect(isEarningWallet(_wallet(wallet), sdk, const {}), isFalse);
    });

    test('a second account on the same wallet does not pass another one', () {
      final links = {
        '0xaaaa': (walletAddress: '0xabc123', walletName: 'n'),
        '0xbbbb': (walletAddress: '0xdef456', walletName: 'n'),
      };
      expect(isEarningWallet(_wallet('0xDEF456'), sdk, links), isFalse);
      expect(isEarningWallet(_wallet('0xDEF456'), '0xBBBB', links), isTrue);
    });
  });

  group('bridgeCoin', () {
    test('matches GNUS in any case', () {
      for (final symbol in ['GNUS', 'gnus']) {
        final coin = Coin(symbol: symbol, address: '0xabc');
        expect(bridgeCoin([coin]), coin);
      }
    });

    test('rejects a GNUS with no contract address', () {
      expect(bridgeCoin(const [Coin(symbol: 'GNUS')]), isNull);
      expect(bridgeCoin(const [Coin(symbol: 'GNUS', address: '')]), isNull);
    });

    test('the first match wins', () {
      const first = Coin(symbol: 'GNUS', address: '0x1');
      const second = Coin(symbol: 'gnus', address: '0x2');
      expect(bridgeCoin(const [first, second]), first);
    });

    test('no GNUS gives null', () {
      expect(bridgeCoin(const [Coin(symbol: 'USDC', address: '0x1')]), isNull);
      expect(bridgeCoin(const []), isNull);
    });
  });
}
