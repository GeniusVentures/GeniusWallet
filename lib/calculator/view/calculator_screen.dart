import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genius_api/genius_api.dart';
import 'package:genius_wallet/app/screens/loading_screen.dart';
import 'package:genius_wallet/app/widgets/app_screen_view.dart';
import 'package:genius_wallet/calculator/bloc/calculator_bloc.dart';
import 'package:genius_wallet/calculator/bloc/calculator_event.dart';
import 'package:genius_wallet/calculator/bloc/calculator_state.dart';
import 'package:genius_wallet/calculator/widgets/desktop_calculator.dart';
import 'package:genius_wallet/theme/genius_wallet_colors.g.dart';
import 'package:genius_wallet/widgets/components/back_button_header.g.dart';
import 'package:genius_wallet/widgets/components/coin_stats_card.g.dart';
import 'package:genius_wallet/widgets/components/conversion_result.g.dart';
import 'package:genius_wallet/widgets/components/currency_selector/mode_from.g.dart';
import 'package:genius_wallet/widgets/components/currency_selector/mode_to.g.dart';
import 'package:genius_wallet/widgets/components/enter_amount.g.dart';
import 'package:genius_wallet/widgets/components/header.g.dart';

class CalculatorScreen extends StatelessWidget {
  const CalculatorScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: GeniusWalletColors.deepBlueTertiary,
      body: BlocProvider(
        create: (context) => CalculatorBloc(
          geniusApi: context.read<GeniusApi>(),
        )..add(GetCurrencies()),
        child: BlocBuilder<CalculatorBloc, CalculatorState>(
          builder: (context, state) {
            if (state.currencies.isNotEmpty) {
              return LayoutBuilder(builder: (context, constraints) {
                if (constraints.maxWidth <= 1240) {
                  return const _CalculatorView();
                }
                return const _CalculatorViewDesktop();
              });
            } else if (state.getCurrenciesStatus == CalculatorStatus.error) {
              return const Center(
                child: Text(
                  'Something went wrong loading this screen. Please try again!',
                ),
              );
            } else {
              return const LoadingScreen();
            }
          },
        ),
      ),
    );
  }
}

class _CalculatorViewDesktop extends StatelessWidget {
  const _CalculatorViewDesktop({
    Key? key,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return AppScreenView(
      body: Row(
        children: [
          Container(
            margin: const EdgeInsets.only(left: 40, top: 40),
            width: 580,
            child: const DesktopCalculator(),
          ),
          const Spacer(),
          Container(
            margin: const EdgeInsets.only(right: 40),
            width: 580,
            child: const CoinsOverview(),
          ),
        ],
      ),
    );
  }
}

class _CalculatorView extends StatelessWidget {
  const _CalculatorView({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppScreenView(
      body: Column(
        children: [
          Padding(
              padding: const EdgeInsets.only(left: 20, right: 20),
              child: Column(children: [
                SizedBox(
                  height: 30,
                  child: LayoutBuilder(
                    builder:
                        (BuildContext context, BoxConstraints constraints) {
                      return Header(
                        constraints,
                        ovrHeaderName: 'Calculator',
                      );
                    },
                  ),
                ),
                const SizedBox(height: 30),
                SizedBox(
                  height: 120,
                  child: LayoutBuilder(
                    builder:
                        (BuildContext context, BoxConstraints constraints) {
                      return ModeFrom(constraints);
                    },
                  ),
                ),
                SizedBox(
                  height: 120,
                  child: LayoutBuilder(
                    builder:
                        (BuildContext context, BoxConstraints constraints) {
                      return ModeTo(constraints);
                    },
                  ),
                ),
                SizedBox(
                  height: 120,
                  child: LayoutBuilder(
                    builder:
                        (BuildContext context, BoxConstraints constraints) {
                      return EnterAmount(constraints);
                    },
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  height: 115,
                  child: LayoutBuilder(
                    builder:
                        (BuildContext context, BoxConstraints constraints) {
                      return BlocBuilder<CalculatorBloc, CalculatorState>(
                        builder: (context, state) {
                          if (state.getResultStatus ==
                              CalculatorStatus.loading) {
                            return const Center(
                                child: CircularProgressIndicator());
                          }
                          if (state.conversionResult.isNotEmpty) {
                            return ConversionResult(
                              constraints,
                              ovrAmountentered: state.amountToConvert,
                              ovrResult:
                                  '${state.currencyFrom!.symbol} = ${state.conversionResult} ${state.currencyTo!.symbol}',
                            );
                          }
                          return const SizedBox();
                        },
                      );
                    },
                  ),
                ),
                const SizedBox(height: 20),
                const CoinsOverview(),
              ]))
        ],
      ),
    );
  }
}

class CoinsOverview extends StatelessWidget {
  const CoinsOverview({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CalculatorBloc, CalculatorState>(
      builder: (context, state) {
        if (state.getResultStatus == CalculatorStatus.loaded) {
          return Column(
            children: [
              SizedBox(
                height: 225,
                child: LayoutBuilder(
                  builder: (BuildContext context, BoxConstraints constraints) {
                    return CoinStatsCard(
                      constraints,
                      ovrCoinName: state.currencyFrom!.name,
                      ovrCurrencySymbol: state.currencyFrom!.symbol,
                      ovrAmountchanged: '', //TODO:
                      ovrShape: state.currencyFrom!.logoUrl == null
                          ? Container()
                          : Image.network(state.currencyFrom!.logoUrl!),
                      ovrPrice: state.currencyFrom!.price,
                    );
                  },
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                height: 225,
                child: LayoutBuilder(
                  builder: (BuildContext context, BoxConstraints constraints) {
                    return CoinStatsCard(
                      constraints,
                      ovrCoinName: state.currencyTo!.name,
                      ovrCurrencySymbol: state.currencyTo!.symbol,
                      ovrAmountchanged: '', //TODO:
                      ovrShape: state.currencyTo!.logoUrl == null
                          ? Container()
                          : Image.network(state.currencyTo!.logoUrl!),
                      ovrPrice: state.currencyTo!.price,
                    );
                  },
                ),
              ),
            ],
          );
        }
        return const SizedBox();
      },
    );
  }
}
