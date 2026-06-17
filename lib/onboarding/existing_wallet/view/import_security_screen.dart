import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genius_api/ffi/trust_wallet_api_ffi.dart';
import 'package:genius_api/types/security_type.dart';
import 'package:genius_wallet/components/loading.dart';
import 'package:genius_wallet/onboarding/widgets/paste_field.dart';
import 'package:genius_wallet/utils/breakpoints.dart';
import 'package:genius_wallet/onboarding/existing_wallet/bloc/existing_wallet_bloc.dart';

class ImportSecurityScreen extends StatelessWidget {
  final String walletType;
  final TWCoinType coinType;
  const ImportSecurityScreen({
    required this.walletType,
    required this.coinType,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final tabControllers = {
      'phrase': {'pasteField': TextEditingController()},
      'privatekey': {'pasteField': TextEditingController()},
      'keystore': {
        'pasteField': TextEditingController(),
        'passwordField': TextEditingController(),
      },
      'address': {'pasteField': TextEditingController()},
    };

    final walletNameController = TextEditingController();

    final formKey = GlobalKey<FormState>();

    return Stack(
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
            }
          },
          child: DefaultTabController(
            length: tabControllers.length,
            child: Form(
              key: formKey,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return Center(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(maxWidth: GeniusBreakpoints.small * 0.8),
                      child: Column(
                        spacing: 24.0,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Import $walletType Wallet',
                            style: Theme.of(context).textTheme.headlineLarge,
                          ),
                          TextFormField(
                            decoration: InputDecoration(
                              hintText: "Enter wallet name",
                              label: Text("Name"),
                            ),
                            controller: walletNameController,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter a wallet name';
                              }
                              return null;
                            },
                          ),
                          TabBar(
                            tabAlignment: TabAlignment.center,
                            isScrollable: true,
                            tabs: [
                              Tab(text: 'Phrase'),
                              Tab(text: 'Private Key'),
                              Tab(text: 'Keystore'),
                              Tab(text: 'Address'),
                            ],
                          ),
                          SizedBox(
                            height: 260,
                            child: TabBarView(
                              children: [
                                PasteField(
                                  hintText: 'Wallet Mnemonic Phrase',
                                  subtitle:
                                      'Typically 12 (sometimes 24) words separated by single spaces.',
                                  controller:
                                      tabControllers['phrase']!['pasteField']!,
                                ),
                                PasteField(
                                  hintText: "Wallet Private Key",
                                  controller:
                                      tabControllers['privatekey']!['pasteField']!,
                                  subtitle:
                                      'Typically 64 alphanumeric characters.',
                                ),
                                KeystoreTabView(
                                  passwordController:
                                      tabControllers['keystore']!['passwordField']!,
                                  pasteFieldController:
                                      tabControllers['keystore']!['pasteField']!,
                                ),
                                PasteField(
                                  height: 150,
                                  hintText: 'Wallet Address',
                                  controller:
                                      tabControllers['address']!['pasteField']!,
                                  subtitle:
                                      'You can “watch” any public address without divulging your private key. This let’s you view balances and transactions, but not send transactions.',
                                ),
                              ],
                            ),
                          ),
                          FilledButton(
                            onPressed: () {
                              if (!formKey.currentState!.validate()) {
                                return;
                              }

                              final selectedIndex = DefaultTabController.of(
                                context,
                              ).index;

                              final selectedEntry = tabControllers.entries
                                  .toList()[selectedIndex];

                              context.read<ExistingWalletBloc>().add(
                                WalletSecurityEntered(
                                  coinType: coinType,
                                  walletName: walletNameController.text,
                                  walletType: walletType,
                                  securityType: getSecurityTypeFromTab(
                                    selectedEntry.key,
                                  ),
                                  pasteFieldText:
                                      selectedEntry.value['pasteField']!.text,
                                  password: selectedEntry
                                      .value['passwordField']
                                      ?.text,
                                ),
                              );
                            },
                            child: Text("Import"),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
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
                    children: [Loading(), Text('Importing wallet')],
                  ),
                ),
              );
            }
            return Container();
          },
        ),
      ],
    );
  }
}

class KeystoreTabView extends StatelessWidget {
  final TextEditingController pasteFieldController;
  final TextEditingController passwordController;
  const KeystoreTabView({
    super.key,
    required this.pasteFieldController,
    required this.passwordController,
  });

  @override
  Widget build(BuildContext context) {
    return PasteField(
      controller: pasteFieldController,
      hintText: 'Wallet Keystore JSON',
      additionalWidget: TextFormField(
        controller: passwordController,
        obscureText: true,
        decoration: const InputDecoration(hintText: 'Password'),
      ),
      subtitle:
          'Several lines of text beginning with “{...}” plus the password you used to encrypt it',
    );
  }
}
