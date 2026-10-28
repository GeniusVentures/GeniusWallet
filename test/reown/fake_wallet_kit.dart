import 'dart:async';

import 'package:genius_wallet/reown/wallet_connect_host.dart';

// IExpirer is not re-exported by reown_walletkit.
// ignore: depend_on_referenced_packages
import 'package:reown_core/pairing/i_expirer.dart';
// ignore: depend_on_referenced_packages
import 'package:reown_core/pairing/i_pairing.dart';
import 'package:reown_walletkit/reown_walletkit.dart';

/// Records the expiry the wallet sets on each request id.
class FakeExpirer implements IExpirer {
  final Map<String, int> expiries = {};

  @override
  Future<void> set(String key, int value) async {
    expiries[key] = value;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

/// `create` answers with [uri] once [hold] (when set) completes, or fails.
class FakePairing implements IPairing {
  static const uri = 'wc:own123@2?relay-protocol=irn&symKey=cafebabe';

  Completer<void>? hold;
  bool fail = false;
  int creates = 0;

  @override
  Future<CreateResponse> create({
    List<List<String>>? methods,
    TransportType transportType = TransportType.relay,
  }) async {
    creates++;
    await hold?.future;
    if (fail) {
      throw StateError('relay disconnected');
    }
    return CreateResponse(
      topic: 'own123',
      uri: Uri.parse(uri),
      pairingInfo: PairingInfo(
        topic: 'own123',
        expiry: 0,
        relay: Relay('irn'),
        active: false,
      ),
    );
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class FakeCore implements IReownCore {
  @override
  final FakeExpirer expirer = FakeExpirer();

  @override
  IPairing pairing = FakePairing();

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

/// A host whose SDK never starts, so a mounted Connect control stays idle and
/// touches nothing.
class UnstartedWalletConnectHost implements WalletConnectHost {
  @override
  Future<bool> start() async => false;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

/// A host whose SDK is up and answers with [walletKit].
class StartedWalletConnectHost implements WalletConnectHost {
  StartedWalletConnectHost(this.walletKit);

  @override
  final ReownWalletKit walletKit;

  @override
  Future<bool> start() async => true;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

/// A [ReownWalletKit] that fires the events a test names and records every
/// call the wallet makes. `implements` plus `noSuchMethod`, because a real
/// instance builds the SDK.
class FakeWalletKit implements ReownWalletKit {
  final Event<SessionProposalEvent> proposal = Event();
  final Event<SessionRequestEvent> request = Event();
  final Event<SessionConnect> connect = Event();
  final Event<SessionDelete> delete = Event();
  final Event<SessionExpire> expire = Event();

  /// The sessions `getActiveSessions` reports, by topic.
  final Map<String, SessionData> activeSessions = {};

  final List<String> disconnects = [];
  final List<Uri> pairs = [];

  final List<({int id, Map<String, Namespace> namespaces})> approvals = [];
  final List<({int id, ReownSignError reason})> rejections = [];
  final List<({String topic, JsonRpcResponse response})> responses = [];
  final List<({String topic, String chainId, SessionEventParams event})> emits =
      [];
  final List<({String topic, Map<String, Namespace> namespaces})> updates = [];

  /// Calls that fail before they are recorded: the next N answers, emits,
  /// updates and approvals.
  int failResponds = 0;
  int failEmits = 0;
  int failApprovals = 0;
  final Set<String> failUpdateTopics = {};

  /// When set, `respondSessionRequest` waits for it before recording.
  Completer<void>? holdRespond;

  @override
  final FakeCore core = FakeCore();

  FakePairing get pairing => core.pairing as FakePairing;

  @override
  Event<SessionProposalEvent> get onSessionProposal => proposal;

  @override
  Event<SessionRequestEvent> get onSessionRequest => request;

  @override
  Event<SessionConnect> get onSessionConnect => connect;

  @override
  Event<SessionDelete> get onSessionDelete => delete;

  @override
  Event<SessionExpire> get onSessionExpire => expire;

  @override
  Map<String, SessionData> getActiveSessions() => Map.of(activeSessions);

  @override
  Future<void> disconnectSession({
    required String topic,
    required ReownSignError reason,
  }) async {
    disconnects.add(topic);
  }

  @override
  Future<PairingInfo> pair({
    required Uri uri,
    bool activatePairing = false,
  }) async {
    pairs.add(uri);
    return PairingInfo(
      topic: 'own123',
      expiry: 0,
      relay: Relay('irn'),
      active: false,
    );
  }

  @override
  Future<ApproveResponse> approveSession({
    required int id,
    required Map<String, Namespace> namespaces,
    Map<String, String>? sessionProperties,
    String? relayProtocol,
    ProposalRequestsResponses? proposalRequestsResponses,
  }) async {
    if (failApprovals > 0) {
      failApprovals--;
      throw StateError('relay disconnected');
    }
    approvals.add((id: id, namespaces: namespaces));
    return ApproveResponse(topic: 'approved-$id', session: null);
  }

  @override
  Future<void> rejectSession({
    required int id,
    required ReownSignError reason,
  }) async {
    rejections.add((id: id, reason: reason));
  }

  @override
  Future<void> respondSessionRequest({
    required String topic,
    required JsonRpcResponse response,
  }) async {
    await holdRespond?.future;
    if (failResponds > 0) {
      failResponds--;
      throw StateError('relay disconnected');
    }
    responses.add((topic: topic, response: response));
  }

  @override
  Future<void> emitSessionEvent({
    required String topic,
    required String chainId,
    required SessionEventParams event,
  }) async {
    if (failEmits > 0) {
      failEmits--;
      throw StateError('relay disconnected');
    }
    emits.add((topic: topic, chainId: chainId, event: event));
  }

  @override
  Future<void> updateSession({
    required String topic,
    required Map<String, Namespace> namespaces,
  }) async {
    if (failUpdateTopics.contains(topic)) {
      throw StateError('session gone');
    }
    updates.add((topic: topic, namespaces: namespaces));
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

const dashboardUrl = 'https://dash.example';

/// A proposal from [url] asking for [methods] and [events] on eip155 as
/// optional namespaces.
SessionProposalEvent proposalEvent({
  int id = 1,
  String url = dashboardUrl,
  List<String> methods = const ['gnus_getAccounts'],
  List<String> events = const ['gnus_accountsChanged'],
  Validation? validation = Validation.VALID,
  bool? isScam,
}) {
  final proposal = ProposalData(
    id: id,
    expiry: 0,
    relays: [Relay('irn')],
    proposer: ConnectionMetadata(
      publicKey: 'key',
      metadata: PairingMetadata(
        name: 'Dashboard',
        description: 'GNUS dashboard',
        url: url,
        icons: const [],
      ),
    ),
    requiredNamespaces: const {},
    optionalNamespaces: {
      'eip155': RequiredNamespace(
        chains: const ['eip155:80002'],
        methods: methods,
        events: events,
      ),
    },
    pairingTopic: 'pairing',
  );
  return SessionProposalEvent(
    id,
    proposal,
    validation == null
        ? null
        : VerifyContext(
            origin: url,
            validation: validation,
            verifyUrl: 'https://verify.walletconnect.org',
            isScam: isScam,
          ),
  );
}

/// An active session with [url] as its peer, approved for [methods] and
/// [events] on [chains].
SessionData sessionData({
  String topic = 'topic-1',
  String url = dashboardUrl,
  List<String> methods = const ['gnus_getAccounts'],
  List<String> events = const ['gnus_accountsChanged'],
  List<String> chains = const ['eip155:80002'],
  String address = '0xabcd567890123456789012345678901234567890',
}) => SessionData(
  topic: topic,
  pairingTopic: 'pairing',
  relay: Relay('irn'),
  expiry: 0,
  acknowledged: true,
  controller: 'key',
  namespaces: {
    'eip155': Namespace(
      chains: chains,
      accounts: [for (final chain in chains) '$chain:$address'],
      methods: methods,
      events: events,
    ),
  },
  self: const ConnectionMetadata(
    publicKey: 'self',
    metadata: PairingMetadata(
      name: 'Wallet',
      description: 'wallet',
      url: 'https://gnus.ai/',
    ),
  ),
  peer: ConnectionMetadata(
    publicKey: 'key',
    metadata: PairingMetadata(
      name: 'Dashboard',
      description: 'GNUS dashboard',
      url: url,
    ),
  ),
);

SessionRequestEvent gnusRequest(
  String method, {
  Object? params,
  int id = 1,
  String topic = 'topic-1',
}) => SessionRequestEvent(
  id,
  topic,
  method,
  'eip155:80002',
  params,
  TransportType.relay,
);
