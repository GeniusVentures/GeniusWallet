import 'dart:async';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show FontLoader, rootBundle;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:genius_api/ffi/trust_wallet_api_ffi.dart';
import 'package:genius_api/genius_api.dart';
import 'package:genius_api/models/coin.dart';
import 'package:genius_api/models/network.dart';
import 'package:genius_api/types/wallet_type.dart';
import 'package:genius_wallet/bloc/app_bloc.dart';
import 'package:genius_wallet/components/buttons/gw_button.dart';
import 'package:genius_wallet/dashboard/bridge/bridge_entry.dart';
import 'package:genius_wallet/dashboard/bridge/bridge_gate.dart';
import 'package:genius_wallet/dashboard/bridge/bridge_gate_cubit.dart';
import 'package:genius_wallet/providers/network_tokens_provider.dart';
import 'package:genius_wallet/theme/genius_wallet_typography.dart';
import 'package:genius_wallet/theme/gw_appearance.dart';
import 'package:genius_wallet/theme/gw_colors.dart';
import 'package:genius_wallet/tokens/token_info_args.dart';
import 'package:genius_wallet/tokens/token_info_screen.dart';
import 'package:genius_wallet/wallets/cubit/wallet_details_cubit.dart';
import 'package:go_router/go_router.dart';

import '../../theme/theme_contrast_test.dart' show contrastRatio, themeFor;

class _UnusedApi implements GeniusApi {
  @override
  dynamic noSuchMethod(Invocation i) => super.noSuchMethod(i);
}

const _amoy = Network(
  name: 'Polygon Amoy',
  symbol: 'matic',
  chainId: 80002,
  rpcUrl: 'https://rpc.invalid',
);

const _walletAddress = '0xAbCd567890123456789012345678901234567890';
const _otherAddress = '0x1111111111111111111111111111111111111111';
final _sdkAccount = '0x${'a' * 128}';

const _wallet = Wallet(
  coinType: TWCoinType.TWCoinTypeEthereum,
  walletName: 'Test Wallet',
  currencySymbol: 'MATIC',
  walletType: WalletType.mnemonic,
  balance: 0,
  address: _walletAddress,
);

const _gnus = Coin(symbol: 'GNUS', address: '0xabc', balance: 10);

// What the wallet had selected before the tap: a GNUS entry that is not the
// contract coin, so the test can see the tap replace it.
const _staleSelection = Coin(symbol: 'GNUS', balance: 0);

AppState _appState({String linkedWallet = _walletAddress, String? switching}) =>
    AppState(
      selectedSDKAccount: _sdkAccount,
      switchingSDKAccount: switching,
      sdkAccountLinks: {
        _sdkAccount.toLowerCase(): (
          walletAddress: linkedWallet.toLowerCase(),
          walletName: 'Linked',
        ),
      },
    );

class _Host {
  _Host(this.app) {
    wallet = WalletDetailsCubit(
      initialState: const WalletDetailsState(
        selectedWallet: _wallet,
        selectedNetwork: _amoy,
        selectedCoin: _staleSelection,
        coins: [_gnus],
        coinsNetwork: _amoy,
        coinsStatus: WalletStatus.successful,
      ),
      geniusApi: _UnusedApi(),
      networkTokensProvider: NetworkTokensProvider(),
    );
    gate = BridgeGateCubit(
      readAppState: () => app,
      appStates: appStream.stream,
      walletDetails: wallet,
    );
  }

  AppState app;
  final appStream = StreamController<AppState>.broadcast();
  late final WalletDetailsCubit wallet;
  late final BridgeGateCubit gate;
  final bridgePushes = <String>[];

  Future<void> dispose() async {
    await gate.close();
    await wallet.close();
    await appStream.close();
  }

  Widget build({GWColors? colors}) {
    final router = GoRouter(
      routes: [
        GoRoute(
          path: '/',
          builder: (_, _) => TokenInfoScreen(
            walletDetailsCubit: wallet,
            args: const TokenInfoArgs(),
          ),
        ),
        GoRoute(
          path: '/bridge',
          builder: (_, state) {
            bridgePushes.add(state.uri.path);
            return const Scaffold(body: Text('bridge placeholder'));
          },
        ),
      ],
    );
    return MultiBlocProvider(
      providers: [BlocProvider<BridgeGateCubit>.value(value: gate)],
      child: MaterialApp.router(
        theme: ThemeData(extensions: [colors ?? GWColors.dark()]),
        routerConfig: router,
      ),
    );
  }
}

