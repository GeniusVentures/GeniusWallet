import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:genius_wallet/dashboard/bridge/bridge_gate.dart';
import 'package:genius_wallet/gnus_bridge/gnus_rpc_contract.dart';

import 'gnus_fakes.dart';

const _origin = 'https://dash.example';

String _withoutComments(String source) => source
    .split('\n')
    .where((line) => !line.trimLeft().startsWith('//'))
    .join('\n');

/// The text between the `(` that follows [marker] and its matching `)`, or
/// null when [marker] is absent or never closes.
String? _argumentList(String source, String marker) {
  final start = source.indexOf(marker);
  if (start < 0) {
    return null;
  }
  var depth = 0;
  for (var i = start + marker.length - 1; i < source.length; i++) {
    final char = source[i];
    if (char == '(') {
      depth++;
    } else if (char == ')') {
      depth--;
      if (depth == 0) {
        return source.substring(start + marker.length, i);
      }
    }
  }
  return null;
}

List<File> _bridgeFiles() => [
  for (final entity in Directory('lib/gnus_bridge').listSync(recursive: true))
    if (entity is File && entity.path.endsWith('.dart')) entity,
];

void main() {
  group('wiring', () {
    test('the argument matcher finds a nested call and its end', () {
      expect(
        _argumentList('x = Foo(a: bar(1), b: 2); y(', 'Foo('),
        'a: bar(1), b: 2',
      );
      expect(_argumentList('nothing here', 'Foo('), isNull);
      expect(_argumentList('Foo(a: (', 'Foo('), isNull);
    });

    test('the app wires both prompts and the real stores', () {
      final source = _withoutComments(File('lib/main.dart').readAsStringSync());

      final arguments = _argumentList(source, 'GnusRpcHandler(');

      expect(arguments, isNotNull);
      expect(arguments, contains('confirm: showGnusSpendConfirm'));
      expect(arguments, contains('GnusJobStore.app()'));
      expect(arguments, contains('connect: showGnusConnectPrompt'));
      expect(arguments, contains('connections:'));
    });

    test('startup opens the gnusJobs box as a string box', () {
      final source = _withoutComments(
        File('lib/hive/init.dart').readAsStringSync(),
      );

      expect(source, contains('Hive.openBox<String>(gnusJobsBoxName)'));
      expect(source, contains('Hive.openBox<String>(gnusConnectionsBoxName)'));
    });
  });

  group('boundary', () {
    final ownerCall = RegExp(
      r'\b(bridgeOut|getBrigeOutGasCost|requestGeniusSDKCostAsync|requestGeniusSDKProcessAsync|requestGeniusSDKProcessAsAccount)\(',
    );

    test('the matcher sees a direct owner call', () {
      expect(ownerCall.hasMatch('api.bridgeOut('), isTrue);
      expect(ownerCall.hasMatch('api.requestGeniusSDKProcessAsync('), isTrue);
      expect(
        ownerCall.hasMatch('api.requestGeniusSDKProcessAsAccount('),
        isTrue,
      );
      expect(ownerCall.hasMatch('_jobs.submit('), isFalse);
    });

    test('only the owner burns, prices gas and calls the SDK', () {
      final offenders = [
        for (final file in _bridgeFiles())
          if (ownerCall.hasMatch(_withoutComments(file.readAsStringSync())))
            file.path,
      ];

      expect(offenders, isEmpty);
    });

    test('only the store names Hive', () {
      final offenders = [
        for (final file in _bridgeFiles())
          if (!file.path.endsWith('_store.dart') &&
              RegExp(
                r'\bHive\b',
              ).hasMatch(_withoutComments(file.readAsStringSync())))
            file.path,
      ];

      expect(offenders, isEmpty);
    });

    test('nothing under lib/gnus_bridge is UI', () {
      final offenders = [
        for (final file in _bridgeFiles())
          if (RegExp(
            r"package:flutter/(material|widgets)\.dart",
          ).hasMatch(_withoutComments(file.readAsStringSync())))
            file.path,
      ];

      expect(offenders, isEmpty);
    });
  });

  group('logging', () {
    late DebugPrintCallback original;
    late List<String> lines;

    setUp(() {
      original = debugPrint;
      lines = [];
      debugPrint = (String? message, {int? wrapWidth}) {
        lines.add(message ?? '');
      };
    });

    tearDown(() {
      debugPrint = original;
    });

    test(
      'a log line says only the method, the origin and the outcome',
      () async {
        final burning = await GnusHarness.create();
        final refused = await GnusHarness.create();
        refused.gate = const BridgeGate(BridgeGateState.viewOnly);
        addTearDown(burning.dispose);
        addTearDown(refused.dispose);
        final burn = burning.build();
        final refuse = refused.build();

        for (final method in GnusRpcMethod.all) {
          await viaJson(burn, _origin, method, null);
        }
        await viaJson(burn, _origin, GnusRpcMethod.submitJob, {
          'job': {'inputs': 'SENTINEL-JOB'},
          'idempotencyKey': 'SENTINEL-KEY',
        });
        await viaJson(burn, _origin, GnusRpcMethod.estimate, {
          'job': {'inputs': 'SENTINEL-JOB'},
        });
        await viaJson(burn, _origin, GnusRpcMethod.listJobs, {
          'cursor': 'SENTINEL-CURSOR',
        });
        await viaJson(burn, _origin, GnusRpcMethod.getJob, {
          'idempotencyKey': 'SENTINEL-KEY',
        });
        await viaJson(refuse, _origin, GnusRpcMethod.submitJob, {
          'job': {'inputs': 'SENTINEL-JOB'},
          'idempotencyKey': 'SENTINEL-KEY-2',
        });
        await viaJson(burn, _origin, 'gnus_SENTINELMETHOD', null);
        expect(burning.api.count('burn'), 1);

        final gnus = lines
            .where((line) => line.startsWith('gnus_rpc '))
            .toList();
        expect(gnus.length, greaterThanOrEqualTo(12));
        final shape = RegExp(
          r'^gnus_rpc (gnus_[A-Za-z]+|unsupported) \S+ (ok|-?\d+)$',
        );
        for (final line in gnus) {
          expect(line, matches(shape));
        }
        for (final line in lines) {
          expect(line, isNot(contains('SENTINEL')));
          expect(line, isNot(contains(gnusTestBurnHash)));
        }
        expect(gnus, contains('gnus_rpc unsupported $_origin 4200'));
      },
    );
  });
}
