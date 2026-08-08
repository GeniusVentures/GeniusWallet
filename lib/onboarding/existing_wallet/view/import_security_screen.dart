import 'package:flutter/gestures.dart' show PointerDeviceKind;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genius_api/ffi/trust_wallet_api_ffi.dart';
import 'package:genius_api/types/security_type.dart';
import 'package:genius_wallet/components/buttons/gw_button.dart';
import 'package:genius_wallet/components/inputs/gw_text_field.dart';
import 'package:genius_wallet/components/loading.dart';
import 'package:genius_wallet/components/toast/toast_manager.dart';
import 'package:genius_wallet/onboarding/existing_wallet/bloc/existing_wallet_bloc.dart';
import 'package:genius_wallet/onboarding/widgets/paste_field.dart';
import 'package:genius_wallet/theme/genius_wallet_consts.dart';
import 'package:genius_wallet/theme/genius_wallet_typography.dart';
import 'package:genius_wallet/theme/gw_colors.dart';
import 'package:genius_wallet/theme/gw_context_extension.dart';
import 'package:genius_wallet/utils/breakpoints.dart';

class ImportSecurityScreen extends StatefulWidget {
  final String walletType;
  final TWCoinType coinType;
  const ImportSecurityScreen({
    required this.walletType,
    required this.coinType,
    super.key,
  });

  @override
  State<ImportSecurityScreen> createState() => _ImportSecurityScreenState();
}

