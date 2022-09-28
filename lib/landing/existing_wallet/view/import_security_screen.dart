import 'package:flutter/material.dart';
import 'package:genius_wallet/app/widgets/app_screen_with_header.dart';
import 'package:genius_wallet/landing/view/address_tab_view.dart';
import 'package:genius_wallet/landing/view/keystore_tab_view.dart';
import 'package:genius_wallet/landing/view/phrase_tab_view.dart';
import 'package:genius_wallet/landing/view/private_key_tab_view.dart';
import 'package:genius_wallet/widgets/components/continue_button/isactive_true.g.dart';
import 'package:genius_wallet/widgets/components/text_entry_field.g.dart';

class ImportSecurityScreen extends StatelessWidget {
  final String walletName;
  const ImportSecurityScreen({
    required this.walletName,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: DefaultTabController(
        length: 4,
        child: AppScreenWithHeader(
          title: 'Import $walletName Wallet',
          subtitle: '',
          bodyWidgets: [
            SizedBox(
              height: 20,
              width: MediaQuery.of(context).size.width * 0.8,
              child: const Text('Name'),
            ),
            const SizedBox(height: 10),
            SizedBox(
              height: 50,
              width: MediaQuery.of(context).size.width * 0.8,
              child: LayoutBuilder(
                builder: (BuildContext context, BoxConstraints constraints) {
                  return TextEntryField(
                    constraints,
                    ovrTextEntryHinthinttext: walletName,
                  );
                },
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.8,
              height: 50,
              child: AppBar(
                backgroundColor: Colors.transparent,
                elevation: 0,
                bottom: const TabBar(
                  indicatorColor: Colors.white,
                  tabs: [
                    Tab(text: 'Phrase'),
                    Tab(text: 'Keystore'),
                    Tab(text: 'Private Key'),
                    Tab(text: 'Address'),
                  ],
                ),
              ),
            ),
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.8,
              height: 500,
              child: const TabBarView(
                children: [
                  Padding(
                    padding: EdgeInsets.only(top: 25),
                    child: PhraseTabView(),
                  ),
                  Padding(
                    padding: EdgeInsets.only(top: 10),
                    child: KeystoreTabView(),
                  ),
                  Padding(
                    padding: EdgeInsets.only(top: 10),
                    child: PrivateKeyTabView(),
                  ),
                  Padding(
                    padding: EdgeInsets.only(top: 10),
                    child: AddressTabView(),
                  ),
                ],
              ),
            ),
          ],
          footer: SizedBox(
            height: 50,
            width: MediaQuery.of(context).size.width * 0.8,
            child: LayoutBuilder(
              builder: (BuildContext context, BoxConstraints constraints) {
                return IsactiveTrue(
                  constraints,
                  ovrContinue: 'Import',
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
