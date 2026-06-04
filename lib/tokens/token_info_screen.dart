import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genius_api/models/coin.dart';
import 'package:genius_api/models/network.dart';
import 'package:genius_api/models/wallet.dart';
import 'package:genius_wallet/components/coins/view/coin_card_row.dart';
import 'package:genius_wallet/components/qr/crypto_address_qr.dart';
import 'package:genius_wallet/chart/crypto_live_chart.dart';
import 'package:genius_wallet/hive/models/coin_gecko_market_data.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:genius_wallet/components/scaffold/scaffold_helper.dart';
import 'package:genius_wallet/utils/breakpoints.dart';
import 'package:genius_wallet/wallets/cubit/wallet_details_cubit.dart';
import 'package:genius_wallet/components/action_button.dart';
import 'package:genius_wallet/components/bottom_drawer/responsive_drawer.dart';
import 'package:genius_wallet/components/sliding_drawer_button.dart';
import 'package:go_router/go_router.dart';

class TokenInfoScreen extends StatelessWidget {
  final bool? isGnusWalletConnected;
  final CoinGeckoMarketData? marketData;
  final WalletDetailsCubit walletDetailsCubit;

  const TokenInfoScreen({
    super.key,
    required this.walletDetailsCubit,
    this.marketData,
    this.isGnusWalletConnected,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: walletDetailsCubit,
      child: BlocBuilder<WalletDetailsCubit, WalletDetailsState>(
        builder: (context, state) {
          return _buildScreenWithCubit(context, state);
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
      appBar: AppBar(),
      body: LayoutBuilder(
        builder: (context, constraints) {
          bool isDesktop = constraints.maxWidth > GeniusBreakpoints.large;
          return SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            primary: true,
            child: isDesktop
                ? Row(
                    spacing: 20,
                    children: [
                      if (marketData != null)
                        Expanded(
                          flex: 2,
                          child: SizedBox(
                            height: constraints.maxHeight - 40,
                            child: _buildGraphSection(
                                marketData!,
                                _buildStaticActions(
                                    selectedCoin,
                                    context,
                                    selectedWallet,
                                    selectedNetwork,
                                    isGnusBridgeEnabled,
                                    walletDetailsCubit)),
                          ),
                        ),
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
                    spacing: 20,
                    children: [
                      if (marketData != null)
                        _buildGraphSection(marketData!, null),
                      _buildStaticActions(
                          selectedCoin,
                          context,
                          selectedWallet,
                          selectedNetwork,
                          isGnusBridgeEnabled,
                          walletDetailsCubit),
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
          );
        },
      ),
    );
  }

  Widget _buildGraphSection(CoinGeckoMarketData marketData, Widget? child) {
    return CryptoLiveChart(
      coinGeckoCoinId: marketData.id,
      tokenSymbol: marketData.symbol,
      child: child,
    );
  }

  Widget _buildStaticActions(selectedCoin, context, selectedWallet,
      selectedNetwork, bool isGnusBridgeEnabled, walletDetailsCubit) {
    return SizedBox(
      width: 400,
      child: Row(
        spacing: 8,
        children: [
          ActionButton(
            text: "Receive",
            icon: Icons.qr_code,
            onPressed: () {
              ResponsiveDrawer.show<void>(
                context: context,
                title: "Receive ${selectedCoin?.name}",
                child: Align(
                  alignment: Alignment.topCenter,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: SizedBox(
                      width: GeniusBreakpoints.small * 0.5,
                      child: CryptoAddressQR(
                        iconPath: selectedCoin?.iconPath,
                        address: selectedWallet?.address ?? "",
                        network: selectedNetwork?.name ?? "",
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
          const ActionButton(text: "Send", icon: Icons.send),
          const ActionButton(text: "Swap", icon: Icons.swap_horiz),
          ActionButton(
              text: "More",
              icon: Icons.more_horiz,
              onPressed: isGnusBridgeEnabled
                  ? () {
                      ResponsiveDrawer.show<void>(
                          context: context,
                          title: "More Options",
                          child: SlidingDrawerButton(
                            onPressed: selectedCoin?.balance == 0
                                ? null
                                : () async {
                                    Navigator.of(context).pop();
                                    await GoRouter.of(context).push('/bridge',
                                        extra: walletDetailsCubit);
                                    walletDetailsCubit.getCoins();
                                  },
                            label: "Bridge Tokens",
                          ));
                    }
                  : null),
        ],
      ),
    );
  }

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
      spacing: 16,
      children: [
        _MarketDataInfo(
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
        _ConvertSection(tokenPrice: marketData?.currentPrice ?? 0.0),
      ],
    );
  }
}

class _ConvertSection extends StatefulWidget {
  final double tokenPrice;

  const _ConvertSection({
    required this.tokenPrice,
  });

  @override
  State<_ConvertSection> createState() => _ConvertSectionState();
}

class _ConvertSectionState extends State<_ConvertSection> {
  late TextEditingController _tokenAmountController;
  late TextEditingController _tokenPriceController;

  double _totalValue = 0;

  @override
  void initState() {
    super.initState();
    _tokenPriceController = TextEditingController(
      text: widget.tokenPrice.toString(),
    );
    _tokenAmountController = TextEditingController(
      text: "1",
    );
    _calculateTotalValue();
  }

  void _calculateTotalValue() {
    final double tokenAmount =
        double.tryParse(_tokenAmountController.text) ?? 0;
    final double tokenPrice = double.tryParse(_tokenPriceController.text) ?? 0;

    setState(() {
      _totalValue = tokenAmount * tokenPrice;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 8,
        children: [
          Text(
            "Convert",
            style: Theme.of(context).textTheme.titleMedium,
          ),
          Card(
              child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              spacing: 16,
              children: [
                TextField(
                  controller: _tokenPriceController,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(
                    labelText: "Token Price",
                  ),
                  onChanged: (_) => _calculateTotalValue(),
                ),
                TextField(
                  controller: _tokenAmountController,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(
                    labelText: "Token Amount",
                  ),
                  onChanged: (_) => _calculateTotalValue(),
                ),
                Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      "Total: ${NumberFormat.currency(
                        locale: "en_US",
                        symbol: "\$",
                      ).format(_totalValue)}",
                      style: Theme.of(context).textTheme.bodyLarge,
                    )),
              ],
            ),
          ))
        ]);
  }
}

class _MarketDataInfo extends StatelessWidget {
  final CoinGeckoMarketData? marketData;
  final String? address;
  final String? network;
  final Widget? topSlot;

  const _MarketDataInfo({
    this.marketData,
    this.network,
    this.address,
    this.topSlot,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final infoTiles = <Widget>[
      if (network != null)
        ListTile(
          dense: true,
          leading: Icon(
            Icons.bubble_chart,
            color: cs.primary,
          ),
          title: const Text("Network"),
          trailing: Text(
            network!,
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ),
      if (address != null)
        ListTile(
          dense: true,
          leading: Icon(Icons.link, color: cs.primary),
          title: const Text("Address"),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            spacing: 8,
            children: [
              IconButton(
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: address!));
                  showAppSnackBar(context, 'Address copied to clipboard');
                },
                tooltip: "Copy address",
                icon: Icon(
                  Icons.copy,
                  size: 18,
                  color: cs.primary,
                ),
              ),
              Text(
                address!.length > 12
                    ? "${address!.substring(0, 6)}...${address!.substring(address!.length - 6)}"
                    : address!,
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ],
          ),
        ),
      ListTile(
        dense: true,
        leading: Icon(Icons.pie_chart, color: Colors.amber[300]),
        title: const Text("Market Cap"),
        trailing: Text(
          _formatCompactCurrency(marketData?.marketCap),
          style: Theme.of(context).textTheme.titleMedium,
        ),
      ),
      ListTile(
        dense: true,
        leading: Icon(Icons.sync, color: Colors.lightBlue[300]),
        title: const Text("Circulating Supply"),
        trailing: Text(
          _formatCompactDecimal(marketData?.circulatingSupply),
          style: Theme.of(context).textTheme.titleMedium,
        ),
      ),
      ListTile(
        dense: true,
        leading: Icon(Icons.storage, color: Colors.orange[300]),
        title: const Text("Total Supply"),
        trailing: Text(
          _formatCompactDecimal(marketData?.totalSupply),
          style: Theme.of(context).textTheme.titleMedium,
        ),
      ),
      ListTile(
        dense: true,
        leading: Icon(Icons.bar_chart, color: Colors.red[300]),
        title: const Text("Volume"),
        trailing: Text(
          _formatCompactCurrency(marketData?.totalVolume),
          style: Theme.of(context).textTheme.titleMedium,
        ),
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 8,
      children: [
        Text(
          "Info",
          style: Theme.of(context).textTheme.titleMedium,
        ),
        Card(
          color: cs.surface,
          margin: EdgeInsets.zero,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ListTile(
                  contentPadding: EdgeInsets.only(bottom: 8, left: 8),
                  leading: CircleAvatar(
                    radius: 24,
                    backgroundColor: Colors.white,
                    backgroundImage: marketData?.imageUrl != null
                        ? NetworkImage(marketData!.imageUrl)
                        : null,
                    child: marketData?.imageUrl == null
                        ? Icon(Icons.token,
                            color: cs.onSurfaceVariant, size: 32)
                        : null,
                  ),
                  title: Text(
                    marketData?.name ?? "Unknown Token",
                    maxLines: 2,
                  ),
                  subtitle: Text(
                    (marketData?.symbol ?? "").toUpperCase(),
                    style: TextStyle(
                      color: cs.onSurfaceVariant,
                    ),
                  ),
                ),
                Column(
                  children: [
                    for (int i = 0; i < infoTiles.length; i++) ...[
                      Divider(height: 1),
                      infoTiles[i],
                    ]
                  ],
                ),
              ],
            ),
          ),
        )
      ],
    );
  }

  String _formatCompactCurrency(double? number) {
    if (number == 0 || number == null) return "N/A";
    return NumberFormat.compactSimpleCurrency().format(number);
  }

  String _formatCompactDecimal(double? number) {
    if (number == 0 || number == null) return "N/A";
    return NumberFormat.compact().format(number);
  }
}
