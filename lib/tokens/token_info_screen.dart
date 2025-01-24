import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genius_api/models/coin.dart';
import 'package:genius_wallet/app/widgets/coins/view/coin_card_container.dart';
import 'package:genius_wallet/app/widgets/coins/view/coin_card_row.dart';
import 'package:genius_wallet/app/widgets/qr/crypto_address_qr.dart';
import 'package:genius_wallet/theme/genius_wallet_colors.g.dart';
import 'package:genius_wallet/wallets/cubit/wallet_details_cubit.dart';
import 'package:genius_wallet/widgets/components/action_button.dart';
import 'package:genius_wallet/widgets/components/sliding_drawer.dart';
import 'package:genius_wallet/widgets/components/sliding_drawer_button.dart';
import 'package:go_router/go_router.dart';

class TokenInfoScreen extends StatelessWidget {
  final double currentPrice;
  final double priceChange;
  final double priceChangePercent;
  final String chartPlaceholder;
  final String securityInfo;
  final bool? isGnusWalletConnected;
  final List<String> transactionHistory;

  const TokenInfoScreen({
    Key? key,
    required this.currentPrice,
    required this.priceChange,
    required this.priceChangePercent,
    required this.chartPlaceholder,
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
                          _buildPriceSection(),
                          const SizedBox(height: 16),
                          _buildChartPlaceholder(),
                          const SizedBox(height: 16),
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
                                title: Text(
                                    "Token Address: ${selectedCoin?.address}"),
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

  /// Price Section
  Widget _buildPriceSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          "\$${currentPrice.toStringAsFixed(2)}",
          style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: priceChange >= 0
                ? Colors.green.withOpacity(0.2)
                : Colors.red.withOpacity(0.2),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            "${priceChange >= 0 ? "+" : ""}\$${priceChange.toStringAsFixed(2)} (${priceChangePercent.toStringAsFixed(2)}%)",
            style: TextStyle(
              fontSize: 16,
              color: priceChange >= 0 ? Colors.green : Colors.red,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  /// Chart Placeholder
  Widget _buildChartPlaceholder() {
    return Container(
      height: 150,
      width: double.infinity,
      decoration: BoxDecoration(
        color: GeniusWalletColors.deepBlueCardColor,
        borderRadius: BorderRadius.circular(10),
      ),
      alignment: Alignment.center,
      child: const Text("Chart Placeholder"),
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
