import 'package:flutter/material.dart';
import 'package:genius_wallet/theme/genius_wallet_colors.g.dart';
import 'package:go_router/go_router.dart';

class HamburgerMenu extends StatelessWidget {
  const HamburgerMenu({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(
        textTheme: Theme.of(context).textTheme.copyWith(
              bodyLarge: const TextStyle(
                fontSize: 16,
                color: Colors.white,
              ),
            ),
      ),
      child: Drawer(
        backgroundColor: GeniusWalletColors.blue500,
        child: ListView(
          children: [
            const SizedBox(
              height: 40,
            ),
            ListTile(
              title: const Text(
                'Markets',
                textAlign: TextAlign.end,
              ),
              trailing: Image.asset('assets/images/markets_icon.png'),
              onTap: () {
                context.go('/markets');
              },
            ),
            const OpaqueWhiteDivider(),
            ListTile(
              title: const Text(
                'Crypto News',
                textAlign: TextAlign.end,
              ),
              trailing: Image.asset('assets/images/crypto_news_icon.png'),
              onTap: () {
                context.go('/crypto_news');
              },
            ),
            const OpaqueWhiteDivider(),
            ListTile(
              title: const Text(
                'Blockchain Events',
                textAlign: TextAlign.end,
              ),
              trailing: Image.asset('assets/images/calendar_icon.png'),
              onTap: () {
                context.go('/events');
              },
            ),
            const OpaqueWhiteDivider(),
            ListTile(
              title: const Text(
                'Calculator',
                textAlign: TextAlign.end,
              ),
              trailing: Image.asset('assets/images/calculator_icon.png'),
              onTap: () {
                context.go('/calculator');
              },
            ),
            const OpaqueWhiteDivider(),
          ],
        ),
      ),
    );
  }
}

class OpaqueWhiteDivider extends StatelessWidget {
  const OpaqueWhiteDivider({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Divider(color: Colors.white.withOpacity(0.2));
  }
}
