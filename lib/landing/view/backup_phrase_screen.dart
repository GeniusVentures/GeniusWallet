import 'package:flutter/material.dart';
import 'package:genius_wallet/app/widgets/app_screen_view.dart';
import 'package:genius_wallet/widgets/components/registration_header.g.dart';
import 'package:genius_wallet/widgets/components/wallet_agreement.g.dart';
import 'package:genius_wallet/widgets/mobile/wallet_address.g.dart';

import '../../widgets/components/continue_button/isactive_false.g.dart';

class BackupPhraseScreen extends StatelessWidget {
  const BackupPhraseScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AppScreenView(
        body: Column(
          children: [
            SizedBox(
              width: MediaQuery.of(context).size.width,
              height: 190,
              child: LayoutBuilder(builder: (context, constraints) {
                return RegistrationHeader(constraints);
              }),
            ),
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.2,
            ),
            Image.asset(
              'assets/images/shield_icon.png',
              package: 'genius_wallet',
            ),
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.2,
            ),
            SizedBox(
              height: 30,
              width: MediaQuery.of(context).size.width * 0.8,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return WalletAgreement(constraints);
                },
              ),
            ),
          ],
        ),
        footer: SizedBox(
          width: MediaQuery.of(context).size.width * 0.8,
          height: 46,
          child: LayoutBuilder(
            builder: (context, constraints) {
              //TODO: Make this interactive with state
              return IsactiveFalse(constraints);
            },
          ),
        ),
      ),
    );
  }
}