class _ImportSecurityScreenState extends State<ImportSecurityScreen> {
  // Owned by the State, not rebuilt per frame. These hold a seed phrase, a
  // private key and a keystore password: constructing them in `build()` left
  // one abandoned set per rebuild, each retaining key material for as long as
  // the GC took to notice, and none of them ever disposed. (06-04 §1 recorded
  // the defect and fenced the fix out of scope as a Stateless -> Stateful
  // restructure; this is that restructure.)
  //
  // `TextEditingController` holds a `String`, which is immutable and cannot be
  // zeroed — AGENTS.md prefers `Uint8List` for exactly this reason. Clearing
  // before dispose drops this object's reference at a known point instead of
  // an arbitrary one; it does not scrub the characters from the heap. That
  // remains the real ceiling here.
  late final Map<String, Map<String, TextEditingController>> _tabControllers;
  late final TextEditingController _walletNameController;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _tabControllers = {
      'phrase': {'pasteField': TextEditingController()},
      'privatekey': {'pasteField': TextEditingController()},
      'keystore': {
        'pasteField': TextEditingController(),
        'passwordField': TextEditingController(),
      },
      'address': {'pasteField': TextEditingController()},
    };
    _walletNameController = TextEditingController();
  }

  @override
  void dispose() {
    for (final tab in _tabControllers.values) {
      for (final controller in tab.values) {
        controller.clear();
        controller.dispose();
      }
    }
    _walletNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final gw = Theme.of(context).extension<GWColors>() ?? GWColors.dark();
    final isNarrow = MediaQuery.sizeOf(context).width < GeniusBreakpoints.small;

    final tabControllers = _tabControllers;
    final walletNameController = _walletNameController;
    final formKey = _formKey;

    return Stack(
      children: [
        BlocListener<ExistingWalletBloc, ExistingWalletState>(
          listener: (context, state) async {
            if (state.importWalletStatus == ExistingWalletStatus.error) {
              showToast(
                context,
                'Check your import settings and try again.',
                title: 'Could not import wallet',
                type: ToastType.error,
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
                    // Systemic onboarding gutter fix, applied proactively per
                    // the carried-forward todo rather than waiting for the walk
                    // to rediscover it a fourth time. Padding OUTSIDE the
                    // ConstrainedBox, so the inset is additive and wide-window
                    // centring is unchanged by construction (06-01, 67e2821).
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: GeniusWalletConsts.space8,
                      ),
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(
                          maxWidth: GeniusBreakpoints.small * 0.8,
                        ),
                        child: Column(
                          spacing: 24.0,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Import ${widget.walletType} Wallet',
                              style: GeniusWalletTypography.headlineLg.copyWith(
                                color: gw.textPrimary,
                              ),
                            ),
                            GWTextField(
                              label: 'Name',
                              hint: 'Enter wallet name',
                              controller: walletNameController,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter a wallet name';
                                }
                                return null;
                              },
                            ),
                            // Walk-driven (06-04 Task 4). The plan says leave
                            // the TabBar alone, and this is a deliberate Rule-1
                            // deviation from that: with tabAlignment.center +
                            // isScrollable, overflowing tabs could not be
                            // scrolled to at narrow widths, so TWO OF THE FOUR
                            // IMPORT METHODS were unreachable on a phone-sized
                            // window. That is a functional defect, not a style
                            // preference. TabAlignment.start is the correct
                            // pairing for a scrollable TabBar; centring is kept
                            // above the breakpoint where everything fits.
                            // Flutter's default MaterialScrollBehavior omits
                            // PointerDeviceKind.mouse from dragDevices on
                            // desktop, so a scrollable TabBar cannot be dragged
                            // with a mouse — and a wheel scrolls vertically,
                            // which does nothing to a horizontal strip. The
                            // tabs were therefore scrollable in principle and
                            // unreachable in practice. Opting the mouse back in
                            // is what actually makes the overflowing tabs
                            // reachable; TabAlignment.start alone was not
                            // enough.
                            ScrollConfiguration(
                              behavior: ScrollConfiguration.of(context)
                                  .copyWith(
                                    dragDevices: const {
                                      PointerDeviceKind.touch,
                                      PointerDeviceKind.mouse,
                                      PointerDeviceKind.trackpad,
                                      PointerDeviceKind.stylus,
                                    },
                                  ),
                              child: TabBar(
                                tabAlignment: isNarrow
                                    ? TabAlignment.start
                                    : TabAlignment.center,
                                isScrollable: true,
                                tabs: const [
                                  Tab(text: 'Phrase'),
                                  Tab(text: 'Private Key'),
                                  Tab(text: 'Keystore'),
                                  Tab(text: 'Address'),
                                ],
                              ),
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
                            GWButton(
                              label: 'Import',
                              variant: GWButtonVariant.gradient,
                              size: GWButtonSize.lg,
                              expand: true,
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
                                    coinType: widget.coinType,
                                    walletName: walletNameController.text,
                                    walletType: widget.walletType,
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
                    ),
                  );
                },
              ),
            ),
          ),
        ),
        BlocBuilder<ExistingWalletBloc, ExistingWalletState>(
          builder: (context, state) {
            final gw =
                Theme.of(context).extension<GWColors>() ?? GWColors.dark();
            if (state.importWalletStatus == ExistingWalletStatus.loading) {
              // Walk-driven (06-04 Task 4): the overlay had no scrim, so it did
              // not read as modal — the live form stayed at full contrast
              // behind it. surfaceOverlay is the same token GWDialog and
              // GWBottomSheet already use as their barrierColor, so this
              // matches every other modal in the app rather than inventing a
              // value.
              return SizedBox.expand(
                child: ColoredBox(
                  color: context.gw.surfaceOverlay,
                  child: Center(
                    child: AlertDialog(
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Loading(),
                          Text(
                            'Importing wallet',
                            style: GeniusWalletTypography.bodyMd.copyWith(
                              color: gw.textPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),
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
    final gw = Theme.of(context).extension<GWColors>() ?? GWColors.dark();

    return PasteField(
      controller: pasteFieldController,
      hintText: 'Wallet Keystore JSON',
      // Kept as a raw TextFormField, NOT routed through GWTextField (§4.7/§5.4).
      // obscureText: true is a key-safety property, not a style — preserved.
      additionalWidget: TextFormField(
        controller: passwordController,
        obscureText: true,
        // SECURITY — the FOURTH key-bearing typed input, added beyond 06-04's
        // written scope by explicit decision 2026-07-22.
        //
        // The plan hardened three fields (paste_field + the two SDK dialogs).
        // This one holds the password that decrypts a keystore and had none of
        // the flags. `obscureText: true` MAY already suppress some of this on
        // some platforms — but "probably covered" is precisely the reasoning
        // this plan's own amendment was written to kill: autocorrect and
        // enableSuggestions also looked sufficient, and left
        // IME_FLAG_NO_PERSONALIZED_LEARNING wide open. Set them explicitly so
        // the guarantee does not depend on an unverified platform behaviour.
        autocorrect: false,
        enableSuggestions: false,
        enableIMEPersonalizedLearning: false,
        textCapitalization: TextCapitalization.none,
        style: GeniusWalletTypography.bodyLg,
        decoration: InputDecoration(
          hintText: 'Password',
          hintStyle: GeniusWalletTypography.bodyLg.copyWith(
            color: gw.textSecondary,
          ),
        ),
      ),
      subtitle:
          'Several lines of text beginning with “{...}” plus the password you used to encrypt it',
    );
  }
}
