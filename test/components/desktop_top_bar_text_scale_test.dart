// The desktop top bar at large system text, measured in real Inter.
//
// The bar's controls keep their natural widths, so only the text scale
// decides whether it fits. These cases pump the full bar at the two tightest
// widths it lays out at - the narrowest desktop window, and the width where
// nav labels reappear - and fail on any overflow the bar reports.
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show FontLoader, rootBundle;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:genius_api/ffi/trust_wallet_api_ffi.dart';
import 'package:genius_api/genius_api.dart';
import 'package:genius_api/models/network.dart';
import 'package:genius_api/types/wallet_type.dart';
import 'package:genius_wallet/bloc/app_bloc.dart';
import 'package:genius_wallet/components/overlay/responsive_overlay.dart';
import 'package:genius_wallet/dashboard/transactions/cubit/transactions_cubit.dart';
import 'package:genius_wallet/hive/constants/cache.dart';
import 'package:genius_wallet/providers/network_provider.dart';
import 'package:genius_wallet/providers/network_tokens_provider.dart';
import 'package:genius_wallet/theme/theme.dart';
import 'package:genius_wallet/utils/breakpoints.dart';
import 'package:genius_wallet/wallets/cubit/wallet_details_cubit.dart';
import 'package:go_router/go_router.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';

/// The real `GeniusApi` constructor dlopens the native SDK; nothing the bar
/// renders calls into it.
class _FakeGeniusApi implements GeniusApi {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _SeededAppBloc extends AppBloc {
  _SeededAppBloc({
    required super.api,
    required super.transactionsCubit,
    required super.walletDetailsCubit,
    required super.networkProvider,
  }) {
    // Every optional field shown, so the right-hand cluster is at its widest.
    emit(
      state.copyWith(
        wallets: const [_wallet],
        sdkAccounts: const [_address],
        selectedSDKAccount: _address,
      ),
    );
  }
}

class _SeededNetworkProvider extends NetworkProvider {
  @override
  List<Network> get networks => const [_network];
}

const _address = '0xAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA';

const _wallet = Wallet(
  coinType: TWCoinType.TWCoinTypeEthereum,
  walletName: 'Main',
  currencySymbol: 'ETH',
  walletType: WalletType.privateKey,
  balance: 0,
  address: _address,
);

const _network = Network(
  name: 'Testchain',
  symbol: 'TST',
  chainId: 90001,
  rpcUrl: 'https://testchain.invalid',
  iconPath: 'assets/images/crypto/eth.png',
);

Future<void> _loadInter() async {
  final loader = FontLoader('Inter');
  for (final String asset in const <String>[
    'assets/fonts/Inter-Regular.ttf',
    'assets/fonts/Inter-Medium.ttf',
    'assets/fonts/Inter-SemiBold.ttf',
    'assets/fonts/Inter-Bold.ttf',
  ]) {
    loader.addFont(rootBundle.load(asset));
  }
  await loader.load();
}

/// Pumps the bar at [width] x 800 and returns every error it reported.
Future<List<String>> _pumpBar(
  WidgetTester tester, {
  required double width,
  required double textScale,
}) async {
  tester.view.physicalSize = Size(width, 800);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  final api = _FakeGeniusApi();
  final walletDetailsCubit = WalletDetailsCubit(
    geniusApi: api,
    networkTokensProvider: NetworkTokensProvider(),
  );
  final networkProvider = _SeededNetworkProvider();
  final transactionsCubit = TransactionsCubit();
  final appBloc = _SeededAppBloc(
    api: api,
    transactionsCubit: transactionsCubit,
    walletDetailsCubit: walletDetailsCubit,
    networkProvider: networkProvider,
  );

  final errors = <String>[];
  final previous = FlutterError.onError;
  FlutterError.onError = (details) => errors.add(details.toString());
  try {
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          RepositoryProvider<GeniusApi>.value(value: api),
          BlocProvider<WalletDetailsCubit>.value(value: walletDetailsCubit),
          BlocProvider<TransactionsCubit>.value(value: transactionsCubit),
          BlocProvider<AppBloc>.value(value: appBloc),
          ChangeNotifierProvider<NetworkProvider>.value(value: networkProvider),
        ],
        child: MaterialApp.router(
          theme: getThemeData(),
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(
              context,
            ).copyWith(textScaler: TextScaler.linear(textScale)),
            child: child!,
          ),
          routerConfig: GoRouter(
            initialLocation: '/dashboard',
            routes: [
              GoRoute(
                path: '/dashboard',
                builder: (_, _) =>
                    const DesktopOverlay(child: SizedBox.expand()),
              ),
            ],
          ),
        ),
      ),
    );
    await tester.pump();
    // The logo measures 0 wide until decoded, which fake async never does.
    await tester.runAsync(
      () => precacheImage(
        const AssetImage(
          'assets/images/geniusappbarlogo.png',
          package: 'genius_wallet',
        ),
        tester.element(find.byType(DesktopOverlay)),
      ),
    );
    await tester.pump(const Duration(milliseconds: 300));
  } finally {
    FlutterError.onError = previous;
  }

  await tester.pumpWidget(const SizedBox.shrink());
  await tester.runAsync(() => appBloc.close());
  await walletDetailsCubit.close();
  await transactionsCubit.close();
  return errors;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    await _loadInter();
    // In-memory boxes: the network and wallet chips read their saved choice.
    await Hive.openBox(walletBoxName, bytes: Uint8List(0));
    await Hive.openBox(networkBoxName, bytes: Uint8List(0));
  });

  // 2.0 is past Windows' 150% report and near its 225% ceiling.
  for (final width in const [
    GeniusBreakpoints.large + 1,
    GeniusBreakpoints.xxl,
  ]) {
    for (final textScale in const [1.0, 1.5, 2.0]) {
      testWidgets(
        'the desktop bar fits at ${width.toInt()}px and text x$textScale',
        (tester) async {
          final errors = await _pumpBar(
            tester,
            width: width,
            textScale: textScale,
          );
          expect(errors, isEmpty);
        },
      );
    }
  }
}
