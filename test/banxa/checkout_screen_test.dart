import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:genius_wallet/banxa/banxa_order/banxa_order_cubit.dart';
import 'package:genius_wallet/banxa/checkout/checkout_screen.dart';
import 'package:genius_wallet/banxa/checkout_qr.dart';
import 'package:genius_wallet/theme/gw_colors.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher_platform_interface/link.dart';
import 'package:url_launcher_platform_interface/url_launcher_platform_interface.dart';

import 'fake_banxa_api.dart';
import 'fixtures.dart';

const _id = 'ord_0001';
const _url = 'https://gnus.banxa-sandbox.com/checkout/abc';

String? _launched;

class _RecordingLauncher extends UrlLauncherPlatform {
  @override
  final LinkDelegate? linkDelegate = null;

  @override
  Future<bool> canLaunch(String url) async => true;

  @override
  Future<bool> launch(
    String url, {
    required bool useSafariVC,
    required bool useWebView,
    required bool enableJavaScript,
    required bool enableDomStorage,
    required bool universalLinksOnly,
    required Map<String, String> headers,
    String? webOnlyWindowName,
  }) async {
    _launched = url;
    return true;
  }
}

/// Counts how many times the host is created, not how often it is rebuilt.
class _FakeHost extends StatefulWidget {
  const _FakeHost({
    required this.uri,
    required this.created,
    required this.onReturn,
    required this.onLoadError,
  });

  final Uri uri;
  final List<Uri> created;
  final VoidCallback onReturn;
  final VoidCallback onLoadError;

  @override
  State<_FakeHost> createState() => _FakeHostState();
}

class _FakeHostState extends State<_FakeHost> {
  @override
  void initState() {
    super.initState();
    widget.created.add(widget.uri);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Text('fake host'),
        ElevatedButton(
          onPressed: widget.onReturn,
          child: const Text('simulate return'),
        ),
        ElevatedButton(
          onPressed: widget.onLoadError,
          child: const Text('simulate error'),
        ),
      ],
    );
  }
}

