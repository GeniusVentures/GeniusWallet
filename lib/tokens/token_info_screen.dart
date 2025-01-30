import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genius_wallet/app/widgets/coins/view/coin_card_container.dart';
import 'package:genius_wallet/app/widgets/coins/view/coin_card_row.dart';
import 'package:genius_wallet/app/widgets/qr/crypto_address_qr.dart';
import 'package:genius_wallet/chart/crypto_live_chart.dart';
import 'package:genius_wallet/models/coin_gecko_coin.dart';
import 'package:genius_wallet/providers/coin_gecko_coin_provider.dart';
import 'package:genius_wallet/theme/genius_wallet_colors.g.dart';
import 'package:genius_wallet/wallets/cubit/wallet_details_cubit.dart';
import 'package:genius_wallet/widgets/components/action_button.dart';
import 'package:genius_wallet/widgets/components/sliding_drawer.dart';
import 'package:genius_wallet/widgets/components/sliding_drawer_button.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class TokenInfoScreen extends StatelessWidget {
  final String securityInfo;
  final bool? isGnusWalletConnected;
  final List<String> transactionHistory;

  const TokenInfoScreen({
    Key? key,
    required this.securityInfo,
    required this.transactionHistory,
    this.isGnusWalletConnected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final SlidingDrawerController qrCodeDrawerController =
        SlidingDrawerController();
    final SlidingDrawerController moreOptionsDrawerController =
        SlidingDrawerController();

    return BlocBuilder<WalletDetailsCubit, WalletDetailsState>(
      builder: (context, state) {
        final selectedCoin = state.selectedCoin;
        final selectedWallet = state.selectedWallet;
        final selectedNetwork = state.selectedNetwork;
        final walletDetailsCubit = context.read<WalletDetailsCubit>();

        // We need to compare the token symbol to our coin gecko token list to get
        // the ID to pass to the coin gecko api for that tokens data
        // assets/json/coins_list/coins_list.json
        // TODO: we need to have the wallet pull in the latest version of this list on daily or weekly cadence to support new tokens
        final coinGeckoCoinsList =
            Provider.of<CoinGeckoCoinProvider>(context).coins;

        // Find the token where the symbol matches the selected coin symbol (ignoring case)
        final matchingCoinGeckoToken = coinGeckoCoinsList.firstWhere(
          (coin) =>
              coin.symbol.toLowerCase() == selectedCoin?.symbol?.toLowerCase(),
          orElse: () => CoinGeckoCoin(
            id: '',
            symbol: '',
            name: 'Unknown Token',
          ), // Provide a default placeholder token
        );

        // For now hard code logic to allow bridging of only gnus tokens
        final isGnusBridgeEnabled = (isGnusWalletConnected ?? false) &&
            selectedCoin?.symbol?.toLowerCase() == 'gnus';

        return Scaffold(
          appBar: AppBar(
            title: Text(
              selectedCoin?.name ?? "Unknown",
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            centerTitle: true,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
          body: Stack(
            children: [
              SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 500),
                    child: Align(
                      alignment: Alignment.topCenter,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // Display chart if we found a matching id in the coingecko list
                          if (matchingCoinGeckoToken.id.isNotEmpty)
                            Center(
                              child: CryptoLiveChart(
                                  tokenDecimals: selectedCoin?.decimals,
                                  coinId: matchingCoinGeckoToken.id), //
                            ),
                          const SizedBox(height: 24),
                          Row(
                            children: [
                              ActionButton(
                                text: "Receive",
                                icon: Icons.qr_code,
                                onPressed: () {
                                  qrCodeDrawerController.openDrawer();
                                },
                              ),
                              const SizedBox(width: 8),
                              const ActionButton(
                                  text: "Send", icon: Icons.send),
                              const SizedBox(width: 8),
                              const ActionButton(
                                  text: "Swap", icon: Icons.swap_horiz),
                              const SizedBox(width: 8),
                              ActionButton(
                                text: "More",
                                icon: Icons.more_horiz,
                                onPressed: () {
                                  moreOptionsDrawerController.openDrawer();
                                },
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          ListTile(
                            contentPadding: EdgeInsets.zero,
                            title: const Text(
                              "Your Balance",
                              style:
                                  TextStyle(color: GeniusWalletColors.gray500),
                            ),
                            subtitle: CoinCardContainer(
                              child: CoinCardRow(
                                iconPath: selectedCoin?.iconPath ?? "",
                                balance: selectedCoin?.balance ?? 0.0,
                                name: selectedCoin?.name ?? "unknown",
                                symbol: selectedCoin?.symbol ?? "unknown",
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          ListTile(
                            contentPadding: EdgeInsets.zero,
                            title: const Text(
                              "Info",
                              style:
                                  TextStyle(color: GeniusWalletColors.gray500),
                            ),
                            subtitle: Card(
                              margin: EdgeInsets.zero,
                              color: GeniusWalletColors.deepBlueCardColor,
                              elevation: 1,
                              child: ListTile(
                                title: const Text("Token Address"),
                                subtitle: Text("${selectedCoin?.address}"),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          _buildSecuritySection(),
                          const SizedBox(height: 16),
                          _buildActivitySection(),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              SlidingDrawer(
                controller: qrCodeDrawerController,
                title: "Receive ${selectedCoin?.name}",
                content: Container(
                  margin: EdgeInsets.only(
                      top: MediaQuery.of(context).size.height * .15),
                  alignment: Alignment.center,
                  child: Column(
                    children: [
                      CryptoAddressQR(
                        iconPath: selectedCoin?.iconPath,
                        address: selectedWallet?.address ?? "",
                        network: selectedNetwork?.name ?? "",
                      ),
                    ],
                  ),
                ),
              ),
              SlidingDrawer(
                controller: moreOptionsDrawerController,
                title: "More Options",
                content: Container(
                  child: isGnusBridgeEnabled
                      ? SlidingDrawerButton(
                          onPressed: selectedCoin?.balance == 0
                              ? null
                              : () async {
                                  moreOptionsDrawerController.closeDrawer();
                                  await context.push('/bridge',
                                      extra: walletDetailsCubit);
                                  // after we come back to coins screen reload coins / balance
                                  walletDetailsCubit.getCoins();
                                  walletDetailsCubit.getWalletBalance();
                                },
                          label: "Bridge Tokens",
                        )
                      : null,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  /// Security Section
  Widget _buildSecuritySection() {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: const Text(
        "Security",
        style: TextStyle(color: GeniusWalletColors.gray500),
      ),
      subtitle: Card(
        margin: EdgeInsets.zero,
        color: GeniusWalletColors.deepBlueCardColor,
        elevation: 1,
        child: ListTile(title: Text(securityInfo)),
      ),
    );
  }

  /// Activity Section
  Widget _buildActivitySection() {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: const Text(
        "Activity",
        style: TextStyle(color: GeniusWalletColors.gray500),
      ),
      subtitle: Card(
        margin: EdgeInsets.zero,
        color: GeniusWalletColors.deepBlueCardColor,
        elevation: 1,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: transactionHistory
              .map((tx) => ListTile(title: Text(tx)))
              .toList(),
        ),
      ),
    );
  }
}
