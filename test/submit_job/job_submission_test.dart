import 'dart:async';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:genius_api/ffi/genius_api_ffi.dart';
import 'package:genius_api/genius_api.dart';
import 'package:genius_api/web3/api_response.dart';
import 'package:genius_api/web3/bridge_out_abi.dart'
    show bridgeCreditFailedMessage;
import 'package:genius_wallet/dev/dev_mock_job.dart';
import 'package:genius_wallet/submit_job/cubit/submit_job_state.dart';
import 'package:genius_wallet/submit_job/job_submission.dart';

class _BurnCall {
  _BurnCall({
    required this.contractAddress,
    required this.rpcUrl,
    required this.address,
    required this.amountToBurn,
    required this.sourceChainId,
    required this.destinationChainId,
    this.sgnsAccount,
  });

  final String? sgnsAccount;
  final String contractAddress;
  final String rpcUrl;
  final String address;
  final String amountToBurn;
  final int sourceChainId;
  final int destinationChainId;
}

/// Records every call it receives; anything it does not override throws
/// through `noSuchMethod`.
class _FakeGeniusApi implements GeniusApi {
  ApiResponse<String> bridgeOutResponse = ApiResponse.success('0xHASH');
  GeniusNodeReturnValue processResponse =
      GeniusNodeReturnValue.GENIUS_NODE_RET_OK;
  bool processThrows = false;

  int costResponse = 10;
  ApiResponse<String> gasResponse = ApiResponse.success('1.00 Gwei');

  final List<_BurnCall> burns = [];

  /// Runs inside the burn, before it answers.
  Future<void> Function()? onBurn;
  final List<String> processed = [];
  final List<String> costed = [];
  final List<_BurnCall> gasCalls = [];
  final List<String> order = [];

  @override
  Future<int> requestGeniusSDKCostAsync({required String jobJson}) async {
    costed.add(jobJson);
    return costResponse;
  }

  @override
  Future<ApiResponse<String>> getBrigeOutGasCost({
    required String contractAddress,
    required String rpcUrl,
    required String address,
    required String amountToBurn,
    required int sourceChainId,
    required int destinationChainId,
  }) async {
    gasCalls.add(
      _BurnCall(
        contractAddress: contractAddress,
        rpcUrl: rpcUrl,
        address: address,
        amountToBurn: amountToBurn,
        sourceChainId: sourceChainId,
        destinationChainId: destinationChainId,
      ),
    );
    return gasResponse;
  }

  @override
  Future<ApiResponse<String>> bridgeOut({
    required String contractAddress,
    required String rpcUrl,
    required String address,
    required String amountToBurn,
    required int sourceChainId,
    required int destinationChainId,
    String? sgnsAccount,
    Future<void> Function(String txHash)? beforeBroadcast,
  }) async {
    order.add('burn');
    await onBurn?.call();
    burns.add(
      _BurnCall(
        contractAddress: contractAddress,
        rpcUrl: rpcUrl,
        address: address,
        amountToBurn: amountToBurn,
        sourceChainId: sourceChainId,
        destinationChainId: destinationChainId,
        sgnsAccount: sgnsAccount,
      ),
    );
    return bridgeOutResponse;
  }

