import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart' show debugPrint;
import 'package:genius_wallet/hive/constants/cache.dart';
import 'package:hive_ce/hive.dart';

/// `.name` is the contract string. The contract's live states arrive with
/// SDK-STATUS; a stored value that matches none decodes to [unknown].
enum GnusJobStatus { submitted, bridgedNotProcessed, unknown }

/// One job submitted through the gnus handler. Holds no job body, params, key
/// or mnemonic: [bodyHash] is enough to tell a reused idempotency key apart.
class GnusJob {
  const GnusJob({
    required this.jobId,
    required this.burnTxHash,
    required this.sdkAddress,
    required this.origin,
    required this.idempotencyKey,
    required this.submittedAt,
    required this.cost,
    required this.status,
    required this.bodyHash,
  });

  final String? jobId;
  final String burnTxHash;
  final String sdkAddress;
  final String origin;
  final String idempotencyKey;
  final DateTime submittedAt;

  /// Base units of the GNUS decimals, as a decimal string.
  final String cost;
  final GnusJobStatus status;
  final String bodyHash;

  GnusJob withStatus(GnusJobStatus status) => GnusJob(
    jobId: jobId,
    burnTxHash: burnTxHash,
    sdkAddress: sdkAddress,
    origin: origin,
    idempotencyKey: idempotencyKey,
    submittedAt: submittedAt,
    cost: cost,
    status: status,
    bodyHash: bodyHash,
  );

  /// The contract `Job` shape.
  Map<String, Object?> toContract() => {
    'jobId': jobId,
    'burnTxHash': burnTxHash,
    'sdkAddress': sdkAddress,
    'origin': origin,
    'idempotencyKey': idempotencyKey,
    'submittedAt': submittedAt.toUtc().toIso8601String(),
    'cost': cost,
    'status': status.name,
  };

  String encode() =>
      jsonEncode({'v': 1, ...toContract(), 'bodyHash': bodyHash});

  /// Null on any malformed value; never throws.
  static GnusJob? decode(String raw) {
    try {
      final map = jsonDecode(raw);
      if (map is! Map) {
        return null;
      }
      final jobId = map['jobId'];
      final burnTxHash = map['burnTxHash'];
      final sdkAddress = map['sdkAddress'];
      final origin = map['origin'];
      final idempotencyKey = map['idempotencyKey'];
      final submittedAt = map['submittedAt'];
      final cost = map['cost'];
      final status = map['status'];
      final bodyHash = map['bodyHash'];
      if ((jobId != null && jobId is! String) ||
          burnTxHash is! String ||
          sdkAddress is! String ||
          origin is! String ||
          idempotencyKey is! String ||
          submittedAt is! String ||
          cost is! String ||
          status is! String ||
          bodyHash is! String) {
        return null;
      }
      final at = DateTime.tryParse(submittedAt);
      if (at == null) {
        return null;
      }
      return GnusJob(
        jobId: jobId as String?,
        burnTxHash: burnTxHash,
        sdkAddress: sdkAddress,
        origin: origin,
        idempotencyKey: idempotencyKey,
        submittedAt: at.toUtc(),
        cost: cost,
        status: GnusJobStatus.values.firstWhere(
          (s) => s.name == status,
          orElse: () => GnusJobStatus.unknown,
        ),
        bodyHash: bodyHash,
      );
    } catch (_) {
      return null;
    }
  }
}

/// A submit the wallet is about to burn for, written before the burn so a
/// restart can never forget the key. [burnTxHash] is set once the burn lands.
/// Like [GnusJob], it holds no job body, key or mnemonic.
class GnusSubmitIntent {
  const GnusSubmitIntent({
    required this.origin,
    required this.idempotencyKey,
    required this.bodyHash,
    required this.payer,
    required this.sdkAddress,
    required this.cost,
    required this.createdAt,
    this.burnTxHash,
  });

  final String origin;
  final String idempotencyKey;
  final String bodyHash;
  final String payer;
  final String sdkAddress;
  final String cost;
  final DateTime createdAt;
  final String? burnTxHash;

  GnusSubmitIntent withBurn(String burnTxHash) => GnusSubmitIntent(
    origin: origin,
    idempotencyKey: idempotencyKey,
    bodyHash: bodyHash,
    payer: payer,
    sdkAddress: sdkAddress,
    cost: cost,
    createdAt: createdAt,
    burnTxHash: burnTxHash,
  );

