import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:genius_api/models/transaction.dart';
import 'package:genius_wallet/dashboard/home/widgets/transaction_displays.dart';
import 'package:genius_wallet/dashboard/home/widgets/transaction_utils.dart';
import 'package:genius_wallet/providers/network_provider.dart';
import 'package:genius_wallet/theme/gw_colors.dart';
import 'package:hive_ce/hive.dart';
import 'package:provider/provider.dart';

/// A token transfer: gas paid in ETH, the token that actually moved is USDC.
Transaction _tokenTx({int? chainId = 8453, String? assetSymbol = 'USDC'}) =>
    Transaction(
      hash: '0xabcdef0123456789abcdef0123456789abcdef0123456789',
      fromAddress: '0x1111222233334444555566667777888899990000',
      recipients: [
        TransferRecipients(
          toAddr: '0x5555666677778888999900001111222233334444',
          amount: '1.25',
        ),
      ],
      timeStamp: DateTime(2026, 9, 23, 18, 42),
      transactionDirection: TransactionDirection.sent,
      fees: '0.0042',
      coinSymbol: 'ETH',
      transactionStatus: TransactionStatus.completed,
      assetSymbol: assetSymbol,
      chainId: chainId,
    );

void main() {
  group('a token row reads its asset, not the gas coin', () {
    test('title names the asset', () {
      final content = txRowContent(_tokenTx(), prices: {});
      expect(content.title, 'USDC');
    });

    test('amount names the asset', () {
      final content = txRowContent(_tokenTx(), prices: {});
      expect(content.amount, contains('USDC'));
      expect(content.amount, isNot(contains('ETH')));
    });

    test('a row with neither field behaves exactly as today', () {
      final tx = _tokenTx(chainId: null, assetSymbol: null);
      final content = txRowContent(tx, prices: {});
      expect(content.title, 'ETH');
      expect(content.amount, contains('ETH'));
    });
  });

  group('the explorer link is keyed off the chain', () {
    test('8453 links to basescan', () {
      expect(
        explorerUrlFor(_tokenTx(chainId: 8453)),
        'https://basescan.org/tx/${_tokenTx().hash}',
      );
    });

    test('80002 links to Amoy', () {
      expect(
        explorerUrlFor(_tokenTx(chainId: 80002)),
        'https://amoy.polygonscan.com/tx/${_tokenTx().hash}',
      );
    });

    test('84532 links to Base Sepolia', () {
      expect(
        explorerUrlFor(_tokenTx(chainId: 84532)),
        'https://sepolia.basescan.org/tx/${_tokenTx().hash}',
      );
    });

    test('84531 (retired Base Goerli) shows no link', () {
      expect(explorerUrlFor(_tokenTx(chainId: 84531)), '');
    });

    test('the catalogue signs Base Sepolia with its real chain id', () {
      // The RPC is Base Sepolia's, which rejects anything signed for 84531.
      final networks =
          jsonDecode(
                File('assets/json/networks/networks.json').readAsStringSync(),
              )
              as List<dynamic>;
      final sepolia = networks.cast<Map<String, dynamic>>().singleWhere(
        (n) => n['name'] == 'Base - Sepolia',
      );
      expect(sepolia['chainId'], 84532);
    });

    test('no chainId falls back to the symbol lookup', () {
      final tx = _tokenTx(chainId: null, assetSymbol: null);
      expect(explorerUrlFor(tx), getExplorerUrl(tx.coinSymbol, tx.hash));
    });
  });

  group('the receipt drawer', () {
    Widget host(Transaction tx) => MaterialApp(
      theme: ThemeData(extensions: [GWColors.dark()]),
      home: Builder(
        builder: (context) => Scaffold(
          body: Center(
            child: ElevatedButton(
              onPressed: () => showTransactionDetails(context, tx),
              child: const Text('open'),
            ),
          ),
        ),
      ),
    );

    Future<void> openWithCatalogue(WidgetTester tester, Transaction tx) async {
      final catalogue = NetworkProvider();
      await tester.runAsync(catalogue.loadNetworks);
      await tester.pumpWidget(
        ChangeNotifierProvider.value(value: catalogue, child: host(tx)),
      );
      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();
    }

    testWidgets('a Base send names Base as its network, not its gas coin', (
      tester,
    ) async {
      await openWithCatalogue(tester, _tokenTx(chainId: 8453));

      expect(find.text('Base'), findsOneWidget);
      expect(find.text('ETH'), findsNothing);
      expect(find.text('0.0042 ETH'), findsOneWidget);
    });

    testWidgets('a row with no chain id still names its gas coin', (
      tester,
    ) async {
      await openWithCatalogue(tester, _tokenTx(chainId: null));

      expect(find.text('ETH'), findsOneWidget);
    });

    testWidgets('Network Fee names the gas coin; no fee line names the asset', (
      tester,
    ) async {
      await tester.pumpWidget(host(_tokenTx()));
      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();

      expect(find.text('0.0042 ETH'), findsOneWidget);
      expect(find.text('0.0042 USDC'), findsNothing);
    });
  });

  // Real Hive I/O, so plain `test()` — `testWidgets` hangs on it. Proves a
  // row an older build wrote (18 fields, none of them the new two) still
  // deserializes once the current adapter is registered.
  group('a legacy 18-field row survives the new adapter', () {
    late Directory dir;

    setUp(() async {
      dir = await Directory.systemTemp.createTemp('gw_legacy_transaction_box');
      Hive.init(dir.path);
      if (!Hive.isAdapterRegistered(4)) {
        Hive.registerAdapter(TransactionDirectionAdapter());
      }
      if (!Hive.isAdapterRegistered(5)) {
        Hive.registerAdapter(TransactionStatusAdapter());
      }
      if (!Hive.isAdapterRegistered(6)) {
        Hive.registerAdapter(TransactionTypeAdapter());
      }
      if (!Hive.isAdapterRegistered(7)) {
        Hive.registerAdapter(TransferRecipientsAdapter());
      }
    });

    tearDown(() async {
      await Hive.close();
      await dir.delete(recursive: true);
    });

    test('old fields survive, both new fields read as null', () async {
      final legacy = _tokenTx(chainId: null, assetSymbol: null);

      Hive.registerAdapter(_LegacyTransactionAdapter(), override: true);
      var box = await Hive.openBox<Transaction>('legacy_transactions');
      await box.put('row', legacy);
      await box.close();

      Hive.registerAdapter(TransactionAdapter(), override: true);
      box = await Hive.openBox<Transaction>('legacy_transactions');
      final read = box.get('row')!;

      expect(read.hash, legacy.hash);
      expect(read.fromAddress, legacy.fromAddress);
      expect(read.coinSymbol, legacy.coinSymbol);
      expect(read.fees, legacy.fees);
      expect(read.transactionStatus, legacy.transactionStatus);
      expect(read.transactionDirection, legacy.transactionDirection);
      expect(read.recipients.single.toAddr, legacy.recipients.single.toAddr);
      expect(read.recipients.single.amount, legacy.recipients.single.amount);
      expect(read.assetSymbol, isNull);
      expect(read.chainId, isNull);
    });
  });
}

