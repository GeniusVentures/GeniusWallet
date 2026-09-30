import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:genius_wallet/banxa/checkout_qr.dart';
import 'package:genius_wallet/components/toast/toast_manager.dart';
import 'package:genius_wallet/theme/gw_colors.dart';
import 'package:qr_flutter/qr_flutter.dart';

import 'gw_pump.dart';

const _url = 'https://gnus.banxa-sandbox.com/checkout/abc123def456';

void main() {
  late List<MethodCall> platformCalls;

  setUp(() {
    platformCalls = [];
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, (call) async {
          platformCalls.add(call);
          return null;
        });
  });

  tearDown(() {
    ToastManager.instance.disposeAll();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, null);
  });

  Widget body({GWColors? gw}) =>
      gwHost(const CheckoutQrBody(checkoutUrl: _url), gw: gw);

  testWidgets('shows the instruction, the QR and the whole link', (
    tester,
  ) async {
    await tester.pumpWidget(body());

    expect(find.textContaining('Scan with your phone'), findsOneWidget);
    expect(
      find.textContaining('updates when Banxa has your payment'),
      findsOne,
    );
    expect(find.byType(QrImageView), findsOneWidget);
    expect(find.text(_url), findsOneWidget);
    expect(find.text('Copy link'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Copy link puts the exact URL on the clipboard', (tester) async {
    await tester.pumpWidget(body());

    await tester.tap(find.text('Copy link'));
    await tester.pump();

    final copy = platformCalls.firstWhere(
      (c) => c.method == 'Clipboard.setData',
    );
    expect((copy.arguments as Map)['text'], _url);
    expect(find.text('Link copied'), findsOneWidget);
  });

  testWidgets('the QR backing stays white in both appearances', (tester) async {
    final backings = <Color?>[];
    for (final gw in gwBothModes) {
      await tester.pumpWidget(body(gw: gw));
      await tester.pumpAndSettle();
      backings.add(
        tester
            .widget<Container>(
              find
                  .ancestor(
                    of: find.byType(QrImageView),
                    matching: find.byType(Container),
                  )
                  .first,
            )
            .color,
      );
    }

    expect(backings, [Colors.white, Colors.white]);
  });
}
