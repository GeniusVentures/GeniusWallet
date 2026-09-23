// The ERC-20 send: a built `transfer` call decodes back to exactly
// what the form asked for -- the app's own dApp decoder is the self-check --
// and a token send runs review-to-resolved on a fake API, gated on the
// native (gas) balance rather than the token balance for the fee.
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:genius_api/genius_api.dart';
import 'package:genius_api/models/coin.dart';
import 'package:genius_api/models/network.dart';
import 'package:genius_api/web3/api_response.dart';
import 'package:genius_api/web3/send_service.dart';
import 'package:genius_wallet/dashboard/transactions/cubit/transactions_cubit.dart';
import 'package:genius_wallet/hive/services/transaction_storage_service.dart';
import 'package:genius_wallet/reown/calldata_decoder.dart';
import 'package:genius_wallet/send/send_cubit.dart';
import 'package:web3dart/web3dart.dart' show TransactionReceipt, bytesToHex;

const _hash = '0xfeedfacefeedfacefeedfacefeedfacefeedface';
const _walletAddress = '0xSENDSENDSENDSENDSENDSENDSENDSENDSENDSEND';
const _recipient = '0x1234567890123456789012345678901234567890';
// The real mainnet USDC contract -- a stable, recognisable fixture address,
// not a claim this test sends anything on mainnet.
const _usdcContract = '0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48';

const _amoy = Network(
  name: 'Polygon Amoy',
  symbol: 'matic',
  chainId: 80002,
  rpcUrl: 'https://rpc.invalid',
);

const _usdcCoin = Coin(
  symbol: 'usdc',
  address: _usdcContract,
  decimals: '6',
  balance: 100,
);

SendFee _fee() => SendFee(
  maxFeePerGas: BigInt.from(30000000000),
  maxPriorityFeePerGas: BigInt.from(1500000000),
  gasLimit: BigInt.from(60000),
);

TransactionReceipt _completedReceipt() => TransactionReceipt.fromMap({
  'transactionHash': _hash,
  'transactionIndex': '0x0',
  'blockHash': _hash,
  'cumulativeGasUsed': '0xea60',
  'gasUsed': '0xea60',
  'effectiveGasPrice': '30000000000',
  'status': '0x1',
});

class _RecordingStorage implements TransactionStorageService {
  final List<Transaction> writes = [];

  @override
  Future<void> addTransaction(String walletAddress, Transaction tx) async =>
      writes.add(tx);

  @override
  dynamic noSuchMethod(Invocation i) => super.noSuchMethod(i);
}

/// A token send's reads: a fixed fee, a token balance and a native balance
/// each independently configurable, one poll settling at once.
class _ConfigurableApi implements GeniusApi {
  _ConfigurableApi({BigInt? tokenBalance, BigInt? nativeBalanceAmount})
    : tokenBalance = tokenBalance ?? BigInt.parse('10000000'), // 10 USDC
      nativeBalanceAmount =
          nativeBalanceAmount ?? BigInt.parse('10000000000000000000');

  final BigInt tokenBalance;
  final BigInt nativeBalanceAmount;
  int signCalls = 0;
  Map<String, dynamic>? signedTx;

  @override
  Future<BigInt> rawBalanceOf({
    required String address,
    required String contractAddress,
    required String rpcUrl,
  }) async => tokenBalance;

  @override
  Future<BigInt> nativeBalance({
    required String address,
    required String rpcUrl,
  }) async => nativeBalanceAmount;

  /// Reverts like a real `estimateGas` does on a transfer beyond balance.
  @override
  Future<SendFee> estimateSendFee({
    required String rpcUrl,
    required String sender,
    required String recipient,
    Uint8List? data,
  }) async {
    final transfer = tryDecodeErc20Transfer(
      data == null ? null : bytesToHex(data, include0x: true),
    );
    if (transfer != null && transfer.amount > tokenBalance) {
      throw Exception('execution reverted: transfer amount exceeds balance');
    }
    return _fee();
  }

  @override
  Future<ApiResponse<String>> signAndSendTransaction({
    required Map<String, dynamic> tx,
    required String rpcUrl,
    required String address,
    required int sourceChainId,
  }) async {
    signCalls++;
    signedTx = tx;
    return ApiResponse.success(_hash);
  }

  @override
  Future<TransactionReceipt?> transactionReceipt({
    required String hash,
    required String rpcUrl,
  }) async => _completedReceipt();

  @override
  dynamic noSuchMethod(Invocation i) => super.noSuchMethod(i);
}

