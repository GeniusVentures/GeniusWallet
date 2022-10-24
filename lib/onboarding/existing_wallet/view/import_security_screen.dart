import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genius_wallet/app/widgets/app_screen_with_header.dart';
import 'package:genius_wallet/onboarding/existing_wallet/bloc/existing_wallet_bloc.dart';
import 'package:genius_wallet/onboarding/view/address_tab_view.dart';
import 'package:genius_wallet/onboarding/view/keystore_tab_view.dart';
import 'package:genius_wallet/onboarding/view/phrase_tab_view.dart';
import 'package:genius_wallet/onboarding/view/private_key_tab_view.dart';
import 'package:genius_wallet/widgets/components/continue_button/isactive_true.g.dart';
import 'package:genius_wallet/widgets/components/text_entry_field_widget.g.dart';
import 'package:genius_wallet/widgets/text_form_field_logic.g.dart';

class ImportSecurityScreen extends StatelessWidget {
  final String walletType;
  const ImportSecurityScreen({
    required this.walletType,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    /// This was done to have the same data structure, since `KeyStore` needs two controllers.
    /// TODO: Optimize this.
    final tabControllers = {
      'phrase': {
        'pasteField': TextEditingController(),
      },
      'keystore': {
        'pasteField': TextEditingController(),
        'passwordField': TextEditingController(),
      },
      'privatekey': {
        'pasteField': TextEditingController(),
      },
      'address': {
        'pasteField': TextEditingController(),
      },
    };

    final walletNameController =
        TextEditingController(text: '$walletType Wallet');

    return Scaffold(
      body: DefaultTabController(
        length: 4,
        child: AppScreenWithHeader(
          title: 'Import $walletType Wallet',
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
                  return TextEntryFieldWidget(
                    logic: TextFormFieldLogic(
                      context,
                      controller: walletNameController,
                    ),
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
              height: 400,
              child: TabBarView(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 25),
                    child: PhraseTabView(
                      controller: tabControllers['phrase']!['pasteField']!,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: KeystoreTabView(
                      passwordController:
                          tabControllers['keystore']!['passwordField']!,
                      pasteFieldController:
                          tabControllers['keystore']!['pasteField']!,
                    ),
                  ),
                  Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: PrivateKeyTabView(
                        controller:
                            tabControllers['privatekey']!['pasteField']!,
                      )),
                  Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: AddressTabView(
                      controller: tabControllers['address']!['pasteField']!,
                    ),
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
                return MaterialButton(
                  onPressed: () {
                    /// Get currently selected tab
                    final selectedIndex =
                        DefaultTabController.of(context)?.index ?? 0;

                    /// Get current entry to access [TextEditingControllers]
                    final selectedEntry =
                        tabControllers.entries.toList()[selectedIndex];

                    /// Send event with currently selected tab information
                    context.read<ExistingWalletBloc>().add(
                          WalletSecurityEntered(
                            walletName: walletNameController.text,
                            walletType: walletType,
                            securityType: selectedEntry.key,
                            pasteFieldText:
                                selectedEntry.value['pasteField']!.text,
                            password:
                                selectedEntry.value['passwordField']?.text,
                          ),
                        );
                  },
                  child: IsactiveTrue(
                    constraints,
                    ovrContinue: 'Import',
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