void _size(WidgetTester tester) {
  tester.view.physicalSize = const Size(2000, 1800);
  tester.view.devicePixelRatio = 2.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
}

void main() {
  testWidgets('the earning wallet opens the bridge on the GNUS coin', (
    tester,
  ) async {
    _size(tester);
    final host = _Host(_appState());
    addTearDown(host.dispose);

    await tester.pumpWidget(host.build());
    await tester.pump();

    expect(find.text('Only the earning wallet can bridge.'), findsNothing);
    await tester.tap(find.text('Bridge'));
    await tester.pumpAndSettle();

    expect(host.bridgePushes, ['/bridge']);
    expect(host.wallet.state.selectedCoin, _gnus);
  });

  testWidgets('another account earning disables Bridge and says why', (
    tester,
  ) async {
    _size(tester);
    final host = _Host(_appState(linkedWallet: _otherAddress));
    addTearDown(host.dispose);

    await tester.pumpWidget(host.build());
    await tester.pump();

    expect(find.text('Only the earning wallet can bridge.'), findsOneWidget);
    await tester.tap(find.text('Bridge'), warnIfMissed: false);
    await tester.pumpAndSettle();

    expect(host.bridgePushes, isEmpty);
  });

  testWidgets('a switch that began after the last frame stops the tap', (
    tester,
  ) async {
    _size(tester);
    final host = _Host(_appState());
    addTearDown(host.dispose);

    await tester.pumpWidget(host.build());
    await tester.pump();

    host.app = _appState(switching: _sdkAccount);
    await tester.tap(find.text('Bridge'));
    await tester.pumpAndSettle();

    expect(host.bridgePushes, isEmpty);
  });

  testWidgets('a disabled Bridge exposes its state and reason to semantics', (
    tester,
  ) async {
    _size(tester);
    final handle = tester.ensureSemantics();
    final host = _Host(_appState(linkedWallet: _otherAddress));
    addTearDown(host.dispose);

    await tester.pumpWidget(host.build());
    await tester.pump();

    final data = tester
        .getSemantics(find.bySemanticsLabel('Bridge'))
        .getSemanticsData();
    expect(data.hint, 'Only the earning wallet can bridge.');
    expect(data.flagsCollection.isButton, isTrue);
    expect(data.flagsCollection.isEnabled, ui.Tristate.isFalse);
    expect(
      find.bySemanticsLabel('Only the earning wallet can bridge.'),
      findsOneWidget,
    );
    handle.dispose();
  });

  group('entry contract', () {
    const disabled = BridgeGate(BridgeGateState.notEarning);
    const enabled = BridgeGate(BridgeGateState.enabled, coin: _gnus);

    Future<void> pumpEntry(
      WidgetTester tester,
      BridgeGate gate, {
      ThemeData? theme,
      VoidCallback? onPressed,
    }) {
      return tester.pumpWidget(
        MaterialApp(
          theme: theme ?? ThemeData(extensions: [GWColors.dark()]),
          home: Scaffold(
            body: Align(
              alignment: Alignment.topLeft,
              child: SizedBox(
                width: 264,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    BridgeButton(gate: gate, onPressed: onPressed ?? () {}),
                    BridgeReasonCaption(gate: gate),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    }

    setUpAll(() async {
      TestWidgetsFlutterBinding.ensureInitialized();
      final loader = FontLoader('Inter');
      for (final asset in const [
        'Inter-Regular.ttf',
        'Inter-Medium.ttf',
        'Inter-SemiBold.ttf',
      ]) {
        loader.addFont(rootBundle.load('assets/fonts/$asset'));
      }
      await loader.load();
    });

    testWidgets('enabled Bridge is an enabled button with no hint', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      var taps = 0;
      await pumpEntry(tester, enabled, onPressed: () => taps++);

      final data = tester
          .getSemantics(find.bySemanticsLabel('Bridge'))
          .getSemanticsData();
      expect(data.hint, isEmpty);
      expect(data.flagsCollection.isButton, isTrue);
      expect(data.flagsCollection.isEnabled, ui.Tristate.isTrue);
      expect(find.byType(BridgeReasonCaption), findsOneWidget);
      expect(find.byType(Text), findsOneWidget);

      await tester.tap(find.byType(BridgeButton));
      expect(taps, 1);
      handle.dispose();
    });

    testWidgets('a disabled Bridge ignores taps and its caption is its own '
        'node', (tester) async {
      final handle = tester.ensureSemantics();
      var taps = 0;
      await pumpEntry(tester, disabled, onPressed: () => taps++);

      await tester.tap(find.byType(BridgeButton), warnIfMissed: false);
      expect(taps, 0);
      expect(find.text('Only the earning wallet can bridge.'), findsOneWidget);
      expect(
        find.bySemanticsLabel('Only the earning wallet can bridge.'),
        findsOneWidget,
      );
      expect(find.byType(Tooltip), findsNothing);
      handle.dispose();
    });

    testWidgets('enabled is the gradient outline, disabled is tertiary with '
        'a dimmed label; both are 44px', (tester) async {
      final gw = GWColors.dark();

      await pumpEntry(tester, enabled);
      expect(
        tester.widget<GWButton>(find.byType(GWButton)).variant,
        GWButtonVariant.gradientOutline,
      );
      expect(
        find.descendant(
          of: find.byType(BridgeButton),
          matching: find.byType(ShaderMask),
        ),
        findsOneWidget,
      );
      expect(tester.getSize(find.byType(GWButton)).height, 44);
      expect(find.byType(Tooltip), findsNothing);

      await pumpEntry(tester, disabled);
      expect(
        tester.widget<GWButton>(find.byType(GWButton)).variant,
        GWButtonVariant.tertiary,
      );
      expect(
        find.descendant(
          of: find.byType(BridgeButton),
          matching: find.byType(ShaderMask),
        ),
        findsNothing,
      );
      expect(
        tester.widget<Text>(find.text('Bridge')).style!.color,
        gw.textPrimary.withAlpha(140),
      );
      expect(tester.getSize(find.byType(GWButton)).height, 44);
      expect(find.byType(Tooltip), findsNothing);
    });

    for (final mode in GWAppearanceMode.values) {
      testWidgets('caption and disabled label are legible on the page '
          'canvas -- $mode', (tester) async {
        final theme = themeFor(mode);
        final gw = theme.extension<GWColors>()!;
        await pumpEntry(tester, disabled, theme: theme);

        final captionColor = tester
            .widget<Text>(find.text('Only the earning wallet can bridge.'))
            .style!
            .color!;
        expect(captionColor, gw.textSecondary);
        expect(contrastRatio(captionColor, gw.surfaceBase), greaterThan(4.5));

        final decoration =
            tester
                    .widget<AnimatedContainer>(find.byType(AnimatedContainer))
                    .decoration!
                as BoxDecoration;
        final fillOnCanvas = Color.alphaBlend(
          decoration.color!,
          gw.surfaceBase,
        );
        final label = tester.widget<Text>(find.text('Bridge')).style!.color!;
        expect(
          contrastRatio(Color.alphaBlend(label, fillOnCanvas), fillOnCanvas),
          greaterThanOrEqualTo(3.0),
        );
      });
    }

    test('every static caption fits one line in 264px at scale 1.0', () {
      final captions = [
        for (final state in BridgeGateState.values)
          if (state != BridgeGateState.enabled) bridgeGateCaption(state)!,
      ];
      for (final caption in captions) {
        final painter = TextPainter(
          text: TextSpan(text: caption, style: GeniusWalletTypography.labelMd),
          textDirection: TextDirection.ltr,
          maxLines: 1,
        )..layout(maxWidth: 264);
        expect(painter.didExceedMaxLines, isFalse, reason: caption);
      }
    });

    testWidgets('a long network name ellipsizes but stays readable to '
        'semantics', (tester) async {
      final handle = tester.ensureSemantics();
      const gate = BridgeGate(
        BridgeGateState.gnusElsewhere,
        elsewhereNetwork: 'An Extremely Long Network Name Chain',
      );
      await pumpEntry(tester, gate);

      final caption = tester.widget<Text>(find.textContaining('GNUS is on'));
      expect(caption.maxLines, 1);
      expect(caption.softWrap, isFalse);
      expect(caption.overflow, TextOverflow.ellipsis);
      expect(
        find.bySemanticsLabel(
          'GNUS is on An Extremely Long Network Name Chain. Switch network.',
        ),
        findsOneWidget,
      );
      handle.dispose();
    });
  });
}
