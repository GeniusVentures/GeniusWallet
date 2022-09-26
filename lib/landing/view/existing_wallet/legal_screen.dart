import 'package:flutter/material.dart';
import 'package:genius_wallet/app/widgets/app_screen_with_header.dart';
import 'package:genius_wallet/widgets/components/continue_button/isactive_false.g.dart';
import 'package:genius_wallet/widgets/components/wallet_agreement.g.dart';
import 'package:genius_wallet/widgets/components/wallet_button/type_existing.g.dart';

class LegalScreen extends StatelessWidget {
  const LegalScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AppScreenWithHeader(
        title: 'Legal',
        subtitle:
            'Please review the Privacy Policy and Terms of Service of the Cryptonix wallet before processing',
        bodyWidgets: [
          ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: 50,
              minWidth: MediaQuery.of(context).size.width * 0.8,
              maxHeight: MediaQuery.of(context).size.width * 0.6,
              maxWidth: MediaQuery.of(context).size.width * 0.8,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  height: 50,
                  width: MediaQuery.of(context).size.width * 0.8,
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      return TypeExisting(
                        constraints,
                        ovrIalreadyhaveawallet: 'Privacy Policy',
                      );
                    },
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  height: 50,
                  width: MediaQuery.of(context).size.width * 0.8,
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      return TypeExisting(
                        constraints,
                        ovrIalreadyhaveawallet: 'Terms of Service',
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
        footer: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              height: 30,
              width: MediaQuery.of(context).size.width * 0.8,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return WalletAgreement(constraints);
                },
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.8,
              height: 50,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return IsactiveFalse(constraints);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
