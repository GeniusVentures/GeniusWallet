import 'dart:convert';

import 'package:crypto/crypto.dart';
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
/// burn, keyed by the lowercased burn hash.
class GnusJobStore {
  GnusJobStore(this._box);

  final Box<String> _box;

  Future<void> put(GnusJob job) =>
      _box.put(job.burnTxHash.toLowerCase(), job.encode());

  GnusJob? byBurnHash(String burnTxHash) {
    final raw = _box.get(burnTxHash.toLowerCase());
    return raw == null ? null : GnusJob.decode(raw);
  }
}
