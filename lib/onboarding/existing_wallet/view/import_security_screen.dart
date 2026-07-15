import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genius_api/ffi/trust_wallet_api_ffi.dart';
import 'package:genius_api/types/security_type.dart';
import 'package:genius_wallet/components/buttons/gw_button.dart';
import 'package:genius_wallet/components/inputs/gw_text_field.dart';
import 'package:genius_wallet/components/loading/gw_spinner.dart';
import 'package:genius_wallet/components/overlays/gw_dialog.dart';
import 'package:genius_wallet/components/scaffold/scaffold_helper.dart';
import 'package:genius_wallet/onboarding/widgets/paste_field.dart';
import 'package:genius_wallet/theme/genius_wallet_colors.dart';
import 'package:genius_wallet/theme/genius_wallet_consts.dart';
import 'package:genius_wallet/theme/genius_wallet_decorations.dart';
import 'package:genius_wallet/theme/genius_wallet_elevation.dart';
import 'package:genius_wallet/theme/genius_wallet_typography.dart';
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
              showAppSnackBar(
                context,
                'Failed to import wallet. Check your import settings and try again.',
                backgroundColor: GeniusWalletColors.statusError,
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
                      constraints: BoxConstraints(
                        maxWidth: GeniusBreakpoints.small * 0.8,
                      ),
                      child: Column(
                        spacing: 24.0,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Import $walletType Wallet',
                            style: Theme.of(context).textTheme.headlineLarge,
                          ),
                          GWTextField(
                            controller: walletNameController,
                            label: 'Name',
                            hint: 'Enter wallet name',
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter a wallet name';
                              }
                              return null;
                            },
                          ),
                          _ImportMethodSelector(
                            controller: DefaultTabController.of(context),
                            labels: const [
                              'Phrase',
                              'Private Key',
                              'Keystore',
                              'Address',
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
                                  controller: tabControllers['privatekey']![
                                      'pasteField']!,
                                  subtitle:
                                      'Typically 64 alphanumeric characters.',
                                ),
                                KeystoreTabView(
                                  passwordController: tabControllers['keystore']![
                                      'passwordField']!,
                                  pasteFieldController: tabControllers[
                                      'keystore']!['pasteField']!,
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
                          GWButton(
                            label: 'Import',
                            variant: GWButtonVariant.gradient,
                            size: GWButtonSize.lg,
                            expand: true,
                            onPressed: () {
                              if (!formKey.currentState!.validate()) {
                                return;
                              }

                              final selectedIndex =
                                  DefaultTabController.of(context).index;

                              final selectedEntry =
                                  tabControllers.entries.toList()[selectedIndex];

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
                child: GWDialog(
                  title: 'Importing wallet',
                  content: Center(child: GWSpinner(size: 32)),
                ),
              );
            }
            return const SizedBox.shrink();
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
      additionalWidget: GWPasswordField(
        controller: passwordController,
        hint: 'Password',
      ),
      subtitle:
          'Several lines of text beginning with “{...}” plus the password you used to encrypt it',
    );
  }
}

/// ponytail: Local reproduction of dashboard_screen.dart's private `_Tabs`
/// pill/segmented-control motif (recessed `surfaceSunken` track + per-segment
/// `AnimatedContainer` highlight using `GWDecorations.surfaceSheen`), extended
/// from 2 to 4 segments. Copied rather than shared because this is only the
/// second consumer and CLAUDE.md discourages unrequested abstractions.
/// Ceiling: the motif is duplicated from dashboard's private `_Tabs`.
/// Upgrade path: extract a shared `GWSegmentedControl` if a third consumer
/// appears. Drives the same `TabController` the Import button reads via
/// `DefaultTabController.of(context).index`, so tab content wiring is unchanged.
class _ImportMethodSelector extends StatelessWidget {
  const _ImportMethodSelector({required this.controller, required this.labels});

  final TabController controller;
  final List<String> labels;

  @override
  Widget build(BuildContext context) {
    // Rebuild the highlight whenever the controller's index changes — whether
    // from a segment tap or a TabBarView swipe.
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        return Container(
          height: 48, // Material touch target, matching dashboard's _Tabs.
          decoration: BoxDecoration(
            color: GeniusWalletColors.surfaceSunken,
            borderRadius: BorderRadius.circular(GeniusWalletConsts.radiusPill),
            border:
                Border.all(color: GeniusWalletColors.borderSubtle, width: 1),
          ),
          child: Row(
            children: [
              for (var i = 0; i < labels.length; i++)
                Expanded(child: _segment(i)),
            ],
          ),
        );
      },
    );
  }

  Widget _segment(int i) {
    final selected = controller.index == i;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => controller.animateTo(i),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
        margin: const EdgeInsets.all(3),
        decoration: BoxDecoration(
          gradient: selected ? GWDecorations.surfaceSheen : null,
          borderRadius: BorderRadius.circular(GeniusWalletConsts.radiusPill),
          border: selected
              ? Border.all(color: GeniusWalletColors.borderSubtle, width: 1)
              : null,
          boxShadow: selected ? GeniusWalletElevation.card : null,
        ),
        alignment: Alignment.center,
        child: Text(
          labels[i],
          textAlign: TextAlign.center,
          style: GeniusWalletTypography.labelMd.copyWith(
            color: selected
                ? GeniusWalletColors.textPrimary
                : GeniusWalletColors.textSecondary,
            fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
