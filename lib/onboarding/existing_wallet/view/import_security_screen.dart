import 'package:flow_builder/flow_builder.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genius_api/ffi/genius_api_ffi.dart';
import 'package:genius_api/types/security_type.dart';
import 'package:genius_wallet/app/utils/breakpoints.dart';
import 'package:genius_wallet/app/widgets/app_screen_with_header_desktop.dart';
import 'package:genius_wallet/app/widgets/app_screen_with_header_mobile.dart';
import 'package:genius_wallet/app/widgets/desktop_body_container.dart';
import 'package:genius_wallet/onboarding/existing_wallet/bloc/existing_wallet_bloc.dart';
import 'package:genius_wallet/onboarding/view/address_tab_view.dart';
import 'package:genius_wallet/onboarding/view/keystore_tab_view.dart';
import 'package:genius_wallet/onboarding/view/phrase_tab_view.dart';
import 'package:genius_wallet/onboarding/view/private_key_tab_view.dart';
import 'package:genius_wallet/theme/genius_wallet_colors.g.dart';
import 'package:genius_wallet/theme/genius_wallet_font_size.dart';
import 'package:genius_wallet/widgets/components/continue_button/isactive_true.g.dart';
import 'package:genius_wallet/widgets/components/text_entry_field_widget.g.dart';
import 'package:genius_wallet/widgets/text_form_field_logic.g.dart';

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
    /// This was done to have the same data structure, since `KeyStore` needs two controllers.
    /// TODO: Optimize this.
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
              // TODO add other methods of import .. change this to 4
              length: 2,
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
          width: 530,
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
          height: 20,
          width: MediaQuery.of(context).size.width * 0.9,
          child: const Text(
            'Name',
            style: TextStyle(fontSize: GeniusWalletFontSize.medium),
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 50,
          width: MediaQuery.of(context).size.width * 0.9,
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
          width: MediaQuery.of(context).size.width,
          height: 50,
          child: const TabBar(
            indicatorSize: TabBarIndicatorSize.label,
            indicatorColor: GeniusWalletColors.lightGreenPrimary,
            indicatorWeight: 2,
            indicatorPadding: EdgeInsets.symmetric(vertical: 8),
            labelColor: Colors.white,
            tabAlignment: TabAlignment.start,
            labelPadding: EdgeInsets.only(left: 22, right: 20),
            isScrollable: true,
            tabs: [
              Tab(text: 'Phrase'),
              Tab(text: 'Private Key'),
              // TODO: add support for other import methods
              // Tab(text: 'Keystore'),
              // Tab(text: 'Address'),
            ],
          ),
        ),
        SizedBox(
          width: MediaQuery.of(context).size.width * 0.9,
          height: 350,
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
              // TODO: add other import types
              // Padding(
              //   padding: const EdgeInsets.only(top: 10),
              //   child: KeystoreTabView(
              //     passwordController:
              //         tabControllers['keystore']!['passwordField']!,
              //     pasteFieldController:
              //         tabControllers['keystore']!['pasteField']!,
              //   ),
              // ),
              // Padding(
              //   padding: const EdgeInsets.only(top: 10),
              //   child: AddressTabView(
              //     controller: tabControllers['address']!['pasteField']!,
              //   ),
              // ),
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
                    DefaultTabController.of(context)?.index ?? 0;

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