  /// The contract `Job` shape, status `pending`: the outcome is not recorded.
  Map<String, Object?> toContract() => {
    'jobId': null,
    'burnTxHash': burnTxHash,
    'sdkAddress': sdkAddress,
    'origin': origin,
    'idempotencyKey': idempotencyKey,
    'submittedAt': createdAt.toUtc().toIso8601String(),
    'cost': cost,
    'status': pendingStatus,
  };

  static const pendingStatus = 'pending';

  /// [toContract] for an intent whose record cannot be read.
  static Map<String, Object?> unreadableContract(String origin, String key) => {
    'jobId': null,
    'burnTxHash': null,
    'sdkAddress': null,
    'origin': origin,
    'idempotencyKey': key,
    'submittedAt': null,
    'cost': null,
    'status': pendingStatus,
  };

  String encode() => jsonEncode({
    'v': 1,
    'origin': origin,
    'idempotencyKey': idempotencyKey,
    'bodyHash': bodyHash,
    'payer': payer,
    'sdkAddress': sdkAddress,
    'cost': cost,
    'createdAt': createdAt.toUtc().toIso8601String(),
    'burnTxHash': burnTxHash,
    'status': pendingStatus,
  });

  /// Null on any malformed value; never throws.
  static GnusSubmitIntent? decode(String raw) {
    try {
      final map = jsonDecode(raw);
      if (map is! Map) {
        return null;
      }
      final origin = map['origin'];
      final idempotencyKey = map['idempotencyKey'];
      final bodyHash = map['bodyHash'];
      final payer = map['payer'];
      final sdkAddress = map['sdkAddress'];
      final cost = map['cost'];
      final createdAt = map['createdAt'];
      final burnTxHash = map['burnTxHash'];
      if (origin is! String ||
          idempotencyKey is! String ||
          bodyHash is! String ||
          payer is! String ||
          sdkAddress is! String ||
          cost is! String ||
          createdAt is! String ||
          (burnTxHash != null && burnTxHash is! String)) {
        return null;
      }
      final at = DateTime.tryParse(createdAt);
      if (at == null) {
        return null;
      }
      return GnusSubmitIntent(
        origin: origin,
        idempotencyKey: idempotencyKey,
        bodyHash: bodyHash,
        payer: payer,
        sdkAddress: sdkAddress,
        cost: cost,
        createdAt: at.toUtc(),
        burnTxHash: burnTxHash as String?,
      );
    } catch (_) {
      return null;
    }
  }
}

/// sha256 of the job encoded with its keys sorted at every depth, so the same
/// job hashes the same whatever order its keys arrived in.
String gnusJobBodyHash(Map<String, dynamic> job) =>
    sha256.convert(utf8.encode(jsonEncode(_canonical(job)))).toString();

Object? _canonical(Object? value) {
  if (value is Map) {
    final keys = value.keys.map((k) => '$k').toList()..sort();
    return {for (final k in keys) k: _canonical(value[k])};
  }
  if (value is List) {
    return [for (final e in value) _canonical(e)];
  }
  return value;
}

/// The wallet's own record of jobs submitted over gnus: one JSON string per
/// burn, keyed by the lowercased burn hash, plus one submit intent per origin
/// and idempotency key under [_intentPrefix]. Reads and writes records only.
class GnusJobStore {
  GnusJobStore(this._box);

  /// The app's box, opened by `initHive`. The only place outside `lib/hive/`
  /// that names it.
  factory GnusJobStore.app() => GnusJobStore(Hive.box<String>(gnusJobsBoxName));

  final Box<String> _box;

  static const _intentPrefix = 'intent:';

  Future<void> put(GnusJob job) =>
      _box.put(job.burnTxHash.toLowerCase(), job.encode());

  // Hashed: an origin plus a 128-character key can pass Hive's 255-byte key cap.
  static String _intentKey(String origin, String key) =>
      '$_intentPrefix${sha256.convert(utf8.encode('$origin|$key'))}';

  // ponytail: an intent stays after its job record is written, about 400 bytes
  // per submit, so the box grows by one entry per submit forever. Lookups skip
  // intents by key and never decode them. Upgrade: drop intents past the 24 h
  // idempotency window at startup.
  Future<void> putIntent(GnusSubmitIntent intent) => _box.put(
    _intentKey(intent.origin, intent.idempotencyKey),
    intent.encode(),
  );

  Future<void> deleteIntent(String origin, String key) =>
      _box.delete(_intentKey(origin, key));

