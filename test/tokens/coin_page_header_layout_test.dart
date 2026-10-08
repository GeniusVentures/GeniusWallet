import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:genius_api/genius_api.dart';
import 'package:genius_wallet/components/scaffold/gw_page_header.dart';
import 'package:genius_wallet/hive/models/coin_gecko_market_data.dart';
import 'package:genius_wallet/providers/network_tokens_provider.dart';
import 'package:genius_wallet/theme/genius_wallet_typography.dart';
import 'package:genius_wallet/theme/gw_colors.dart';
import 'package:genius_wallet/tokens/token_info_args.dart';
import 'package:genius_wallet/tokens/token_info_screen.dart';
import 'package:genius_wallet/wallets/cubit/wallet_details_cubit.dart';

class _UnusedApi implements GeniusApi {
  @override
  dynamic noSuchMethod(Invocation i) => super.noSuchMethod(i);
}

CoinGeckoMarketData _btc() => CoinGeckoMarketData.fromJson({
  'id': 'bitcoin',
  'symbol': 'btc',
  'name': 'Bitcoin',
  'image': '',
  'current_price': 8102.0,
  'high_24h': 82000.0,
  'low_24h': 80000.0,
  'price_change_percentage_24h': 1.2,
});

Widget _host() => BlocProvider(
  create: (_) => WalletDetailsCubit(
    geniusApi: _UnusedApi(),
    networkTokensProvider: NetworkTokensProvider(),
  ),
  child: MaterialApp(
    theme: ThemeData(extensions: [GWColors.dark()]),
    home: Builder(
      builder: (context) => TokenInfoScreen(
        walletDetailsCubit: context.read<WalletDetailsCubit>(),
        args: TokenInfoArgs(marketData: _btc()),
      ),
    ),
  ),
);

void main() {
  final style = GeniusWalletTypography.headlineLg;
  final double oneLine = style.fontSize! * style.height!;

  for (final size in const [Size(360, 800), Size(1400, 1000)]) {
    testWidgets('the coin name stays on one line at ${size.width}', (
      tester,
    ) async {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(_host());
      await tester.pump();

      final name = find.descendant(
        of: find.byType(GWPageHeader),
        matching: find.text('Bitcoin'),
      );
      final paragraph = tester.renderObject<RenderParagraph>(name);
      expect(paragraph.size.height, oneLine);
      expect(paragraph.didExceedMaxLines, isFalse);
      expect(find.text(formatPrice(8102.0)), findsWidgets);
    });
  }
}