void main() {
  late FakeBanxaApi api;
  final cubits = <OrdersCubit>[];
  late List<Uri> built;
  late List<MethodCall> platformCalls;

  setUp(() {
    _launched = null;
    UrlLauncherPlatform.instance = _RecordingLauncher();
    built = [];
    platformCalls = [];
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, (call) async {
          platformCalls.add(call);
          return null;
        });
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, null);
  });

  Future<void> pumpScreen(
    WidgetTester tester, {
    String status = 'pendingPayment',
    String url = _url,
    bool sandbox = false,
    GWColors? gw,
  }) async {
    api = FakeBanxaApi(
      orders: [
        testOrder(
          id: _id,
          status: status,
          cryptoId: 'GNUS',
          cryptoAmount: '100',
          fiatAmount: '25.00',
        ),
      ],
    );
    final cubit = OrdersCubit(api: api);
    cubits.add(cubit);

    final router = GoRouter(
      initialLocation: '/checkout',
      routes: [
        GoRoute(
          path: '/buy',
          builder: (context, state) => const Scaffold(body: Text('buy stub')),
        ),
        GoRoute(
          path: '/checkout',
          builder: (context, state) => CheckoutScreen(
            orderId: _id,
            checkoutUrl: url,
            isSandbox: sandbox,
            hostBuilder: (context, uri, onReturn, onLoadError) {
              return _FakeHost(
                uri: uri,
                created: built,
                onReturn: onReturn,
                onLoadError: onLoadError,
              );
            },
          ),
        ),
      ],
    );
    await tester.pumpWidget(
      BlocProvider<OrdersCubit>.value(
        value: cubit,
        child: MaterialApp.router(
          theme: ThemeData(extensions: [gw ?? GWColors.dark()]),
          routerConfig: router,
        ),
      ),
    );
    await tester.pump();
    await tester.pump();
  }

  // The poll timer must be cancelled inside the test body; the framework
  // checks for pending timers before tearDown callbacks run.
  void screenTest(String name, Future<void> Function(WidgetTester) body) {
    testWidgets(name, (tester) async {
      try {
        await body(tester);
      } finally {
        for (final cubit in cubits) {
          unawaited(cubit.close());
        }
        cubits.clear();
        await tester.pumpWidget(const SizedBox());
      }
    });
  }

  CheckoutProgress progress(WidgetTester tester) =>
      tester.widget<CheckoutProgress>(find.byType(CheckoutProgress));

  screenTest('an unpaid order shows the host with Pay active', (tester) async {
    await pumpScreen(tester);

    expect(find.text('fake host'), findsOneWidget);
    expect(built.single, Uri.parse(_url));
    expect(progress(tester).pay, CheckoutStepState.active);
    expect(progress(tester).done, isFalse);
    expect(find.text('Secured by Banxa'), findsOneWidget);
    expect(find.textContaining('Sandbox'), findsNothing);
  });

  screenTest('the polled status alone ends checkout, with no return', (
    tester,
  ) async {
    await pumpScreen(tester);
    api.statuses[_id] = ['paymentReceived'];

    await tester.pump(const Duration(seconds: 15));
    await tester.pump();

    expect(find.text('fake host'), findsNothing);
    expect(find.text('+ ≈100 GNUS'), findsOneWidget);
    expect(find.text('25.00 USD'), findsOneWidget);
    expect(find.text('Back to Buy'), findsOneWidget);
    expect(find.text('View order'), findsOneWidget);
    expect(progress(tester).pay, CheckoutStepState.done);
    expect(progress(tester).done, isTrue);
  });

  screenTest('a completed order drops the approximate sign', (tester) async {
    await pumpScreen(tester, status: 'complete');

    expect(find.text('+ 100 GNUS'), findsOneWidget);
  });

  screenTest('a return asks for one immediate read, then shows the result', (
    tester,
  ) async {
    await pumpScreen(tester);
    final before = api.getOrderByIdCalls;
    api.holdOrderById = Completer<void>();
    api.statuses[_id] = ['paymentReceived'];

    await tester.tap(find.text('simulate return'));
    await tester.pump();

    expect(find.text('Checking your order'), findsOneWidget);
    expect(
      find.text('Banxa sent you back. Asking for the latest status.'),
      findsOneWidget,
    );
    expect(api.getOrderByIdCalls, before + 1);

    api.holdOrderById!.complete();
    await tester.pump();
    await tester.pump();

    expect(find.text('Checking your order'), findsNothing);
    expect(find.text('+ ≈100 GNUS'), findsOneWidget);
    expect(api.getOrderByIdCalls, before + 1);
  });

  screenTest('a return with the order still unpaid offers Complete payment', (
    tester,
  ) async {
    await pumpScreen(tester);

    await tester.tap(find.text('simulate return'));
    await tester.pump();
    await tester.pump();

    expect(find.text('Complete payment'), findsOneWidget);
    expect(built, hasLength(1));

    await tester.tap(find.text('Complete payment'));
    await tester.pump();

    expect(find.text('fake host'), findsOneWidget);
    expect(built, hasLength(2));
  });

  screenTest('a return while the bank confirms offers no second payment', (
    tester,
  ) async {
    await pumpScreen(tester, status: 'waitingPayment');

    await tester.tap(find.text('simulate return'));
    await tester.pump();
    await tester.pump();

    expect(
      find.text(
        'Banxa is waiting for your bank or card to confirm the payment.',
      ),
      findsOneWidget,
    );
    expect(find.text('Complete payment'), findsNothing);
    expect(find.text('Back to Buy'), findsOneWidget);
  });

  screenTest('a declined order reads Not charged and can be copied', (
    tester,
  ) async {
    await pumpScreen(tester, status: 'declined');

    expect(find.text('Not charged'), findsOneWidget);
    expect(find.textContaining('100 GNUS'), findsNothing);
    expect(find.text('Try again'), findsOneWidget);
    expect(find.text('Contact Banxa support'), findsOneWidget);
    expect(progress(tester).pay, CheckoutStepState.failed);
    expect(progress(tester).done, isFalse);

    await tester.tap(find.text(_id));
    await tester.pump();
    final copy = platformCalls.firstWhere(
      (c) => c.method == 'Clipboard.setData',
    );
    expect((copy.arguments as Map)['text'], _id);

    await tester.tap(find.text('Try again'));
    await tester.pumpAndSettle();
    expect(find.text('buy stub'), findsOneWidget);
  });

  screenTest('a link that is not Banxa never builds a host', (tester) async {
    await pumpScreen(tester, url: 'https://banxa.com.evil.io/pay');

    expect(built, isEmpty);
    expect(find.text("This checkout link isn't from Banxa"), findsOneWidget);

    await tester.tap(find.text('Close'));
    await tester.pumpAndSettle();
    expect(find.text('buy stub'), findsOneWidget);
  });

  screenTest('a load error says so and Try again builds the host again', (
    tester,
  ) async {
    await pumpScreen(tester);

    await tester.tap(find.text('simulate error'));
    await tester.pump();

    expect(find.text("Checkout didn't load"), findsOneWidget);
    expect(
      find.text('Your order is created. Check your connection and try again.'),
      findsOneWidget,
    );
    expect(built, hasLength(1));

    await tester.tap(find.text('Try again'));
    await tester.pump();

    expect(find.text('fake host'), findsOneWidget);
    expect(built, hasLength(2));
  });

  screenTest('a sandbox build shows the sandbox pill', (tester) async {
    await pumpScreen(tester, sandbox: true);

    expect(find.text('Sandbox · no real money'), findsOneWidget);
  });

  screenTest('the result reads in both appearances', (tester) async {
    for (final gw in [GWColors.dark(), GWColors.light()]) {
      await pumpScreen(tester, status: 'declined', gw: gw);
      expect(find.text('Not charged'), findsOneWidget);
      expect(tester.takeException(), isNull);
    }
  });

  screenTest('the menu offers both, and Pay on another device shows the QR', (
    tester,
  ) async {
    await pumpScreen(tester);

    await tester.tap(find.byTooltip('More'));
    await tester.pump();

    expect(find.text('Pay on another device'), findsOneWidget);
    expect(find.text('Scan a code or copy the link'), findsOneWidget);
    expect(find.text('Open in browser'), findsOneWidget);
    expect(find.text('For Apple Pay or iDEAL'), findsOneWidget);

    await tester.tap(find.text('Pay on another device'));
    await tester.pumpAndSettle();

    expect(find.byType(CheckoutQrBody), findsOneWidget);
    expect(
      tester.widget<CheckoutQrBody>(find.byType(CheckoutQrBody)).checkoutUrl,
      _url,
    );
  });

  screenTest('Open in browser launches the checkout link', (tester) async {
    await pumpScreen(tester);

    await tester.tap(find.byTooltip('More'));
    await tester.pump();
    await tester.tap(find.text('Open in browser'));
    await tester.pump();

    expect(_launched, _url);
  });

  screenTest('a load error offers both ways out as well as Try again', (
    tester,
  ) async {
    await pumpScreen(tester);

    await tester.tap(find.text('simulate error'));
    await tester.pump();

    expect(find.text('Try again'), findsOneWidget);
    await tester.tap(find.text('Open in browser'));
    await tester.pump();
    expect(_launched, _url);

    await tester.tap(find.text('Pay on another device'));
    await tester.pumpAndSettle();
    expect(find.byType(CheckoutQrBody), findsOneWidget);
  });

  screenTest('a link that is not Banxa has no menu to hand it elsewhere', (
    tester,
  ) async {
    await pumpScreen(tester, url: 'https://banxa.com.evil.io/pay');

    expect(find.byTooltip('More'), findsNothing);
  });

  screenTest('closing while paying asks first; Keep paying stays', (
    tester,
  ) async {
    await pumpScreen(tester);

    await tester.tap(find.byTooltip('Close'));
    await tester.pumpAndSettle();

    expect(find.text('Leave checkout?'), findsOneWidget);
    expect(
      find.text(
        'Your order stays open for a while. You can finish it from Buy '
        'orders in Transactions.',
      ),
      findsOneWidget,
    );

    await tester.tap(find.text('Keep paying'));
    await tester.pumpAndSettle();

    expect(find.text('Leave checkout?'), findsNothing);
    expect(find.text('fake host'), findsOneWidget);
    expect(find.text('buy stub'), findsNothing);
  });

  screenTest('Leave closes checkout', (tester) async {
    await pumpScreen(tester);

    await tester.tap(find.byTooltip('Close'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Leave'));
    await tester.pumpAndSettle();

    expect(find.text('buy stub'), findsOneWidget);
  });

  screenTest('the back gesture while paying asks instead of leaving', (
    tester,
  ) async {
    await pumpScreen(tester);

    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();

    expect(find.text('Leave checkout?'), findsOneWidget);
    expect(find.text('fake host'), findsOneWidget);
  });

  screenTest('once the result shows, closing does not ask', (tester) async {
    await pumpScreen(tester);
    api.statuses[_id] = ['paymentReceived'];
    await tester.pump(const Duration(seconds: 15));
    await tester.pump();
    expect(find.text('View order'), findsOneWidget);

    await tester.tap(find.byTooltip('Close'));
    await tester.pumpAndSettle();

    expect(find.text('Leave checkout?'), findsNothing);
    expect(find.text('buy stub'), findsOneWidget);
  });
}