  /// The intent [origin] wrote for [key], not older than [notBefore] when
  /// given. Throws [FormatException] for one it cannot read, so a damaged
  /// record can never pass for no record.
  GnusSubmitIntent? intentFor(
    String origin,
    String key, {
    DateTime? notBefore,
  }) {
    final raw = _box.get(_intentKey(origin, key));
    if (raw == null) {
      return null;
    }
    final intent = GnusSubmitIntent.decode(raw);
    if (intent == null) {
      throw const FormatException('unreadable submit intent');
    }
    if (notBefore != null && intent.createdAt.isBefore(notBefore)) {
      return null;
    }
    return intent;
  }

  GnusJob? byBurnHash(String burnTxHash) {
    final raw = _box.get(burnTxHash.toLowerCase());
    return raw == null ? null : GnusJob.decode(raw);
  }

  /// Exact match on a set `jobId`; every record has none until SDK-JOBID.
  GnusJob? byJobId(String jobId) {
    for (final job in _records()) {
      if (job.jobId != null && job.jobId == jobId) {
        return job;
      }
    }
    return null;
  }

  /// The newest record from [origin] carrying [key], not older than
  /// [notBefore] when given.
  GnusJob? byIdempotencyKey(String origin, String key, {DateTime? notBefore}) {
    GnusJob? newest;
    for (final job in _records()) {
      if (job.origin != origin || job.idempotencyKey != key) {
        continue;
      }
      if (notBefore != null && job.submittedAt.isBefore(notBefore)) {
        continue;
      }
      if (newest == null || job.submittedAt.isAfter(newest.submittedAt)) {
        newest = job;
      }
    }
    return newest;
  }

  /// [sdkAddress]'s jobs, newest first (then burn hash descending), strictly
  /// after [cursor]. [nextCursor] is set only when more remain. Throws
  /// [FormatException] for a cursor it cannot decode.
  ({List<GnusJob> jobs, String? nextCursor}) page({
    required String sdkAddress,
    required int limit,
    String? cursor,
  }) {
    final after = cursor == null ? null : _decodeCursor(cursor);
    final node = sdkAddress.toLowerCase();
    final all =
        _records().where((j) => j.sdkAddress.toLowerCase() == node).toList()
          ..sort(_newestFirst);
    final rest = after == null
        ? all
        : all.where((j) => _newestFirst(j, after) > 0).toList();
    final jobs = rest.take(limit).toList();
    return (
      jobs: jobs,
      nextCursor: rest.length > jobs.length ? _encodeCursor(jobs.last) : null,
    );
  }

  // ponytail: every lookup decodes the whole box. Fine to a few thousand jobs.
  // Upgrade: a secondary index key per origin and idempotency key pointing at
  // the burn hash.
  List<GnusJob> _records() {
    final jobs = <GnusJob>[];
    var skipped = 0;
    for (final key in _box.keys) {
      if (key is String && key.startsWith(_intentPrefix)) {
        continue;
      }
      final raw = _box.get(key);
      final job = raw == null ? null : GnusJob.decode(raw);
      if (job == null) {
        skipped++;
      } else {
        jobs.add(job);
      }
    }
    if (skipped > 0) {
      debugPrint('gnus_job_store skipped $skipped unreadable records');
    }
    return jobs;
  }
}

int _newestFirst(GnusJob a, GnusJob b) {
  final byTime = b.submittedAt.compareTo(a.submittedAt);
  if (byTime != 0) {
    return byTime;
  }
  return b.burnTxHash.toLowerCase().compareTo(a.burnTxHash.toLowerCase());
}

String _encodeCursor(GnusJob last) => base64Url.encode(
  utf8.encode(
    '${last.submittedAt.microsecondsSinceEpoch}|'
    '${last.burnTxHash.toLowerCase()}',
  ),
);

// DateTime's own range, in microseconds; beyond it the constructor throws.
const int _maxCursorMicros = 8640000000000000000;

/// A position, as a stand-in record that sorts where the cursor points.
GnusJob _decodeCursor(String cursor) {
  final String text;
  try {
    text = utf8.decode(base64Url.decode(cursor));
  } on FormatException {
    throw const FormatException('bad cursor');
  }
  final bar = text.indexOf('|');
  final micros = bar < 0 ? null : int.tryParse(text.substring(0, bar));
  // Not micros.abs(): the smallest int is its own negation.
  if (micros == null ||
      micros < -_maxCursorMicros ||
      micros > _maxCursorMicros) {
    throw const FormatException('bad cursor');
  }
  return GnusJob(
    jobId: null,
    burnTxHash: text.substring(bar + 1),
    sdkAddress: '',
    origin: '',
    idempotencyKey: '',
    submittedAt: DateTime.fromMicrosecondsSinceEpoch(micros, isUtc: true),
    cost: '',
    status: GnusJobStatus.unknown,
    bodyHash: '',
  );
}
