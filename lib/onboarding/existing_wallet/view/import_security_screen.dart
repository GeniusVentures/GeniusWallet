import 'package:flow_builder/flow_builder.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genius_wallet/app/utils/breakpoints.dart';
import 'package:genius_wallet/app/widgets/app_screen_with_header.dart';
import 'package:genius_wallet/app/widgets/desktop_body_container.dart';
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

    final formKey = GlobalKey<FormState>();

    return Scaffold(
      body: Stack(
        children: [
          BlocListener<ExistingWalletBloc, ExistingWalletState>(
            listener: (context, state) {
              if (state.importWalletStatus == ExistingWalletStatus.error) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'Failed to import wallet. Check your import settings and try again.',
                    ),
                  ),
                );
              } else if (state.importWalletStatus ==
                  ExistingWalletStatus.success) {
                context.flow<ExistingWalletState>().complete();
              }
            },
            child: DefaultTabController(
              length: 4,
              child: Form(
                key: formKey,
                child: AppScreenWithHeader(
                  title: 'Import $walletType Wallet',
                  subtitle: '',
                  bodyWidgets: [
                    Builder(builder: (context) {
                      if (GeniusBreakpoints.useDesktopLayout(context)) {
                        return _ImportSecurityViewDesktop(
                          walletNameController: walletNameController,
                          tabControllers: tabControllers,
                          formKey: formKey,
                          walletType: walletType,
                        );
                      }
                      return _ImportSecurityBody(
                        walletNameController: walletNameController,
                        tabControllers: tabControllers,
                      );
                    }),
                  ],
                  footer: Builder(builder: (context) {
                    if (GeniusBreakpoints.useDesktopLayout(context)) {
                      return const SizedBox();
                    }
                    return _ImportSecurityContinueButton(
                      formKey: formKey,
                      tabControllers: tabControllers,
                      walletNameController: walletNameController,
                      walletType: walletType,
                    );
                  }),
                ),
              ),
            ),
          ),
          BlocBuilder<ExistingWalletBloc, ExistingWalletState>(
            builder: (context, state) {
              if (state.importWalletStatus == ExistingWalletStatus.loading) {
                return Center(
                  child: AlertDialog(
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        CircularProgressIndicator(),
                        Text('Importing wallet'),
                      ],
                    ),
                  ),
                );
              }
              return Container();
            },
          ),
        ],
      ),
    );
  }
}

class _ImportSecurityViewDesktop extends StatelessWidget {
  const _ImportSecurityViewDesktop({
    Key? key,
    required this.walletNameController,
    required this.tabControllers,
    required this.formKey,
    required this.walletType,
  }) : super(key: key);

  final TextEditingController walletNameController;
  final Map<String, Map<String, TextEditingController>> tabControllers;
  final GlobalKey<FormState> formKey;
  final String walletType;

  @override
  Widget build(BuildContext context) {
    return DesktopBodyContainer(
      child: Column(
        children: [
          _ImportSecurityBody(
            walletNameController: walletNameController,
            tabControllers: tabControllers,
          ),
          _ImportSecurityContinueButton(
            formKey: formKey,
            tabControllers: tabControllers,
            walletNameController: walletNameController,
            walletType: walletType,
          )
        ],
      ),
    );
  }
}

class _ImportSecurityBody extends StatelessWidget {
  final TextEditingController walletNameController;
  final Map<String, Map<String, TextEditingController>> tabControllers;
  const _ImportSecurityBody({
    Key? key,
    required this.walletNameController,
    required this.tabControllers,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
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
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a wallet name';
                    }
                    return null;
                  },
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
                    controller: tabControllers['privatekey']!['pasteField']!,
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
    );
  }
}

class _ImportSecurityContinueButton extends StatelessWidget {
  const _ImportSecurityContinueButton({
    Key? key,
    required this.formKey,
    required this.tabControllers,
    required this.walletNameController,
    required this.walletType,
  }) : super(key: key);

  final GlobalKey<FormState> formKey;
  final Map<String, Map<String, TextEditingController>> tabControllers;
  final TextEditingController walletNameController;
  final String walletType;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 50,
      width: MediaQuery.of(context).size.width * 0.8,
      child: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          return MaterialButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
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
                        pasteFieldText: selectedEntry.value['pasteField']!.text,
                        password: selectedEntry.value['passwordField']?.text,
                      ),
                    );
              }
            },
            child: IsactiveTrue(
              constraints,
              ovrContinue: 'Import',
            ),
          );
        },
      ),
    );
  }
}