/// The adapter this repo shipped before this phase: exactly 18 fields (0-17),
/// no knowledge of `assetSymbol`/`chainId`. Kept here, not imported, because
/// the real adapter has already moved on to 20 — this is what "an older
/// build wrote" means, pinned as code rather than as a claim.
class _LegacyTransactionAdapter extends TypeAdapter<Transaction> {
  @override
  final typeId = 8;

  @override
  Transaction read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Transaction(
      hash: fields[0] as String,
      fromAddress: fields[1] as String,
      recipients: (fields[2] as List).cast<TransferRecipients>(),
      timeStamp: fields[3] as DateTime,
      transactionDirection: fields[4] as TransactionDirection,
      fees: fields[5] as String,
      coinSymbol: fields[6] as String,
      transactionStatus: fields[7] as TransactionStatus,
      isSGNUS: fields[8] as bool?,
      type: fields[9] as TransactionType?,
      fromIconUrl: fields[10] as String?,
      fromAmount: fields[11] as String?,
      toIconUrl: fields[12] as String?,
      toAmount: fields[13] as String?,
      exchangeRate: fields[14] as String?,
      fromSymbol: fields[15] as String?,
      toSymbol: fields[16] as String?,
      recoveryUrl: fields[17] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, Transaction obj) {
    writer
      ..writeByte(18)
      ..writeByte(0)
      ..write(obj.hash)
      ..writeByte(1)
      ..write(obj.fromAddress)
      ..writeByte(2)
      ..write(obj.recipients)
      ..writeByte(3)
      ..write(obj.timeStamp)
      ..writeByte(4)
      ..write(obj.transactionDirection)
      ..writeByte(5)
      ..write(obj.fees)
      ..writeByte(6)
      ..write(obj.coinSymbol)
      ..writeByte(7)
      ..write(obj.transactionStatus)
      ..writeByte(8)
      ..write(obj.isSGNUS)
      ..writeByte(9)
      ..write(obj.type)
      ..writeByte(10)
      ..write(obj.fromIconUrl)
      ..writeByte(11)
      ..write(obj.fromAmount)
      ..writeByte(12)
      ..write(obj.toIconUrl)
      ..writeByte(13)
      ..write(obj.toAmount)
      ..writeByte(14)
      ..write(obj.exchangeRate)
      ..writeByte(15)
      ..write(obj.fromSymbol)
      ..writeByte(16)
      ..write(obj.toSymbol)
      ..writeByte(17)
      ..write(obj.recoveryUrl);
  }
}
