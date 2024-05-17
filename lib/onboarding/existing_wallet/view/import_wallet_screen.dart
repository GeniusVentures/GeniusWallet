import 'package:flutter/material.dart';
import 'package:genius_wallet/app/utils/breakpoints.dart';
import 'package:genius_wallet/app/widgets/app_screen_with_header_desktop.dart';
import 'package:genius_wallet/app/widgets/app_screen_with_header_mobile.dart';
import 'package:genius_wallet/app/widgets/desktop_body_container.dart';
import 'package:genius_wallet/onboarding/widgets/supported_existing_wallets.dart';

class ImportWalletScreen extends StatelessWidget {
  static const title = 'Import Wallet';
  static const subtitle = 'Select the wallet that you would like to import';
  const ImportWalletScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(builder: (context, constraints) {
        if (GeniusBreakpoints.useDesktopLayout(context)) {
          return const _ImportWalletViewDesktop(
              title: title, subtitle: subtitle);
        }
        return const _ImportWalletViewMobile(title: title, subtitle: subtitle);
      }),
    );
  }
}

class _ImportWalletViewDesktop extends StatelessWidget {
  final String title;
  final String subtitle;
  const _ImportWalletViewDesktop({
    Key? key,
    required this.title,
    required this.subtitle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppScreenWithHeaderDesktop(
      title: '',
      subtitle: '',
      body: Center(
        child: DesktopBodyContainer(
          title: title,
          subText: subtitle,
          child: const SupportedExistingWallets(),
        ),
      ),
    );
  }
}

class _ImportWalletViewMobile extends StatelessWidget {
  final String title;
  final String subtitle;
  const _ImportWalletViewMobile({
    required this.title,
    required this.subtitle,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppScreenWithHeaderMobile(
      title: title,
      subtitle: subtitle,
      body: Container(
        padding: const EdgeInsets.only(top: 40),
        constraints: BoxConstraints(
          minHeight: 100,
          maxHeight: MediaQuery.of(context).size.height * 0.6,
          minWidth: MediaQuery.of(context).size.width * 0.8,
          maxWidth: MediaQuery.of(context).size.width * 0.8,
        ),
        child: const SupportedExistingWallets(),
      ),
    );
  }
}