  @override
  Future<GeniusNodeReturnValue> requestGeniusSDKProcessAsync({
    required String jobJson,
  }) async {
    order.add('process');
    processed.add(jobJson);
    if (processThrows) {
      throw StateError('isolate failed');
    }
    return processResponse;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

const _facts = JobFacts(
  chainId: 1,
  rpcUrl: 'https://example.invalid',
  walletAddress: '0xWALLET',
  gnusAddress: '0xGNUS',
);

const _job = {'job': 'spec'};

void main() {
  late _FakeGeniusApi api;
  late JobSubmission owner;

  setUp(() {
    api = _FakeGeniusApi();
    owner = JobSubmission(geniusApi: api);
  });

  tearDown(() {
    DevMockJob.instance.clear();
  });

  group('submit', () {
    test('a successful burn and process returns JobDone', () async {
      final result = await owner.submit(_facts, jobCost: 10, jobJson: _job);

      expect(result, isA<JobDone>());
      expect((result as JobDone).txHash, '0xHASH');
      expect(api.burns, hasLength(1));
      final burn = api.burns.single;
      expect(burn.amountToBurn, '10');
      expect(burn.destinationChainId, 15305752297694);
      expect(burn.sourceChainId, 1);
      expect(burn.contractAddress, '0xGNUS');
      expect(burn.rpcUrl, 'https://example.invalid');
      expect(burn.address, '0xWALLET');
      expect(api.processed, ['{"job":"spec"}']);
    });

    test('a confirmed node account is the burn destination', () async {
      final node = '0x${'ab' * 64}';
      await owner.submit(
        _facts,
        jobCost: 10,
        jobJson: _job,
        expectedNode: node,
      );

      expect(api.burns.single.sgnsAccount, node);
    });

    test(
      'with no node account the burn leaves the destination to the API',
      () async {
        await owner.submit(_facts, jobCost: 10, jobJson: _job);

        expect(api.burns.single.sgnsAccount, isNull);
      },
    );

    final missing =
        <String, ({JobFacts facts, int cost, Map<String, dynamic> job})>{
          'chainId': (
            facts: const JobFacts(
              chainId: null,
              rpcUrl: 'u',
              walletAddress: 'w',
              gnusAddress: 'g',
            ),
            cost: 10,
            job: _job,
          ),
          'rpcUrl': (
            facts: const JobFacts(
              chainId: 1,
              rpcUrl: null,
              walletAddress: 'w',
              gnusAddress: 'g',
            ),
            cost: 10,
            job: _job,
          ),
          'walletAddress': (
            facts: const JobFacts(
              chainId: 1,
              rpcUrl: 'u',
              walletAddress: null,
              gnusAddress: 'g',
            ),
            cost: 10,
            job: _job,
          ),
          'gnusAddress': (
            facts: const JobFacts(
              chainId: 1,
              rpcUrl: 'u',
              walletAddress: 'w',
              gnusAddress: null,
            ),
            cost: 10,
            job: _job,
          ),
          'jobCost': (facts: _facts, cost: 0, job: _job),
          'jobJson': (facts: _facts, cost: 10, job: const <String, dynamic>{}),
        };
    missing.forEach((name, input) {
      test(
        'a missing $name returns JobMissingData and calls nothing',
        () async {
          final result = await owner.submit(
            input.facts,
            jobCost: input.cost,
            jobJson: input.job,
          );

          expect(result, isA<JobMissingData>());
          expect(api.burns, isEmpty);
          expect(api.processed, isEmpty);
        },
      );
    });

    test(
      'a failed burn returns JobBridgeFailed and does not process',
      () async {
        api.bridgeOutResponse = ApiResponse.error('boom');

        final result = await owner.submit(_facts, jobCost: 10, jobJson: _job);

        expect(result, isA<JobBridgeFailed>());
        expect(api.processed, isEmpty);
      },
    );

    test('an unconfirmed burn returns its hash and does not process', () async {
      api.bridgeOutResponse = ApiResponse.unconfirmed('0xHASH', 'reset');

      final result = await owner.submit(_facts, jobCost: 10, jobJson: _job);

      expect(result, isA<JobBurnUnconfirmed>());
      expect((result as JobBurnUnconfirmed).bridgeHash, '0xHASH');
      expect(api.processed, isEmpty);
    });

    test('a burn the wallet could not credit keeps the hash and does not '
        'process', () async {
      api.bridgeOutResponse = ApiResponse.unconfirmed(
        '0xHASH',
        bridgeCreditFailedMessage,
      );

      final result = await owner.submit(_facts, jobCost: 10, jobJson: _job);

      expect(result, isA<JobBridgedNotProcessed>());
      final bridged = result as JobBridgedNotProcessed;
      expect(bridged.bridgeHash, '0xHASH');
      expect(
        bridged.processResult,
        GeniusNodeReturnValue.GENIUS_NODE_ERROR_MINT,
      );
      expect(api.processed, isEmpty);
    });

    test('a reverted burn is a settled failure and does not process', () async {
      api.bridgeOutResponse = ApiResponse.reverted('0xHASH', 'reverted');

      final result = await owner.submit(_facts, jobCost: 10, jobJson: _job);

      expect(result, isA<JobBridgeFailed>());
      expect((result as JobBridgeFailed).reverted, isTrue);
      expect(api.processed, isEmpty);
    });

    test('a burn that succeeds but fails to process keeps the hash', () async {
      api.processResponse =
          GeniusNodeReturnValue.GENIUS_NODE_ERROR_PROCESS_IMAGE;

      final result = await owner.submit(_facts, jobCost: 10, jobJson: _job);

      expect(result, isA<JobBridgedNotProcessed>());
      final bridged = result as JobBridgedNotProcessed;
      expect(bridged.bridgeHash, '0xHASH');
      expect(
        bridged.processResult,
        GeniusNodeReturnValue.GENIUS_NODE_ERROR_PROCESS_IMAGE,
      );
    });

    test('a process call that throws after the burn keeps the hash', () async {
      api.processThrows = true;

      final result = await owner.submit(_facts, jobCost: 10, jobJson: _job);

      expect(result, isA<JobBridgedNotProcessed>());
      final bridged = result as JobBridgedNotProcessed;
      expect(bridged.bridgeHash, '0xHASH');
      expect(
        bridged.processResult,
        GeniusNodeReturnValue.GENIUS_NODE_ERROR_NOT_INITIALIZED,
      );
    });
  });

  group('one submit at a time', () {
    test('a second instance gets JobBusy while a submit runs, and burns '
        'nothing', () async {
      final release = Completer<void>();
      api.onBurn = () => release.future;
      final first = owner.submit(_facts, jobCost: 10, jobJson: _job);

      final second = await JobSubmission(
        geniusApi: api,
      ).submit(_facts, jobCost: 10, jobJson: _job);

      expect(second, isA<JobBusy>());
      release.complete();
      expect(await first, isA<JobDone>());
      expect(api.order.where((call) => call == 'burn'), hasLength(1));
    });

    test('the slot frees after a submit ends, failed or not', () async {
      api.bridgeOutResponse = ApiResponse.error('no');
      expect(
        await owner.submit(_facts, jobCost: 10, jobJson: _job),
        isA<JobBridgeFailed>(),
      );
      api.bridgeOutResponse = ApiResponse.success('0xHASH');

      expect(
        await JobSubmission(
          geniusApi: api,
        ).submit(_facts, jobCost: 10, jobJson: _job),
        isA<JobDone>(),
      );
    });
  });

  group('onBurned', () {
    test(
      'runs once with the burn hash, between the burn and the process',
      () async {
        final seen = <String>[];

        final result = await owner.submit(
          _facts,
          jobCost: 10,
          jobJson: _job,
          onBurned: (hash) async {
            api.order.add('onBurned');
            seen.add(hash);
          },
        );

        expect(result, isA<JobDone>());
        expect(seen, ['0xHASH']);
        expect(api.order, ['burn', 'onBurned', 'process']);
      },
    );

    test('is not called when the burn fails', () async {
      api.bridgeOutResponse = ApiResponse.error('no');
      var called = false;

      final result = await owner.submit(
        _facts,
        jobCost: 10,
        jobJson: _job,
        onBurned: (_) async => called = true,
      );

      expect(result, isA<JobBridgeFailed>());
      expect(called, isFalse);
    });

    test('is not called when data is missing', () async {
      var called = false;

      final result = await owner.submit(
        _facts,
        jobCost: 0,
        jobJson: _job,
        onBurned: (_) async => called = true,
      );

      expect(result, isA<JobMissingData>());
      expect(called, isFalse);
    });

    test('a callback that throws still lets the process call run', () async {
      final result = await owner.submit(
        _facts,
        jobCost: 10,
        jobJson: _job,
        onBurned: (_) async => throw StateError('disk full'),
      );

      expect(result, isA<JobDone>());
      expect((result as JobDone).txHash, '0xHASH');
      expect(api.processed, hasLength(1));
    });
  });

  group('cost', () {
    test(
      'a priced job returns JobCostOk with the job JSON unchanged',
      () async {
        final result = await owner.cost('{"job":"spec"}');

        expect(result, isA<JobCostOk>());
        expect((result as JobCostOk).minions, 10);
        expect(api.costed, ['{"job":"spec"}']);
      },
    );

    test('a cost of zero returns JobCostFailed with no reason', () async {
      api.costResponse = 0;

      final result = await owner.cost('{}');

      expect(result, isA<JobCostFailed>());
      expect((result as JobCostFailed).reason, isNull);
    });

    test('an armed costFailure with the gate closed still prices', () async {
      DevMockJob.instance.arm(DevJobScenario.costFailure);

      final result = await owner.cost('{}');

      expect(result, isA<JobCostOk>());
      expect((result as JobCostOk).minions, 10);
    });
  });

  group('estimateGas', () {
    final missing = <String, JobFacts>{
      'chainId': const JobFacts(
        chainId: null,
        rpcUrl: 'u',
        walletAddress: 'w',
        gnusAddress: 'g',
      ),
      'rpcUrl': const JobFacts(
        chainId: 1,
        rpcUrl: null,
        walletAddress: 'w',
        gnusAddress: 'g',
      ),
      'walletAddress': const JobFacts(
        chainId: 1,
        rpcUrl: 'u',
        walletAddress: null,
        gnusAddress: 'g',
      ),
      'gnusAddress': const JobFacts(
        chainId: 1,
        rpcUrl: 'u',
        walletAddress: 'w',
        gnusAddress: null,
      ),
    };
    missing.forEach((name, facts) {
      test('a missing $name returns GasEstimateMissingData', () async {
        final result = await owner.estimateGas(facts, 10);

        expect(result, isA<GasEstimateMissingData>());
        expect(api.gasCalls, isEmpty);
      });
    });

    test('a successful estimate returns GasEstimateOk', () async {
      final result = await owner.estimateGas(_facts, 10);

      expect(result, isA<GasEstimateOk>());
      expect((result as GasEstimateOk).gas, '1.00 Gwei');
      final call = api.gasCalls.single;
      expect(call.amountToBurn, '10');
      expect(call.destinationChainId, 15305752297694);
    });

    test('the bridge error message passes through untouched', () async {
      api.gasResponse = ApiResponse.error(
        'Not enough funds for gas to bridge tokens',
      );

      final result = await owner.estimateGas(_facts, 10);

      expect(result, isA<GasEstimateFailed>());
      expect(
        (result as GasEstimateFailed).reason,
        'Not enough funds for gas to bridge tokens',
      );
    });

    test(
      'an armed pricedOk with the gate closed still checks the facts',
      () async {
        DevMockJob.instance.arm(DevJobScenario.pricedOk);

        final result = await owner.estimateGas(
          const JobFacts(
            chainId: null,
            rpcUrl: null,
            walletAddress: null,
            gnusAddress: null,
          ),
          10,
        );

        expect(result, isA<GasEstimateMissingData>());
      },
    );
  });

  test('the cubit makes no direct job-flow call', () {
    final call = RegExp(
      r'\.(bridgeOut|getBrigeOutGasCost|requestGeniusSDKCost|requestGeniusSDKProcess)(Async)?\(',
    );
    expect(call.hasMatch('geniusApi.bridgeOut('), isTrue);
    expect(call.hasMatch('x.requestGeniusSDKCostAsync('), isTrue);

    final source = File('lib/submit_job/cubit/submit_job_cubit.dart')
        .readAsLinesSync()
        .where((line) => !line.trimLeft().startsWith('//'))
        .join('\n');

    expect(call.allMatches(source).map((m) => m.group(0)), isEmpty);
  });

  group('dev fixture release safety', () {
    test(
      'an armed scenario with the gate closed takes the real path',
      () async {
        DevMockJob.instance.arm(DevJobScenario.bridgeFailed);

        expect(JobSubmission.devToolsEnabled, isFalse);
        expect(owner.devScenario, isNull);
        expect(owner.fixtureBalance, isNull);
        expect((await owner.cost('{}')).fixtureBalance, isNull);

        final result = await owner.submit(_facts, jobCost: 10, jobJson: _job);

        expect(result, isA<JobDone>());
        expect(api.burns, hasLength(1));
      },
    );

    test('devSubmitResult maps each fixture outcome', () {
      final done = JobSubmission.devSubmitResult(SubmitOutcome.done);
      expect((done as JobDone).txHash, DevMockJob.txHash);

      expect(
        JobSubmission.devSubmitResult(SubmitOutcome.bridgeFailed),
        isA<JobBridgeFailed>(),
      );

      final bridged =
          JobSubmission.devSubmitResult(SubmitOutcome.bridgedNotProcessed)
              as JobBridgedNotProcessed;
      expect(bridged.bridgeHash, DevMockJob.bridgeHash);
      expect(bridged.processResult, DevMockJob.processFailure);

      expect(
        () => JobSubmission.devSubmitResult(SubmitOutcome.notSubmitted),
        throwsStateError,
      );
    });
  });
}
