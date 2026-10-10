import 'dart:async';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:genius_api/genius_api.dart';
import 'package:genius_api/models/network.dart';
import 'package:genius_wallet/hive/constants/cache.dart';
import 'package:genius_wallet/network/network_dropdown_selector.dart';
import 'package:genius_wallet/providers/network_tokens_provider.dart';
import 'package:genius_wallet/settings/developer_mode.dart';
import 'package:genius_wallet/settings/developer_settings_cubit.dart';
import 'package:genius_wallet/wallets/cubit/wallet_details_cubit.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';

class _FakeGeniusApi implements GeniusApi {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  late Box box;
  late List<SgnsNet> writes;
  late int leaves;
  late DeveloperSettingsCubit cubit;

  DeveloperSettingsCubit build(Future<bool> Function(SgnsNet) writeNet) =>
      DeveloperSettingsCubit(
        readNet: () async => SgnsNet.test,
        writeNet: writeNet,
        leaveTestnets: () async => leaves++,
      );

  setUp(() async {
    box = await Hive.openBox(preferencesBoxName, bytes: Uint8List(0));
    writes = [];
    leaves = 0;
    cubit = build((net) async {
      writes.add(net);
      return true;
    });
  });

  tearDown(() async {
    await cubit.close();
    DeveloperMode.instance.value = false;
    if (box.isOpen) {
      await box.close();
    }
  });

  test('selectNet persists through the injected writer', () async {
    await cubit.selectNet(SgnsNet.main);

    expect(writes, [SgnsNet.main]);
    expect(cubit.state.net, SgnsNet.main);
    expect(cubit.state.netStatus, contains('Saved'));
  });

  test('turning Developer mode off resets the SDK net to dev', () async {
    await cubit.load();
    await DeveloperMode.instance.setEnabled(true);

    await cubit.setDeveloperMode(false);

    expect(writes, [SgnsNet.dev]);
    expect(cubit.state.net, SgnsNet.dev);
    expect(cubit.state.busy, isFalse);
    expect(DeveloperMode.isOn, isFalse);
    expect(leaves, 1);
  });

  test('a failed persist leaves Developer mode unchanged', () async {
    await box.close();

    await cubit.setDeveloperMode(true);

    expect(DeveloperMode.isOn, isFalse);
    expect(cubit.state.status, startsWith('Error:'));
    expect(cubit.state.busy, isFalse);
  });

  test('off then on runs in order and ends on', () async {
    await DeveloperMode.instance.setEnabled(true);

    final off = cubit.setDeveloperMode(false);
    final on = cubit.setDeveloperMode(true);
    expect(cubit.state.busy, isTrue);
    await Future.wait([off, on]);

    expect(writes, [SgnsNet.dev]);
    expect(DeveloperMode.isOn, isTrue);
    expect(box.get(developerModeKey), isTrue);
    expect(cubit.state.busy, isFalse);
  });

  test('a slow select is written before a later off resets to dev', () async {
    await cubit.close();
    cubit = build((net) async {
      await Future<void>.delayed(
        Duration(milliseconds: net == SgnsNet.main ? 50 : 0),
      );
      writes.add(net);
      return true;
    });
    await DeveloperMode.instance.setEnabled(true);

    final select = cubit.selectNet(SgnsNet.main);
    final off = cubit.setDeveloperMode(false);
    await Future.wait([select, off]);

    expect(writes, [SgnsNet.main, SgnsNet.dev]);
    expect(cubit.state.net, SgnsNet.dev);
    expect(DeveloperMode.isOn, isFalse);
  });

  test('a failed reset turns Developer mode back on', () async {
    await cubit.close();
    cubit = build((net) async => throw StateError('disk full'));
    await DeveloperMode.instance.setEnabled(true);

    await cubit.setDeveloperMode(false);

    expect(DeveloperMode.isOn, isTrue);
    expect(box.get(developerModeKey), isTrue);
    expect(cubit.state.status, startsWith('Error:'));
    expect(leaves, 0);
  });

  test('off still leaves testnets when the cubit closes mid-way', () async {
    final gate = Completer<bool>();
    await cubit.close();
    cubit = build((net) => gate.future);
    await DeveloperMode.instance.setEnabled(true);

    final off = cubit.setDeveloperMode(false);
    await cubit.close();
    gate.complete(true);
    await off;

    expect(DeveloperMode.isOn, isFalse);
    expect(leaves, 1);
  });

  group('NetworkSelection.leaveTestnets', () {
    const mainnet = Network(name: 'Main', chainId: 1, rpcUrl: 'https://m');
    const testnet = Network(
      name: 'Test',
      chainId: 2,
      rpcUrl: 'https://t',
      testnet: true,
    );

    test('moves a testnet selection to a mainnet and persists it', () async {
      final networkBox = await Hive.openBox(
        networkBoxName,
        bytes: Uint8List(0),
      );
      final walletCubit = WalletDetailsCubit(
        initialState: const WalletDetailsState(selectedNetwork: testnet),
        geniusApi: _FakeGeniusApi(),
        networkTokensProvider: NetworkTokensProvider(),
      );
      try {
        await NetworkSelection.leaveTestnets(walletCubit, const [
          testnet,
          mainnet,
        ]);

        expect(walletCubit.state.selectedNetwork, mainnet);
        expect(networkBox.get(selectedNetworkKeyChainId), 1);
        expect(networkBox.get(selectedNetworkKeyRpcUrl), 'https://m');
      } finally {
        await walletCubit.close();
        await networkBox.close();
      }
    });
  });
}
