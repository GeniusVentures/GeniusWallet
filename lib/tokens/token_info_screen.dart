import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genius_api/models/coin.dart';
import 'package:genius_wallet/app/widgets/coins/view/coin_card_row.dart';
import 'package:genius_wallet/app/widgets/qr/crypto_address_qr.dart';
import 'package:genius_wallet/chart/crypto_live_chart.dart';
import 'package:genius_wallet/models/coin_gecko_coin.dart';
import 'package:genius_wallet/models/coin_gecko_market_data.dart';
import 'package:genius_wallet/providers/coin_gecko_coin_provider.dart';
import 'package:genius_wallet/theme/genius_wallet_colors.g.dart';
import 'package:genius_wallet/tokens/convert_section.dart';
import 'package:genius_wallet/tokens/market_data_info.dart';
import 'package:genius_wallet/wallets/cubit/wallet_details_cubit.dart';
import 'package:genius_wallet/widgets/components/action_button.dart';
import 'package:genius_wallet/widgets/components/sliding_drawer.dart';
import 'package:genius_wallet/widgets/components/sliding_drawer_button.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

class TokenInfoScreen extends StatelessWidget {
  final String securityInfo;
  final bool? isGnusWalletConnected;
  final List<String> transactionHistory;
  final CoinGeckoMarketData? marketData;

