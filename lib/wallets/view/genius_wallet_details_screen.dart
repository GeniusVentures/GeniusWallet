import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genius_api/genius_api.dart';
import 'package:genius_wallet/app/widgets/app_screen_view.dart';
import 'package:genius_wallet/dashboard/home/widgets/containers.dart';
import 'package:genius_wallet/dashboard/home/widgets/sgnus_transactions_screen.dart';
import 'package:genius_wallet/dashboard/home/widgets/transactions_slim_view.dart';
import 'package:genius_wallet/theme/genius_wallet_colors.g.dart';
import 'package:genius_wallet/wallets/cubit/genius_wallet_details_cubit.dart';
import 'package:genius_wallet/wallets/view/genius_balance_display.dart';

class GeniusWalletDetailsScreen extends StatelessWidget {
  const GeniusWalletDetailsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<GeniusWalletDetailsCubit, GeniusWalletDetailsState>(
      builder: (context, state) {
        return const View();
      },
    );
  }
}

class View extends StatefulWidget {
  const View({Key? key}) : super(key: key);

  @override
  State<View> createState() => _ViewState();
}

class _ViewState extends State<View> {
  bool useMinionIcon = true;

  @override
  Widget build(BuildContext context) {
    final geniusApi = context.read<GeniusApi>();
    final isDesktop = MediaQuery.of(context).size.width >= 900;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Super Genius Wallet"),
        centerTitle: false,
        actions: isDesktop
            ? null
            : [
                _buildToggle(),
                const SizedBox(width: 8),
              ],
      ),
      body: isDesktop
          ? Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  // Left Side: Balance & Toggle
                  Padding(
                      padding: const EdgeInsets.all(8),
                      child: Container(
                        width: 300,
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: GeniusWalletColors.deepBlueCardColor,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const Text(
                              "Wallet Balance",
                              style: TextStyle(
                                fontSize: 20,
                                color: GeniusWalletColors.gray500,
                              ),
                            ),
                            const SizedBox(height: 16),
                            GeniusBalanceDisplay(
                                useMinions: useMinionIcon,
                                fontSize: isDesktop ? 24 : 48,
                                isShowSuffix: isDesktop ? false : true),
                            const SizedBox(height: 24),
                            _buildToggle(),
                          ],
                        ),
                      )),
                  // Right Side: Transactions
                  const Expanded(
                    child: DashboardScrollContainer(
                      child: SgnusTransactionsScreen(),
                    ),
                  ),
                ],
              ),
            )
          : Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 500),
                child: AppScreenView(
                  body: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 18),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.baseline,
                          textBaseline: TextBaseline.alphabetic,
                          children: [
                            Flexible(
                              child: AutoSizeText(
                                geniusApi.getMinionsBalance(),
                                style: const TextStyle(
                                  fontSize: 48,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                                maxLines: 1,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              useMinionIcon ? "Minions" : "GNUS",
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: GeniusWalletColors.gray500,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                            height: MediaQuery.of(context).size.height - 220,
                            child: LayoutBuilder(
                              builder: (BuildContext context,
                                  BoxConstraints constraints) {
                                return const DashboardScrollContainer(
                                    child: SgnusTransactionsScreen());
                              },
                            )),
                      ],
                    ),
                  ),
                ),
              ),
            ),
    );
  }

  Widget _buildToggle() {
    return ToggleButtons(
      isSelected: [!useMinionIcon, useMinionIcon],
      onPressed: (index) {
        setState(() {
          useMinionIcon = index == 1;
        });
      },
      borderRadius: BorderRadius.circular(12),
      borderColor: Colors.white24,
      selectedBorderColor: Colors.white,
      fillColor: Colors.white10,
      selectedColor: Colors.white,
      constraints: const BoxConstraints(minHeight: 40, minWidth: 110),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              "assets/images/crypto/gnus.png",
              height: 28,
              width: 28,
            ),
            const SizedBox(width: 8),
            const Text("GNUS"),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              "assets/images/crypto/minion.png",
              height: 28,
              width: 28,
            ),
            const SizedBox(width: 8),
            const Text("Minions"),
          ],
        ),
      ],
    );
  }
}
