import 'package:flow_builder/flow_builder.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genius_api/types/security_type.dart';
import 'package:genius_wallet/utils/breakpoints.dart';
import 'package:genius_wallet/components/app_screen_with_header_desktop.dart';
import 'package:genius_wallet/components/app_screen_with_header_mobile.dart';
import 'package:genius_wallet/components/desktop_body_container.dart';
import 'package:genius_wallet/onboarding/existing_wallet/bloc/existing_wallet_bloc.dart';
import 'package:genius_wallet/onboarding/view/address_tab_view.dart';
import 'package:genius_wallet/onboarding/view/keystore_tab_view.dart';
import 'package:genius_wallet/onboarding/view/phrase_tab_view.dart';
import 'package:genius_wallet/onboarding/view/private_key_tab_view.dart';
import 'package:genius_wallet/theme/genius_wallet_font_size.dart';
import 'package:genius_wallet/components/continue_button/isactive_true.g.dart';
import 'package:genius_wallet/components/text_entry_field_widget.g.dart';
import 'package:genius_wallet/components/text_form_field_logic.g.dart';

class ImportSecurityScreen extends StatelessWidget {
  final String walletType;
  final int coinType;
  const ImportSecurityScreen({
    required this.walletType,
    required this.coinType,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final tabControllers = {
      'phrase': {
        'pasteField': TextEditingController(),
      },
      'privatekey': {
        'pasteField': TextEditingController(),
      },
      'keystore': {
        'pasteField': TextEditingController(),
        'passwordField': TextEditingController(),
      },
      'address': {
        'pasteField': TextEditingController(),
      },
    };

    final walletNameController = TextEditingController();

    final formKey = GlobalKey<FormState>();

    return Scaffold(
      body: Stack(
        children: [
          BlocListener<ExistingWalletBloc, ExistingWalletState>(
            listener: (context, state) async {
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
              length: tabControllers.length,
              child: Form(
                key: formKey,
                child: LayoutBuilder(builder: (context, constraints) {
                  final title = 'Import $walletType Wallet';
                  const subtitle = '';
                  if (GeniusBreakpoints.useDesktopLayout(context)) {
                    return _ImportSecurityViewDesktop(
                        title: title,
                        subtitle: subtitle,
                        walletNameController: walletNameController,
                        tabControllers: tabControllers,
                        formKey: formKey,
                        walletType: walletType,
                        coinType: coinType);
                  }
                  return _ImportSecurityViewMobile(
                      title: title,
                      subtitle: subtitle,
                      walletNameController: walletNameController,
                      tabControllers: tabControllers,
                      formKey: formKey,
                      walletType: walletType,
                      coinType: coinType);
                }),
              ),
            ),
          ),
          BlocBuilder<ExistingWalletBloc, ExistingWalletState>(
            builder: (context, state) {
              if (state.importWalletStatus == ExistingWalletStatus.loading) {
                return const Center(
                  child: AlertDialog(
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
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
  final String title;
  final String subtitle;
  final TextEditingController walletNameController;
  final Map<String, Map<String, TextEditingController>> tabControllers;
  final GlobalKey<FormState> formKey;
  final String walletType;
  final int coinType;

  const _ImportSecurityViewDesktop(
      {Key? key,
      required this.title,
      required this.subtitle,
      required this.walletNameController,
      required this.tabControllers,
      required this.formKey,
      required this.walletType,
      required this.coinType})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppScreenWithHeaderDesktop(
      title: '',
      subtitle: '',
      body: Center(
        child: DesktopBodyContainer(
          width: 600,
          title: title,
          subText: subtitle,
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
                  coinType: coinType)
            ],
          ),
        ),
      ),
    );
  }
}

class _ImportSecurityViewMobile extends StatelessWidget {
  final String title;
  final String subtitle;
  final TextEditingController walletNameController;
  final Map<String, Map<String, TextEditingController>> tabControllers;
  final GlobalKey<FormState> formKey;
  final String walletType;
  final int coinType;

  const _ImportSecurityViewMobile(
      {Key? key,
      required this.title,
      required this.subtitle,
      required this.walletNameController,
      required this.tabControllers,
      required this.formKey,
      required this.walletType,
      required this.coinType})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppScreenWithHeaderMobile(
      title: title,
      subtitle: subtitle,
      body: _ImportSecurityBody(
        walletNameController: walletNameController,
        tabControllers: tabControllers,
      ),
      footer: _ImportSecurityContinueButton(
          formKey: formKey,
          tabControllers: tabControllers,
          walletNameController: walletNameController,
          walletType: walletType,
          coinType: coinType),
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
          width: MediaQuery.of(context).size.width * 0.9,
          child: const FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              'Name',
              style: TextStyle(
                fontSize: GeniusWalletFontSize.medium,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 70,
          width: MediaQuery.of(context).size.width * 0.9,
          child: LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
              return TextEntryFieldWidget(
                logic: TextFormFieldLogic(
                  hintText: 'Enter wallet name',
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
        const SizedBox(
          child: TabBar(
            tabAlignment: TabAlignment.center,
            isScrollable: true,
            tabs: [
              Tab(text: 'Phrase'),
              Tab(text: 'Private Key'),
              Tab(text: 'Keystore'),
              Tab(text: 'Address'),
            ],
          ),
        ),
        const SizedBox(height: 20),
        SizedBox(
          width: MediaQuery.of(context).size.width * 0.9,
          height: 400,
          child: TabBarView(
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: PhraseTabView(
                  controller: tabControllers['phrase']!['pasteField']!,
                ),
              ),
              Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: PrivateKeyTabView(
                    controller: tabControllers['privatekey']!['pasteField']!,
                  )),
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
  final GlobalKey<FormState> formKey;
  final Map<String, Map<String, TextEditingController>> tabControllers;
  final TextEditingController walletNameController;
  final String walletType;
  final int coinType;

  const _ImportSecurityContinueButton(
      {Key? key,
      required this.formKey,
      required this.tabControllers,
      required this.walletNameController,
      required this.walletType,
      required this.coinType})
      : super(key: key);

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
                    DefaultTabController.of(context).index ?? 0;

                /// Get current entry to access [TextEditingControllers]
                final selectedEntry =
                    tabControllers.entries.toList()[selectedIndex];

                /// Send event with currently selected tab information
                context.read<ExistingWalletBloc>().add(
                      WalletSecurityEntered(
                        coinType: coinType,
                        walletName: walletNameController.text,
                        walletType: walletType,
                        securityType: getSecurityTypeFromTab(selectedEntry.key),
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