  const TokenInfoScreen({
    Key? key,
    required this.securityInfo,
    required this.transactionHistory,
    this.marketData,
    this.isGnusWalletConnected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<WalletDetailsCubit, WalletDetailsState>(
      builder: (context, state) {
        final selectedCoin = state.selectedCoin;
        final selectedWallet = state.selectedWallet;
        final selectedNetwork = state.selectedNetwork;
        final walletDetailsCubit = context.read<WalletDetailsCubit>();

        final coinGeckoCoinsList =
            Provider.of<CoinGeckoCoinProvider>(context).coins;

        final matchingCoinGeckoToken = coinGeckoCoinsList.firstWhere(
          (coin) =>
              coin.symbol.toLowerCase() == selectedCoin?.symbol?.toLowerCase(),
          orElse: () => CoinGeckoCoin(
            id: '',
            symbol: '',
            name: 'Unknown Token',
          ),
        );

        final isGnusBridgeEnabled = (isGnusWalletConnected ?? false) &&
            selectedCoin?.symbol?.toLowerCase() == 'gnus';

        return Scaffold(
          appBar: AppBar(
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
          body: LayoutBuilder(
            builder: (context, constraints) {
              bool isDesktop = constraints.maxWidth > 750;

              return SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: isDesktop
                      ? Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            // **Graph on Left**
                            Expanded(
                              flex: constraints.maxWidth < 1000
                                  ? 1
                                  : constraints.maxWidth < 1500
                                      ? 2
                                      : 3,
                              child: Column(
                                children: [
                                  _buildGraphSection(
                                      matchingCoinGeckoToken,
                                      selectedCoin,
                                      _buildStaticActions(
                                          selectedCoin,
                                          context,
                                          selectedWallet,
                                          selectedNetwork,
                                          isGnusBridgeEnabled,
                                          walletDetailsCubit)),
                                ],
                              ),
                            ),
                            const SizedBox(width: 32),
                            // **Details on Right**
                            Expanded(
                              flex: 1,
                              child: _buildActionSection(
                                selectedCoin,
                                selectedNetwork,
                                walletDetailsCubit,
                                context,
                                selectedWallet,
                                isGnusBridgeEnabled,
                              ),
                            ),
                          ],
                        )
                      : Column(
                          children: [
                            _buildGraphSection(
                                matchingCoinGeckoToken, selectedCoin, null),
                            const SizedBox(height: 20),
                            _buildStaticActions(
                                selectedCoin,
                                context,
                                selectedWallet,
                                selectedNetwork,
                                isGnusBridgeEnabled,
                                walletDetailsCubit),
                            const SizedBox(height: 24),
                            _buildActionSection(
                              selectedCoin,
                              selectedNetwork,
                              walletDetailsCubit,
                              context,
                              selectedWallet,
                              isGnusBridgeEnabled,
                            ),
                          ],
                        ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  /// **Graph Section**
  Widget _buildGraphSection(
      CoinGeckoCoin matchingCoin, Coin? selectedCoin, Widget? child) {
    return matchingCoin.id.isNotEmpty
        ? CryptoLiveChart(
            tokenDecimals: selectedCoin?.decimals,
            coinId: matchingCoin.id,
            child: child != null ? SizedBox(width: 400, child: child) : null,
          )
        : const SizedBox();
  }

  /// **Action Buttons**
  Widget _buildStaticActions(selectedCoin, context, selectedWallet,
      selectedNetwork, isGnusBridgeEnabled, walletDetailsCubit) {
    final SlidingDrawerController qrCodeDrawerController =
        SlidingDrawerController();
    final SlidingDrawerController moreOptionsDrawerController =
        SlidingDrawerController();

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ActionButton(
          text: "Receive",
          icon: Icons.qr_code,
          onPressed: qrCodeDrawerController.openDrawer,
        ),
        const SizedBox(width: 8),
        const ActionButton(text: "Send", icon: Icons.send),
        const SizedBox(width: 8),
        const ActionButton(text: "Swap", icon: Icons.swap_horiz),
        const SizedBox(width: 8),
        ActionButton(
          text: "More",
          icon: Icons.more_horiz,
          onPressed: moreOptionsDrawerController.openDrawer,
        ),
        SlidingDrawer(
          controller: qrCodeDrawerController,
          title: "Receive ${selectedCoin?.name}",
          content: Container(
            margin:
                EdgeInsets.only(top: MediaQuery.of(context).size.height * .15),
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
                                await GoRouter.of(context)
                                    .push('/bridge', extra: walletDetailsCubit);
                                // after we come back to coins screen reload coins / balance
                                walletDetailsCubit.getCoins();
                              },
                        label: "Bridge Tokens",
                      )
                    : null))
      ],
    );
  }

  /// **Details Section**
  Widget _buildActionSection(
    Coin? selectedCoin,
    dynamic selectedNetwork,
    WalletDetailsCubit walletDetailsCubit,
    context,
    dynamic selectedWallet,
    bool isGnusBridgeEnabled,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // **Your Balance**
        ListTile(
          contentPadding: EdgeInsets.zero,
          title: const Padding(
            padding: EdgeInsets.only(bottom: 8),
            child: Text(
              "Your Balance",
              style: TextStyle(color: GeniusWalletColors.gray500),
            ),
          ),
          subtitle: CoinCardRow(
            iconPath: selectedCoin?.iconPath ?? "",
            balance: selectedCoin?.balance ?? 0.0,
            name: selectedCoin?.name ?? "unknown",
            symbol: selectedCoin?.symbol ?? "unknown",
            marketData: marketData,
          ),
        ),

        const SizedBox(height: 16),

        // **Market Data Info**
        MarketDataInfo(
          marketData: marketData,
          address: selectedCoin?.address,
          network: selectedNetwork?.name ?? "",
        ),

        const SizedBox(height: 16),
        ConvertSection(tokenPrice: marketData?.currentPrice ?? 0.0),
        const SizedBox(height: 16),
        _buildSecuritySection(),
        const SizedBox(height: 16),
        _buildActivitySection(),
      ],
    );
  }

  Widget _buildSecuritySection() {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: const Padding(
        padding: EdgeInsets.only(bottom: 8),
        child: Text(
          "Security",
          style: TextStyle(color: GeniusWalletColors.gray500),
        ),
      ),
      subtitle: Card(
        margin: EdgeInsets.zero,
        color: GeniusWalletColors.deepBlueCardColor,
        elevation: 1,
        child: ListTile(title: Text(securityInfo)),
      ),
    );
  }

  Widget _buildActivitySection() {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: const Padding(
        padding: EdgeInsets.only(bottom: 8),
        child: Text(
          "Activity",
          style: TextStyle(color: GeniusWalletColors.gray500),
        ),
      ),
      subtitle: Card(
        margin: EdgeInsets.zero,
        color: GeniusWalletColors.deepBlueCardColor,
        elevation: 1,
        child: Column(
          children: transactionHistory
              .map((tx) => ListTile(title: Text(tx)))
              .toList(),
        ),
      ),
    );
  }
}
