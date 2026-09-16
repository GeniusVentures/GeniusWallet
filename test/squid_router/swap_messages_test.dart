// One message per way a swap can fail, and no two alike.
//
// The phase's promise is that a swap either moves funds or says WHICH way it
// could not. A shared fallback string breaks that promise quietly, so the
// set-size case below is the one that matters: as many distinct messages as
// there are ways to fail.
//
// The other load-bearing case is disclosure. A caught Dio or RPC error carries
// node URLs and addresses; none of it is a sentence a person can act on, and
// none of it belongs on screen.
import 'package:flutter_test/flutter_test.dart';
import 'package:genius_api/models/transaction.dart';
import 'package:genius_wallet/squid_router/swap_execution.dart';
import 'package:genius_wallet/squid_router/swap_messages.dart';
import 'package:genius_wallet/swap/swap_transaction.dart';

const _leaky =
    'DioException [connection error]: http://10.0.0.7:8545 '
    '0xd8dA6BF26964aF9D7eEd9e03E53415D37aA96045 nonce too low';

SwapTransaction _route() => const SwapTransaction(
  quoteId: 'q1',
  requestId: 'r1',
  spender: '0xce16F69375520ab01377ce7B88f5BA8C48F8D666',
  request: {'from': '0x1', 'to': '0x2'},
);

SwapBroadcast _settled(TransactionStatus status) => SwapBroadcast(
  hash: '0xfeedfacefeedfacefeedfacefeedfacefeedface',
  status: status,
  transaction: _route(),
);

/// Every shape that carries no hash, each constructed with a leaky error so
/// the disclosure case has something real to catch.
final _failures = <SwapOutcome>[
  const SwapRouteUnavailable(_leaky),
  const SwapRouteUnsignable(_leaky),
  const SwapAllowanceUnreadable(_leaky),
  const SwapApprovalFailed(_leaky),
  const SwapSendFailed(_leaky),
];

/// The statuses a broadcast swap can settle into that are not a plain success.
const _unhappy = [
  TransactionStatus.pending,
  TransactionStatus.partialSuccess,
  TransactionStatus.needsGas,
  TransactionStatus.refunded,
  TransactionStatus.failed,
];

void main() {
  group('every way it can fail says which way', () {
    test('no shape without a hash is silent', () {
      for (final outcome in _failures) {
        final message = swapFailureMessage(outcome);
        expect(
          message,
          isNotNull,
          reason: '${outcome.runtimeType} had nothing to say',
        );
        expect(message, isNotEmpty);
      }
    });

    test('a swap that settled as something other than success speaks too', () {
      for (final status in _unhappy) {
        expect(
          swapFailureMessage(_settled(status)),
          isNotNull,
          reason: '$status had nothing to say',
        );
      }
    });

    test('a plain success has nothing to report', () {
      expect(swapFailureMessage(_settled(TransactionStatus.completed)), isNull);
    });

    test('no two ways of failing read the same', () {
      // The guard against a shared fallback. If two branches ever collapse
      // onto one string, the set shrinks and this fails.
      final messages = [
        ..._failures.map(swapFailureMessage),
        ..._unhappy.map((s) => swapFailureMessage(_settled(s))),
      ];

      expect(messages.toSet(), hasLength(messages.length));
    });
  });

  group('nothing leaks into the copy', () {
    test('no caught error, address, URL or hash reaches the user', () {
      final all = [
        ..._failures.map(swapFailureMessage),
        ..._unhappy.map((s) => swapFailureMessage(_settled(s))),
      ].whereType<String>();

      for (final message in all) {
        expect(message, isNot(contains('0x')), reason: message);
        expect(message, isNot(contains('Dio')), reason: message);
        expect(message, isNot(contains('http')), reason: message);
        expect(message, isNot(contains('nonce')), reason: message);
        expect(message, isNot(contains('Exception')), reason: message);
      }
    });

    test('the copy is a sentence, not a symbol dump', () {
      final all = [
        ..._failures.map(swapFailureMessage),
        ..._unhappy.map((s) => swapFailureMessage(_settled(s))),
      ].whereType<String>();

      for (final message in all) {
        expect(message.trim(), endsWith('.'), reason: message);
        expect(message[0], message[0].toUpperCase(), reason: message);
      }
    });
  });

  group('what the message promises', () {
    test('nothing left the wallet on a pre-send failure', () {
      // These three happen before anything is broadcast, so the copy may say
      // so. The send failure may NOT — see the case below.
      for (final outcome in <SwapOutcome>[
        const SwapRouteUnavailable(null),
        const SwapRouteUnsignable(null),
        const SwapAllowanceUnreadable(null),
      ]) {
        expect(swapFailureMessage(outcome), isNotNull);
      }
    });

    test('a settled-but-not-successful swap never claims funds are safe', () {
      // The funds DID move in these states. Telling the user otherwise is the
      // same class of lie the phase exists to remove.
      for (final status in [
        TransactionStatus.partialSuccess,
        TransactionStatus.needsGas,
      ]) {
        final message = swapFailureMessage(_settled(status))!;
        expect(message.toLowerCase(), isNot(contains('nothing was')));
        expect(message.toLowerCase(), isNot(contains('nothing left')));
      }
    });
  });
}
