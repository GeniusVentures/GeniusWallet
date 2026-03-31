import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:genius_wallet/components/app_screen_view.dart';
import 'package:genius_wallet/components/sgnus/sgnus_connection_widget.dart';
import 'package:genius_wallet/theme/genius_wallet_colors.dart';
import 'package:genius_wallet/wallets/view/genius_balance_display.dart';

class GeniusWalletDetailsScreen extends StatelessWidget {
  const GeniusWalletDetailsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const View();
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
    return Scaffold(
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 500),
          child: AppScreenView(
            body: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 18),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Flexible(
                        child: GeniusBalanceDisplay(
                          useMinions: useMinionIcon,
                          fontSize: 48,
                          fontColor: Colors.white,
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
                  const SizedBox(height: 16),
                  _buildToggle(),
                  const SizedBox(height: 24),
                  Align(
                    alignment: Alignment.center,
                    child: SizedBox(
                      width: 180,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: const [
                          SGNUSConnectionWidget(),
                          SizedBox(height: 8),
                          SGNUSConnectionStatusWidget(),
                        ],
                      ),
                    ),
                  ),
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
