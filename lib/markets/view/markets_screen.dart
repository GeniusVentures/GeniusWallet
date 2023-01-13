import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genius_api/genius_api.dart';
import 'package:genius_wallet/app/screens/loading_screen.dart';
import 'package:genius_wallet/app/widgets/app_screen_view.dart';
import 'package:genius_wallet/markets/bloc/markets_cubit.dart';
import 'package:genius_wallet/markets/bloc/markets_state.dart';
import 'package:genius_wallet/theme/genius_wallet_colors.g.dart';
import 'package:genius_wallet/widgets/components/back_button_header.g.dart';
import 'package:genius_wallet/widgets/components/market_graph.g.dart';
import 'package:go_router/go_router.dart';

class MarketsScreen extends StatelessWidget {
  const MarketsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AppScreenView(
        body: BlocProvider(
          create: (context) =>
              MarketsCubit(api: context.read<GeniusApi>())..loadMarkets(),
          child: const _CalculatorView(),
        ),
      ),
    );
  }
}

class _CalculatorView extends StatelessWidget {
  const _CalculatorView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30),
      child: Column(
        children: [
          SizedBox(
            height: 50,
            child: LayoutBuilder(
              builder: (context, constraints) {
                return BackButtonHeader(
                  constraints,
                  ovrTitle: '',
                );
              },
            ),
          ),
          const SizedBox(height: 30),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Markets',
                style: TextStyle(fontSize: 24),
              ),
              GestureDetector(
                onTap: () {
                  context.push('/calculator');
                },
                child: Text(
                  'Calculator',
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium!
                      .copyWith(color: GeniusWalletColors.darkGreen),
                ),
              ),
            ],
          ),
          const SizedBox(height: 30),
          const MarketsList(),
        ],
      ),
    );
  }
}

class MarketsList extends StatelessWidget {
  const MarketsList({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MarketsCubit, MarketsState>(
      builder: (context, state) {
        if (state.marketLoadingStatus == MarketsStatus.loading) {
          return const LoadingScreen();
        } else if (state.marketLoadingStatus == MarketsStatus.loaded) {
          final markets = state.markets.map((e) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 20.0),
              child: SizedBox(
                height: 200,
                child: LayoutBuilder(
                  builder: (BuildContext context, BoxConstraints constraints) {
                    //TODO: Get volume
                    return MarketGraph(
                      constraints,
                      ovrPricePerCoin: '${e.price} ${e.priceCurrency}',
                      ovrCoinToFiat: '${e.symbol}/${e.priceCurrency}',
                      ovrVolume: '',
                    );
                  },
                ),
              ),
            );
          }).toList();

          return Column(children: markets);
        }
        return const Center(
          child: Text('Something went wrong. Please try again.'),
        );
      },
    );
  }
}
