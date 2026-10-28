import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:genius_wallet/gnus_bridge/gnus_origin.dart';
import 'package:genius_wallet/gnus_bridge/gnus_rpc_contract.dart';
import 'package:genius_wallet/gnus_bridge/gnus_rpc_handler.dart';
import 'package:reown_walletkit/reown_walletkit.dart';

/// The chain every `gnus_*` event rides: where the bridge burn lives.
const String kGnusWalletConnectChain = 'eip155:80002';
const int kGnusWalletConnectChainId = 80002;

const Set<String> _gnusEvents = {
  GnusRpcEventName.accountsChanged,
  GnusRpcEventName.networkChanged,
  GnusRpcEventName.jobUpdated,
};

/// Whether [method] is a `gnus_*` call, which only the bridge answers.
bool isGnusMethod(String method) => method.startsWith('gnus_');

Iterable<RequiredNamespace> _eip155(ProposalData proposal) => [
  for (final entry in [
    ...proposal.requiredNamespaces.entries,
    ...proposal.optionalNamespaces.entries,
  ])
    if (entry.key == 'eip155' || entry.key.startsWith('eip155:')) entry.value,
];

/// The `gnus_*` methods the page asked for that this wallet implements.
Set<String> requestedGnusMethods(ProposalData proposal) => {
  for (final namespace in _eip155(proposal))
    for (final method in namespace.methods)
      if (GnusRpcMethod.all.contains(method)) method,
};

/// The `gnus_*` events the page asked for that this wallet sends.
Set<String> requestedGnusEvents(ProposalData proposal) => {
  for (final namespace in _eip155(proposal))
    for (final event in namespace.events)
      if (_gnusEvents.contains(event)) event,
};

/// The caller a `gnus_*` proposal is: only a page Verify says is VALID.
GnusOrigin? gnusProposalOrigin(VerifyContext? verifyContext, String url) =>
    verifyContext?.validation == Validation.VALID
    ? GnusOrigin.tryParse(GnusTransport.walletconnect, url)
    : null;

/// The caller behind a session, or null when it no longer qualifies: the
/// proposal was checked once, so a session restored into a build that would
/// refuse it now gets `4100`.
GnusOrigin? gnusSessionOrigin(SessionData session, {required bool devBuild}) {
  final origin = GnusOrigin.tryParse(
    GnusTransport.walletconnect,
    session.peer.metadata.url,
  );
  return origin;
}

const GnusRpcError _unauthorized = GnusRpcError(
  GnusRpcCode.unauthorized,
  'Unauthorized',
);

// WalletConnect errors carry a code and a message only, so an error's data
// travels inside the message as JSON.
JsonRpcResponse<Object> _errorResponse(int id, GnusRpcError error) =>
    JsonRpcResponse<Object>(
      id: id,
      error: JsonRpcError(
        code: error.code,
        message: error.data == null
            ? error.message
            : jsonEncode({'message': error.message, 'data': error.data}),
      ),
    );

/// Answers every `gnus_*` request and forwards the connected page's events.
/// Returns the function that detaches it.
void Function() handleGnusRequests({
  required ReownWalletKit walletKit,
  required GnusRpcHandler handler,
  required bool devBuild,
}) {
  final inFlight = <String>{};
  final tails = <String, Future<void>>{};

  // One chain per topic, so replies and events leave in the order they were
  // queued.
  Future<void> enqueue(String topic, Future<void> Function() job) {
    final next = (tails[topic] ?? Future<void>.value())
        .then((_) => job())
        .catchError((Object e) {
          debugPrint('gnus_wc send failed ${e.runtimeType}');
        });
    tails[topic] = next;
    return next;
  }

  bool active(String topic) => walletKit.getActiveSessions().containsKey(topic);

  Future<void> reply(String topic, JsonRpcResponse<Object> response) => enqueue(
    topic,
    () async {
      if (!active(topic)) {
        debugPrint('gnus_wc reply dropped, session gone');
        return;
      }
      try {
        await walletKit.respondSessionRequest(topic: topic, response: response);
      } catch (e) {
        debugPrint('gnus_wc reply failed ${e.runtimeType}');
      }
    },
  );

  Future<JsonRpcResponse<Object>> answer(
    SessionRequestEvent event,
    GnusOrigin origin,
  ) async {
    final name = GnusRpcMethod.all.contains(event.method)
        ? event.method
        : 'unsupported';
    try {
      final result = await handler.handle(origin, event.method, event.params);
      // A null result cannot be sent: the Dart client reads it as "no result".
      return JsonRpcResponse<Object>(
        id: event.id,
        result: result ?? const <String, Object?>{},
      );
    } on GnusRpcError catch (e) {
      return _errorResponse(event.id, e);
    } catch (e) {
      debugPrint('gnus_wc $name failed ${e.runtimeType}');
      return _errorResponse(
        event.id,
        const GnusRpcError(GnusRpcCode.internal, 'Internal error'),
      );
    }
  }

  Future<void> onRequest(SessionRequestEvent? event) async {
    if (event == null || !isGnusMethod(event.method)) {
      return;
    }
    final key = '${event.topic}/${event.id}';
    if (!inFlight.add(key)) {
      return;
    }
    try {
      // ponytail: reown_sign fixes a wallet-side pending request at 5
      // minutes, whatever the page asked. Raise it past the prompt timeout;
      // drop this once Reown honours the request's own expiry.
      try {
        await walletKit.core.expirer.set(
          event.id.toString(),
          ReownCoreUtils.calculateExpiry(kGnusConfirmTimeout.inSeconds + 60),
        );
      } catch (e) {
        debugPrint('gnus_wc expiry not raised ${e.runtimeType}');
      }
      final session = walletKit.getActiveSessions()[event.topic];
      final origin = session == null
          ? null
          : gnusSessionOrigin(session, devBuild: devBuild);
      final response = origin == null
          ? _errorResponse(event.id, _unauthorized)
          : await answer(event, origin);
      await reply(event.topic, response);
    } finally {
      inFlight.remove(key);
    }
  }

  walletKit.onSessionRequest.subscribe(onRequest);

  return () {
    walletKit.onSessionRequest.unsubscribe(onRequest);
  };
}
