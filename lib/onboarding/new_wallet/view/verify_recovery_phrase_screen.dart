import 'dart:math';

import 'package:flow_builder/flow_builder.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genius_api/genius_api.dart';
import 'package:genius_api/models/wallet.dart';
import 'package:genius_wallet/app/utils/breakpoints.dart';
import 'package:genius_wallet/app/widgets/app_screen_with_header_desktop.dart';
import 'package:genius_wallet/app/widgets/app_screen_with_header_mobile.dart';
import 'package:genius_wallet/app/widgets/desktop_body_container.dart';
import 'package:genius_wallet/onboarding/new_wallet/bloc/new_wallet_bloc.dart';
import 'package:genius_wallet/onboarding/widgets/recovery_words.dart';
import 'package:genius_wallet/onboarding/widgets/recovery_words_input.dart';
import 'package:genius_wallet/widgets/components/continue_button/isactive_true.g.dart';

class VerifyRecoveryPhraseScreen extends StatelessWidget {
  static const title = 'Verify Your Recovery Phrase';
  static const subtitle =
      'Tap the words to put them next to each other in the correct order';
  const VerifyRecoveryPhraseScreen({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocListener<NewWalletBloc, NewWalletState>(
      listener: (context, state) {
        if (state.verificationStatus == VerificationStatus.passed) {
          /// TODO: probably want to create the wallet step-by-step once the API is available
          final random = Random();
          final uuid = random.nextInt(99999999);
          // context.read<NewWalletBloc>().add(
          //       AddWallet(
          //         wallet: Wallet(
          //           walletName: 'dummy_wallet',
          //           currencySymbol: 'ETH',
          //           currencyName: 'Ethereum',
          //           address: uuid.toString(),
          //           balance: 0,
          //           transactions: [],
          //         ),
          //       ),
          //     );

          context.flow<NewWalletState>().complete();
        } else if (state.verificationStatus == VerificationStatus.failed) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content: Text('Verification failed. Please try again.')));
        }
      },
      child: Scaffold(
        body: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            if (GeniusBreakpoints.useDesktopLayout(context)) {
              return const _VerifyRecoveryPhraseViewDesktop(
                title: title,
                subtitle: subtitle,
              );
            }
            return const _VerifyRecoveryPhraseViewMobile(
              title: title,
              subtitle: subtitle,
            );
          },
        ),
      ),
    );
  }
}

class _VerifyRecoveryPhraseViewDesktop extends StatelessWidget {
  final String title;
  final String subtitle;
  const _VerifyRecoveryPhraseViewDesktop({
    required this.title,
    required this.subtitle,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppScreenWithHeaderDesktop(
      title: '',
      subtitle: '',
      body: Center(
        child: DesktopBodyContainer(
          title: title,
          subText: subtitle,
          width: 650,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            mainAxisSize: MainAxisSize.min,
            children: [
              const _InputAndWords(),
              SizedBox(
                height: 50,
                child: MaterialButton(
                  onPressed: () {
                    context
                        .read<NewWalletBloc>()
                        .add(RecoveryVerificationContinue());
                  },
                  child: LayoutBuilder(
                    builder:
                        (BuildContext context, BoxConstraints constraints) {
                      return IsactiveTrue(constraints);
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _VerifyRecoveryPhraseViewMobile extends StatelessWidget {
  final String title;
  final String subtitle;
  const _VerifyRecoveryPhraseViewMobile({
    required this.title,
    required this.subtitle,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppScreenWithHeaderMobile(
      title: 'Verify Your Recovery Phrase',
      subtitle:
          'Tap the words to put them next to each other in the correct order',
      body: const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: EdgeInsets.only(left: 40.0, right: 40.0, top: 40.0),
            child: _InputAndWords(),
          ),
          SizedBox(
            height: 100,
          ),
        ],
      ),
      footer: SizedBox(
        width: MediaQuery.of(context).size.width * 0.8,
        height: 50,
        child: MaterialButton(
          onPressed: () {
            context.read<NewWalletBloc>().add(RecoveryVerificationContinue());
          },
          child: LayoutBuilder(builder: (context, constraints) {
            return IsactiveTrue(constraints);
          }),
        ),
      ),
    );
  }
}

class _InputAndWords extends StatelessWidget {
  const _InputAndWords({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        RecoveryWordsInput(
          selectedWords: context.watch<NewWalletBloc>().state.selectedWords,
        ),
        const SizedBox(
          height: 50,
        ),
        RecoveryWords(
            recoveryWords: context.read<NewWalletBloc>().state.shuffledWords,
            isIncludeIndex: false),
      ],
    );
  }
}
