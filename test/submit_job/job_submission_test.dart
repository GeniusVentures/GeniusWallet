import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:genius_api/ffi/genius_api_ffi.dart';
import 'package:genius_api/genius_api.dart';
import 'package:genius_api/web3/api_response.dart';
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
  });

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

  int costResponse = 10;
  ApiResponse<String> gasResponse = ApiResponse.success('1.00 Gwei');

  final List<_BurnCall> burns = [];
  final List<String> processed = [];
  final List<String> costed = [];
  final List<_BurnCall> gasCalls = [];

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
    bool shouldMintTokens = false,
  }) async {
    burns.add(
      _BurnCall(
        contractAddress: contractAddress,
        rpcUrl: rpcUrl,
        address: address,
        amountToBurn: amountToBurn,
        sourceChainId: sourceChainId,
        destinationChainId: destinationChainId,
      ),
    );
    return bridgeOutResponse;
  }

  @override
  Future<GeniusNodeReturnValue> requestGeniusSDKProcessAsync({
    required String jobJson,
  }) async {
    processed.add(jobJson);
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
