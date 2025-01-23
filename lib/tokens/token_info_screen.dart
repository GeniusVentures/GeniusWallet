import 'package:flutter/material.dart';
import 'package:genius_api/models/network.dart';
import 'package:genius_api/models/wallet.dart';
import 'package:genius_wallet/app/utils/wallet_utils.dart';
import 'package:genius_wallet/app/widgets/button/copy_button.dart';
import 'package:genius_wallet/app/widgets/coins/view/coin_card_container.dart';
import 'package:genius_wallet/app/widgets/coins/view/coin_card_row.dart';
import 'package:genius_wallet/app/widgets/qr/crypto_address_qr.dart';
import 'package:genius_wallet/theme/genius_wallet_colors.g.dart';
import 'package:genius_wallet/widgets/components/action_button.dart';
import 'package:genius_wallet/widgets/components/sliding_drawer.dart';

class TokenInfoScreen extends StatelessWidget {
  final String tokenName;
  final double currentPrice;
  final double priceChange;
  final double priceChangePercent;
  final String chartPlaceholder;
  final double userBalance;
  final String tokenSymbol;
  final String tokenAddress;
  final String securityInfo;
  final String tokenIconPath;
  final String walletAddress;
  final String networkName;
  final List<String> transactionHistory;

  const TokenInfoScreen(
      {Key? key,
      required this.tokenName,
      required this.currentPrice,
      required this.priceChange,
      required this.priceChangePercent,
      required this.chartPlaceholder,
      required this.userBalance,
      required this.tokenSymbol,
      required this.tokenAddress,
      required this.securityInfo,
      required this.transactionHistory,
      required this.networkName,
      required this.tokenIconPath,
      required this.walletAddress})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final SlidingDrawerController qrCodeDrawerController =
        SlidingDrawerController();
    return Scaffold(
        appBar: AppBar(
          title: Text(tokenName, style: TextStyle(fontWeight: FontWeight.bold)),
          centerTitle: true,
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        body: Stack(children: [
          SingleChildScrollView(
            padding: EdgeInsets.all(16.0),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 500),
                child: Align(
                  alignment: Alignment.topCenter,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      _buildPriceSection(),
                      SizedBox(height: 16),
                      _buildChartPlaceholder(),
                      SizedBox(height: 16),
                      Row(
                        children: [
                          ActionButton(
                              text: "Receive",
                              icon: Icons.qr_code,
                              onPressed: () {
                                qrCodeDrawerController.openDrawer();
                              }),
                          const SizedBox(width: 8),
                          const ActionButton(text: "Send", icon: Icons.send),
                          const SizedBox(width: 8),
                          const ActionButton(
                              text: "Swap", icon: Icons.swap_horiz),
                          const SizedBox(width: 8),
                          ActionButton(
                            text: "More",
                            icon: Icons.more_horiz,
                            onPressed: () => _showMoreOptionsDrawer(context),
                          ),
                        ],
                      ),
                      SizedBox(height: 16),
                      _buildYourBalance(),
                      SizedBox(height: 16),
                      _buildInfoSection(),
                      SizedBox(height: 16),
                      _buildSecuritySection(),
                      SizedBox(height: 16),
                      _buildActivitySection(),
                    ],
                  ),
                ),
              ),
            ),
          ),
          SlidingDrawer(
              controller: qrCodeDrawerController,
              title: "Receive $tokenName",
              content: Container(
                  margin: EdgeInsets.only(
                      top: MediaQuery.of(context).size.height * .15),
                  alignment: Alignment.center,
                  child: Column(children: [
                    CryptoAddressQR(
                        iconPath: tokenIconPath,
                        address: walletAddress,
                        network: networkName),
                  ]))),
        ]));
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

  /// More Options Side Drawer
  void _showMoreOptionsDrawer(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: true, // Close when tapping outside
      builder: (context) => GestureDetector(
        onTap: () => Navigator.of(context).pop(), // Close on tap outside
        child: Material(
          color: Colors.black.withOpacity(0.5), // Backdrop
          child: Align(
            alignment: Alignment.centerRight,
            child: Container(
              width: MediaQuery.of(context).size.width * 0.6,
              color: GeniusWalletColors.deepBlueMenu,
              child: GestureDetector(
                onTap: () {}, // Prevent closing when tapping inside drawer
                child: MoreOptionsDrawer(),
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Your Balance Section
  Widget _buildYourBalance() {
    return ListTile(
        contentPadding: const EdgeInsets.all(0),
        title: const Text(
          "Your Balance",
          style: TextStyle(color: GeniusWalletColors.gray500),
        ),
        subtitle: CoinCardContainer(
          child: CoinCardRow(
            iconPath: tokenIconPath,
            balance: userBalance,
            name: tokenName,
            symbol: tokenSymbol,
          ),
        ));
  }

  /// Info Section
  Widget _buildInfoSection() {
    return ListTile(
      contentPadding: const EdgeInsets.all(0),
      title: const Text(
        "Info",
        style: TextStyle(color: GeniusWalletColors.gray500),
      ),
      subtitle: Card(
        margin: const EdgeInsets.all(0),
        color: GeniusWalletColors.deepBlueCardColor,
        elevation: 1,
        child: ListTile(title: Text("Token Address: $tokenAddress")),
      ),
    );
  }

  /// Security Section
  Widget _buildSecuritySection() {
    return ListTile(
      contentPadding: const EdgeInsets.all(0),
      title: const Text(
        "Security",
        style: TextStyle(color: GeniusWalletColors.gray500),
      ),
      subtitle: Card(
        margin: const EdgeInsets.all(0),
        color: GeniusWalletColors.deepBlueCardColor,
        elevation: 1,
        child: ListTile(title: Text(securityInfo)),
      ),
    );
  }

  /// Activity Section
  Widget _buildActivitySection() {
    return ListTile(
      contentPadding: const EdgeInsets.all(0),
      title: const Text(
        "Activity",
        style: TextStyle(color: GeniusWalletColors.gray500),
      ),
      subtitle: Card(
          margin: const EdgeInsets.all(0),
          color: GeniusWalletColors.deepBlueCardColor,
          elevation: 1,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const ListTile(title: Text("Activity")),
              ...transactionHistory.map((tx) => ListTile(title: Text(tx))),
            ],
          )),
    );
  }
}

/// Side Drawer for "More" Button
class MoreOptionsDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              IconButton(
                icon: const Icon(Icons.close, color: Colors.white),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
          const SizedBox(height: 16),
          ListTile(
            title: const Text("View on Explorer",
                style: TextStyle(color: Colors.white)),
            onTap: () {},
          ),
          ListTile(
            title: const Text("Token Details",
                style: TextStyle(color: Colors.white)),
            onTap: () {},
          ),
          ListTile(
            title: const Text("Add to Watchlist",
                style: TextStyle(color: Colors.white)),
            onTap: () {},
          ),
        ],
      ),
    );
  }
}
