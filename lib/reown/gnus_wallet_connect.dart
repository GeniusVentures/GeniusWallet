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

/// Why a `gnus_*` proposal was turned away.
enum GnusRefusal { unverified, flagged }

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

bool _isLoopback(GnusOrigin origin) {
  final host = Uri.parse(origin.value).host;
  return host == 'localhost' || host == '127.0.0.1';
}

/// The caller [url] names, or null where this build refuses it: https only,
/// plus http on a loopback host in a dev build, as the web view allowlist.
GnusOrigin? _walletConnectOrigin(String url, {required bool devBuild}) {
  final origin = GnusOrigin.tryParse(GnusTransport.walletconnect, url);
  if (origin == null) {
    return null;
  }
  final https = origin.value.startsWith('https://');
  if (_isLoopback(origin)) {
    return devBuild && !https ? origin : null;
  }
  return https ? origin : null;
}

/// The caller a `gnus_*` proposal is, or why it is refused. Verify must say
/// VALID. Unknown passes only in a dev build for a loopback host, and that
/// host is refused in every other build.
({GnusOrigin? origin, GnusRefusal? refusal}) gnusProposalOrigin(
  VerifyContext? verifyContext,
  String metadataUrl, {
  required bool devBuild,
}) {
  final validation = verifyContext?.validation ?? Validation.UNKNOWN;
  if (validation == Validation.SCAM ||
      validation == Validation.INVALID ||
      verifyContext?.isScam == true) {
    return (origin: null, refusal: GnusRefusal.flagged);
  }
  final origin = _walletConnectOrigin(metadataUrl, devBuild: devBuild);
  if (origin != null &&
      (validation == Validation.VALID || _isLoopback(origin))) {
    return (origin: origin, refusal: null);
  }
  return (origin: null, refusal: GnusRefusal.unverified);
}

/// The caller behind a session, or null when it no longer qualifies: the
/// proposal was checked once, so a session restored into a build that would
/// refuse it now gets `4100`.
GnusOrigin? gnusSessionOrigin(SessionData session, {required bool devBuild}) =>
    _walletConnectOrigin(session.peer.metadata.url, devBuild: devBuild);

Set<String> _approvedGnusEvents(SessionData session) => {
  for (final event in session.namespaces['eip155']?.events ?? const <String>[])
    if (_gnusEvents.contains(event)) event,
};

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
  final forwarding = <String, StreamSubscription<GnusEvent>>{};

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

  // A failed emit is dropped: every reply reads the current state, so a page
  // that missed an event is not left with a stale answer.
  void forward(SessionData session) {
    final topic = session.topic;
    final approved = _approvedGnusEvents(session);
    final origin = gnusSessionOrigin(session, devBuild: devBuild);
    if (forwarding.containsKey(topic) || approved.isEmpty || origin == null) {
      return;
    }
    forwarding[topic] = handler.eventsFor(origin).listen((event) {
      if (!approved.contains(event.name)) {
        return;
      }
      unawaited(
        enqueue(topic, () async {
          if (!active(topic)) {
            return;
          }
          try {
            await walletKit.emitSessionEvent(
              topic: topic,
              chainId: kGnusWalletConnectChain,
              event: SessionEventParams(name: event.name, data: event.payload),
            );
          } catch (e) {
            debugPrint('gnus_wc ${event.name} not sent ${e.runtimeType}');
          }
        }),
      );
    });
  }

  void stopForwarding(String topic) {
    unawaited(forwarding.remove(topic)?.cancel());
    tails.remove(topic);
  }

  void onConnect(SessionConnect? event) {
    if (event != null) {
      forward(event.session);
    }
  }

  void onDelete(SessionDelete? event) {
    if (event != null) {
      stopForwarding(event.topic);
    }
  }

  void onExpire(SessionExpire? event) {
    if (event != null) {
      stopForwarding(event.topic);
    }
  }

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
  walletKit.onSessionConnect.subscribe(onConnect);
  walletKit.onSessionDelete.subscribe(onDelete);
  walletKit.onSessionExpire.subscribe(onExpire);
  walletKit.getActiveSessions().values.forEach(forward);

  return () {
    walletKit.onSessionRequest.unsubscribe(onRequest);
    walletKit.onSessionConnect.unsubscribe(onConnect);
    walletKit.onSessionDelete.unsubscribe(onDelete);
    walletKit.onSessionExpire.unsubscribe(onExpire);
    for (final subscription in forwarding.values) {
      unawaited(subscription.cancel());
    }
    forwarding.clear();
    tails.clear();
  };
}
