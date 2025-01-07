import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genius_api/genius_api.dart';
import 'package:genius_api/models/coin.dart';
import 'package:genius_api/models/sgnus_connection.dart';
import 'package:genius_api/tw/coin_util.dart';
import 'package:genius_wallet/app/utils/wallet_utils.dart';
import 'package:genius_wallet/app/widgets/loading/loading.dart';
import 'package:genius_wallet/dashboard/wallets/cubit/wallet_details_cubit.dart';
import 'package:genius_wallet/theme/genius_wallet_colors.g.dart';
import 'package:genius_wallet/theme/genius_wallet_consts.dart';
import 'package:go_router/go_router.dart';

class CoinsScreen extends StatefulWidget {
  final Function(Coin)? onCoinSelected;

  /// Coins you wish to filter out from the list of coins
  final List<Coin?>? filterCoins;

  const CoinsScreen({Key? key, this.onCoinSelected, this.filterCoins})
      : super(key: key);

  @override
  CoinsScreenState createState() => CoinsScreenState();
}

class CoinsScreenState extends State<CoinsScreen> {
  @override
  Widget build(BuildContext context) {
    return BlocListener<WalletDetailsCubit, WalletDetailsState>(
      listener: (context, state) {
        final walletCubit = context.read<WalletDetailsCubit>();

        if (state.coinsStatus == WalletStatus.initial &&
            state.selectedNetwork != null) {
          walletCubit.getCoins();
        }
      },
      child: BlocBuilder<WalletDetailsCubit, WalletDetailsState>(
        builder: (context, state) {
          final walletCubit = context.read<WalletDetailsCubit>();

          if (state.coinsStatus == WalletStatus.loading) {
            return const CoinCardContainer(
              child: Center(child: Loading(text: 'Loading Coins')),
            );
          }

          if (state.coins.isEmpty) {
            return const CoinCardContainer(
              child: Center(
                child: AutoSizeText(
                  'No Coins Detected',
                  style: TextStyle(
                    fontSize: 24,
                    color: GeniusWalletColors.btnTextDisabled,
                  ),
                ),
              ),
            );
          }

          return Wrap(
            runSpacing: 8,
            children: [
              for (var coin in state.coins)
                if (widget.filterCoins?.contains(coin) == false ||
                    widget.filterCoins == null)
                  GestureDetector(
                    onTap: () {
                      if (widget.onCoinSelected != null) {
                        widget.onCoinSelected!(coin);
                      }
                    },
                    child: CoinCardContainer(
                        child: StreamBuilder<SGNUSConnection>(
                            stream: context
                                .read<GeniusApi>()
                                .getSGNUSConnectionStream(),
                            builder: (context, snapshot) {
                              final connection = snapshot.data;
                              return CoinCardRow(
                                iconPath: coin.iconPath ?? "",
                                balance: coin.balance ?? 0.0,
                                name: coin.name ?? "",
                                symbol: coin.symbol ?? "",
                                // hardcode for gnus to bridge
                                // should not be able to bridge unless this wallet is connected to the sgnus network
                                additionalCardWidget: coin.symbol
                                                ?.toLowerCase() ==
                                            'gnus' &&
                                        state.selectedWallet?.address ==
                                            connection?.walletAddress
                                    ? TextButton(
                                        style: TextButton.styleFrom(
                                            backgroundColor: Colors.transparent,
                                            padding: const EdgeInsets.only(
                                                left: 12, right: 12)),
                                        onPressed: (coin.balance == 0 ||
                                                (!(connection
                                                        ?.isConnected ?? // only allow bridging if connected to sgnus network
                                                    false)))
                                            ? null
                                            : () async {
                                                walletCubit.selectCoin(coin);
                                                await context.push('/bridge',
                                                    extra: walletCubit);
                                                // after we come back to coins screen reload coins / balance
                                                walletCubit.getCoins();
                                                walletCubit.getWalletBalance();
                                              },
                                        child: const AutoSizeText(
                                          "Bridge Tokens",
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      )
                                    : null,
                              );
                            })),
                  ),
            ],
          );
        },
      ),
    );
  }
}

class CoinCardRow extends StatelessWidget {
  final String iconPath;
  final String name;
  final String symbol;
  final double balance;
  final Widget? additionalCardWidget;
  const CoinCardRow(
      {Key? key,
      required this.iconPath,
      required this.name,
      required this.balance,
      required this.symbol,
      this.additionalCardWidget})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Flexible(
          child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Image.asset(
            iconPath,
            height: 48,
            width: 48,
            errorBuilder: (context, error, stackTrace) {
              return const SizedBox(height: 48, width: 48);
            },
          ),
          const SizedBox(width: 12),
          Flexible(
              child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Flexible(
                  child: AutoSizeText(
                name,
                overflow: TextOverflow.ellipsis,
              )),
              Row(
                children: [
                  Flexible(
                      child: AutoSizeText(
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: GeniusWalletColors.gray500),
                    balance == 0
                        ? '0'
                        : WalletUtils.truncateToDecimals(balance.toString()),
                  )),
                  const SizedBox(width: 8),
                  AutoSizeText(
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                    style: const TextStyle(color: GeniusWalletColors.gray500),
                    symbol,
                  )
                ],
              )
            ],
          )),
        ],
      )),
      if (additionalCardWidget != null) ...[
        const SizedBox(width: 8),
        additionalCardWidget ?? const SizedBox.shrink()
      ]
    ]);
  }
}

class CoinCardContainer extends StatelessWidget {
  final Widget child;
  const CoinCardContainer({Key? key, required this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80,
      width: MediaQuery.of(context).size.width,
      padding: const EdgeInsets.only(left: 16, right: 16),
      decoration: const BoxDecoration(
        color: GeniusWalletColors.deepBlueCardColor,
        borderRadius: BorderRadius.all(
          Radius.circular(GeniusWalletConsts.borderRadiusCard),
        ),
      ),
      child: child,
    );
  }
}