SendCubit _cubit({
  required _ConfigurableApi api,
  Coin coin = _usdcCoin,
  TransactionStorageService? storage,
}) => SendCubit(
  api: api,
  walletAddress: _walletAddress,
  network: _amoy,
  transactions: TransactionsCubit(),
  storage: storage ?? _RecordingStorage(),
  initialCoin: coin,
  wait: (d) async {},
);

void main() {
  group('erc20TransferCalldata', () {
    test(
      'decodes back to the recipient and 5 USDC in base units (6 decimals)',
      () {
        final data = erc20TransferCalldata(
          tokenContract: _usdcContract,
          recipient: _recipient,
          amount: BigInt.from(5000000),
        );
        final decoded = tryDecodeErc20Transfer(
          bytesToHex(data, include0x: true),
        );

        expect(decoded, isNotNull);
        expect(
          decoded!.counterparty.eip55With0x.toLowerCase(),
          _recipient.toLowerCase(),
        );
        expect(decoded.amount, BigInt.from(5000000));
      },
    );
  });

  group('summarizeTransaction', () {
    test('a built USDC transfer reads as a token transfer of 5', () {
      final data = erc20TransferCalldata(
        tokenContract: _usdcContract,
        recipient: _recipient,
        amount: BigInt.from(5000000),
      );
      final tx = {
        'to': _usdcContract,
        'value': '0x0',
        'data': bytesToHex(data, include0x: true),
      };

      final summary = summarizeTransaction(
        tx,
        coins: const [_usdcCoin],
        chainId: 80002,
        nativeSymbol: 'MATIC',
      );

      expect(summary.kind, DappCallKind.tokenTransfer);
      expect(summary.recipient?.toLowerCase(), _recipient.toLowerCase());
      expect(summary.amount, '5');
      expect(summary.symbol, 'usdc');
    });
  });

  group('SendCubit token send', () {
    test(
      'reviews and submits 5 USDC: decoded recipient, token-labelled row',
      () async {
        final api = _ConfigurableApi();
        final storage = _RecordingStorage();
        final cubit = _cubit(api: api, storage: storage);
        cubit.setRecipient(_recipient);
        cubit.setAmount('5');

        await cubit.review();

        final review = cubit.state.review;
        expect(review, isNotNull);
        expect(
          (review!.tx['to'] as String).toLowerCase(),
          _usdcContract.toLowerCase(),
        );
        expect(review.tx['value'], '0x0');
        expect((review.tx['data'] as String).startsWith('0xa9059cbb'), isTrue);

        final resolved = await cubit.submit();

        expect(resolved, isNotNull);
        expect(resolved!.assetSymbol, 'USDC');
        expect(resolved.coinSymbol, 'MATIC');
        expect(resolved.chainId, 80002);
        expect(
          resolved.recipients.single.toAddr.toLowerCase(),
          _recipient.toLowerCase(),
        );
        expect(resolved.recipients.single.amount, '5');
        expect(storage.writes.length, 2);
      },
    );

    test(
      'a token balance short of the amount refuses naming the token',
      () async {
        final api = _ConfigurableApi(tokenBalance: BigInt.from(1000000));
        final cubit = _cubit(api: api);
        cubit.setRecipient(_recipient);
        cubit.setAmount('5');

        await cubit.review();

        expect(cubit.state.error, contains('USDC'));
        expect(cubit.state.review, isNull);
      },
    );

    test('a native balance short of the fee refuses naming the gas coin, even '
        'with plenty of the token', () async {
      final api = _ConfigurableApi(nativeBalanceAmount: BigInt.zero);
      final cubit = _cubit(api: api);
      cubit.setRecipient(_recipient);
      cubit.setAmount('5');

      await cubit.review();

      expect(cubit.state.error, contains('MATIC'));
      expect(cubit.state.review, isNull);
    });

    test('token MAX is the raw balance, dust digit included', () async {
      final api = _ConfigurableApi(tokenBalance: BigInt.from(12345678));
      final cubit = _cubit(api: api);

      await cubit.useMax();

      expect(cubit.state.amount, '12.345678');
      expect(cubit.state.error, isNull);
    });

    test('unknown decimals refuses before any RPC read', () async {
      final api = _ConfigurableApi();
      final cubit = _cubit(
        api: api,
        coin: const Coin(symbol: 'weird', address: _usdcContract),
      );
      cubit.setRecipient(_recipient);
      cubit.setAmount('5');

      await cubit.review();

      expect(cubit.state.error, "This token's decimals are unknown.");
      expect(cubit.state.review, isNull);
      expect(api.signCalls, 0);
    });
  });
}
