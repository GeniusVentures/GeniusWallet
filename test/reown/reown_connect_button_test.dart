import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:genius_wallet/components/loading/gw_spinner.dart';
import 'package:genius_wallet/reown/reown_connect_button.dart';
import 'package:genius_wallet/reown/wallet_connect_host.dart';
import 'package:genius_wallet/theme/gw_appearance.dart';
import 'package:genius_wallet/theme/gw_colors.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../theme/theme_contrast_test.dart' show contrastRatio, themeFor;
import 'fake_wallet_kit.dart';

Future<FakeWalletKit> _pump(
  WidgetTester tester, {
  required double width,
  bool connected = false,
  GWAppearanceMode mode = GWAppearanceMode.dark,
}) async {
  tester.view.physicalSize = Size(width, 844);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  final kit = FakeWalletKit();
  if (connected) {
    kit.activeSessions['topic-1'] = sessionData();
  }
  await tester.pumpWidget(
    RepositoryProvider<WalletConnectHost>.value(
      value: StartedWalletConnectHost(kit),
      child: MaterialApp(
        theme: themeFor(mode),
        home: const Scaffold(body: Center(child: ReownConnectButton())),
      ),
    ),
  );
  await tester.pumpAndSettle();
  return kit;
}

/// Lets the 15 s connect timeout the button schedules after the sheet closes
/// run out, so no timer outlives the test.
Future<void> _drainTimeout(WidgetTester tester) =>
    tester.pump(const Duration(seconds: 16));

const _phone = 390.0;
const _desktop = 1400.0;

void main() {
  for (final mode in GWAppearanceMode.values) {
    group('ReownConnectButton on a phone -- $mode', () {
      testWidgets('connected reads as connected, in a success colour that '
          'passes AA', (tester) async {
        await _pump(tester, width: _phone, connected: true, mode: mode);

        expect(find.byIcon(Icons.link_off), findsNothing);
        expect(find.byTooltip('Connected to Dashboard'), findsOneWidget);

        final button = tester.widget<IconButton>(find.byType(IconButton));
        final gw = Theme.of(
          tester.element(find.byType(ReownConnectButton)),
        ).extension<GWColors>()!;
        expect(find.byIcon(Icons.link), findsOneWidget);
        expect(button.color, gw.statusSuccessText);
        expect(
          contrastRatio(gw.statusSuccessText, gw.surfaceElevated),
          greaterThanOrEqualTo(4.5),
        );
      });

      testWidgets('tapping it asks first; Cancel keeps the session', (
        tester,
      ) async {
        final kit = await _pump(
          tester,
          width: _phone,
          connected: true,
          mode: mode,
        );

        await tester.tap(find.byTooltip('Connected to Dashboard'));
        await tester.pumpAndSettle();
        expect(find.text('Disconnect Dashboard?'), findsOneWidget);
        expect(kit.disconnects, isEmpty);

        await tester.tap(find.text('Cancel'));
        await tester.pumpAndSettle();

        expect(find.text('Disconnect Dashboard?'), findsNothing);
        expect(kit.disconnects, isEmpty);
        expect(find.byTooltip('Connected to Dashboard'), findsOneWidget);
      });

      testWidgets('Disconnect in the confirm ends the session', (tester) async {
        final kit = await _pump(
          tester,
          width: _phone,
          connected: true,
          mode: mode,
        );

        await tester.tap(find.byTooltip('Connected to Dashboard'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Disconnect'));
        await tester.pumpAndSettle();

        expect(kit.disconnects, ['topic-1']);
        expect(find.byTooltip('Connect'), findsOneWidget);
      });
    });
  }

  testWidgets('desktop keeps its Disconnect button and acts at once', (
    tester,
  ) async {
    final kit = await _pump(tester, width: _desktop, connected: true);

    await tester.tap(find.text('Disconnect'));
    await tester.pumpAndSettle();

    expect(kit.disconnects, ['topic-1']);
    expect(find.text('Disconnect Dashboard?'), findsNothing);
  });

  group('the pairing sheet', () {
    testWidgets('opens without waiting for the pairing to be created', (
      tester,
    ) async {
      final kit = await _pump(tester, width: _phone);
      kit.pairing.hold = Completer<void>();

      await tester.tap(find.byTooltip('Connect'));
      await tester.pumpAndSettle();

      expect(find.text('WalletConnect'), findsOneWidget);
      expect(find.byType(TextField), findsOneWidget);
      expect(kit.pairing.creates, 1);

      await tester.tap(find.text('Show QR Code'));
      await tester.pump(const Duration(milliseconds: 400));
      expect(find.byType(GWSpinner), findsOneWidget);
      expect(find.byType(QrImageView), findsNothing);

      kit.pairing.hold!.complete();
      await tester.pumpAndSettle();
      expect(find.byType(QrImageView), findsOneWidget);
      expect(find.byType(GWSpinner), findsNothing);
    });

    testWidgets('closing it pairs with the created link once', (tester) async {
      final kit = await _pump(tester, width: _phone);

      await tester.tap(find.byTooltip('Connect'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      await _drainTimeout(tester);
      expect(kit.pairs, [Uri.parse(FakePairing.uri)]);
    });

    testWidgets('a failed create leaves paste working and pairs nothing', (
      tester,
    ) async {
      final kit = await _pump(tester, width: _phone);
      kit.pairing.fail = true;

      await tester.tap(find.byTooltip('Connect'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Show QR Code'));
      await tester.pumpAndSettle();
      expect(find.textContaining("Couldn't create a QR code"), findsOneWidget);

      await tester.tap(find.text('Enter URI Manually'));
      await tester.pumpAndSettle();
      expect(find.byType(TextField), findsOneWidget);

      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();
      await _drainTimeout(tester);
      expect(kit.pairs, isEmpty);
    });

    testWidgets('a pasted link pairs once and skips the created link', (
      tester,
    ) async {
      final kit = await _pump(tester, width: _phone);
      const pasted = 'wc:abc123@2?relay-protocol=irn&symKey=deadbeef';

      await tester.tap(find.byTooltip('Connect'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), pasted);
      await tester.tap(find.text('Connect'));
      await tester.pumpAndSettle();

      await _drainTimeout(tester);
      expect(kit.pairs, [Uri.parse(pasted)]);
    });
  });
}
