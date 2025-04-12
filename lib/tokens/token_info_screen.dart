import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genius_api/models/coin.dart';
import 'package:genius_api/models/network.dart';
import 'package:genius_api/models/wallet.dart';
import 'package:genius_wallet/app/widgets/coins/view/coin_card_row.dart';
import 'package:genius_wallet/app/widgets/qr/crypto_address_qr.dart';
import 'package:genius_wallet/chart/crypto_live_chart.dart';
import 'package:genius_wallet/hive/models/coin_gecko_market_data.dart';
import 'package:genius_wallet/theme/genius_wallet_colors.g.dart';
import 'package:genius_wallet/tokens/convert_section.dart';
import 'package:genius_wallet/tokens/market_data_info.dart';
import 'package:genius_wallet/wallets/cubit/wallet_details_cubit.dart';
import 'package:genius_wallet/widgets/components/action_button.dart';
import 'package:genius_wallet/widgets/components/bottom_drawer/responsive_drawer.dart';
import 'package:genius_wallet/widgets/components/sliding_drawer_button.dart';
import 'package:go_router/go_router.dart';

class TokenInfoScreen extends StatelessWidget {
  final String securityInfo;
  final bool? isGnusWalletConnected;
  final List<String> transactionHistory;
  final CoinGeckoMarketData? marketData;
  final WalletDetailsCubit? walletDetailsCubit; // Optional cubit

  const TokenInfoScreen({
    Key? key,
    required this.securityInfo,
    required this.transactionHistory,
    this.marketData,
    this.isGnusWalletConnected,
    this.walletDetailsCubit, // Allow null
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (walletDetailsCubit == null) {
      // If no cubit is provided, return UI without wallet-dependent features
      return _buildScreenWithoutCubit(context);
    }

    return BlocProvider.value(
      value: walletDetailsCubit!,
      child: BlocBuilder<WalletDetailsCubit, WalletDetailsState>(
        builder: (context, state) {
          return _buildScreenWithCubit(context, state);
        },
      ),
    );
  }

  /// **Screen when WalletDetailsCubit is NOT available**
  Widget _buildScreenWithoutCubit(BuildContext context) {
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
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: constraints.maxWidth < 1000
                              ? 1
                              : constraints.maxWidth < 1500
                                  ? 2
                                  : 3,
                          child: Column(
                            children: [
                              const SizedBox(height: 50),
                              _buildGraphSection(marketData, null),
                            ],
                          ),
                        ),
                        const SizedBox(width: 32),
                        Expanded(
                          flex: 1,
                          child: _buildActionSection(
                            marketData,
                            null,
                            null,
                            null,
                            context,
                            null,
                            null,
                          ),
                        ),
                      ],
                    )
                  : Column(
                      children: [
                        _buildGraphSection(marketData, null),
                        const SizedBox(height: 24),
                        _buildActionSection(
                          marketData,
                          null,
                          null,
                          null,
                          context,
                          null,
                          null,
                        ),
                      ],
                    ),
            ),
          );
        },
      ),
    );
  }

  /// **Screen when WalletDetailsCubit is available**
  Widget _buildScreenWithCubit(BuildContext context, WalletDetailsState state) {
    final selectedCoin = state.selectedCoin;
    final selectedWallet = state.selectedWallet;
    final selectedNetwork = state.selectedNetwork;
    final walletDetailsCubit = context.read<WalletDetailsCubit>();

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
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: constraints.maxWidth < 1000
                              ? 1
                              : constraints.maxWidth < 1500
                                  ? 2
                                  : 3,
                          child: Column(
                            children: [
                              const SizedBox(height: 50),
                              _buildGraphSection(
                                  marketData,
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
                        Expanded(
                          flex: 1,
                          child: _buildActionSection(
                            marketData,
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
                        _buildGraphSection(marketData, null),
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
                          marketData,
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
  }

  /// **Security Section**
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

  /// **Activity Section**
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

  /// **Graph Section**
  Widget _buildGraphSection(CoinGeckoMarketData? marketData, Widget? child) {
    if (marketData == null) {
      return const SizedBox();
    }
    return CryptoLiveChart(
      coinGeckoCoinId: marketData.id,
      tokenSymbol: marketData.symbol,
      child: child != null ? SizedBox(width: 400, child: child) : null,
    );
  }

  /// **Action Buttons**
  Widget _buildStaticActions(selectedCoin, context, selectedWallet,
      selectedNetwork, isGnusBridgeEnabled, walletDetailsCubit) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ActionButton(
          text: "Receive",
          icon: Icons.qr_code,
          onPressed: () {
            ResponsiveDrawer.show<void>(
              context: context,
              title: "Receive ${selectedCoin?.name}",
              children: [
                Container(
                  margin: EdgeInsets.only(
                      top: MediaQuery.of(context).size.height * .15),
                  alignment: Alignment.center,
                  child: CryptoAddressQR(
                    iconPath: selectedCoin?.iconPath,
                    address: selectedWallet?.address ?? "",
                    network: selectedNetwork?.name ?? "",
                  ),
                ),
              ],
            );
          },
        ),
        const SizedBox(width: 8),
        const ActionButton(text: "Send", icon: Icons.send),
        const SizedBox(width: 8),
        const ActionButton(text: "Swap", icon: Icons.swap_horiz),
        const SizedBox(width: 8),
        ActionButton(
          text: "More",
          icon: Icons.more_horiz,
          onPressed: () {
            ResponsiveDrawer.show<void>(
              context: context,
              title: "More Options",
              children: [
                if (isGnusBridgeEnabled)
                  SlidingDrawerButton(
                    onPressed: selectedCoin?.balance == 0
                        ? null
                        : () async {
                            Navigator.of(context).pop(); // Close drawer
                            await GoRouter.of(context)
                                .push('/bridge', extra: walletDetailsCubit);
                            walletDetailsCubit
                                .getCoins(); // Refresh after return
                          },
                    label: "Bridge Tokens",
                  ),
              ],
            );
          },
        ),
      ],
    );
  }

  /// **Details Section**
  Widget _buildActionSection(
    CoinGeckoMarketData? marketData,
    Coin? selectedCoin,
    Network? selectedNetwork,
    WalletDetailsCubit? walletDetailsCubit,
    context,
    Wallet? selectedWallet,
    bool? isGnusBridgeEnabled,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // **Market Data Info**
        MarketDataInfo(
          topSlot: CoinCardRow(
            iconPath: marketData?.imageUrl ?? "",
            balance: selectedCoin?.balance,
            name: marketData?.name ?? "unknown",
            symbol: marketData?.symbol ?? "unknown",
            marketData: marketData,
          ),
          marketData: marketData,
          address: selectedCoin?.address,
          network: selectedNetwork?.name,
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
}
