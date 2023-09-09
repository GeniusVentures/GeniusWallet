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

  static const eth_addr = [
  "0x5b6234EcFE322f426244C856Ba94b01591570De4",
  "0x8e8e701eBe107dFce8377EF138599F3B0cb1D1E8",
  "0xa59854cf0c01890037283e7AC5BB29B12Fcea7cf",
  "0x823e3270aB5a9AB98EC2f9cfA5E509e3216A858F",
  "0x22E4F3779618DfE7642456A95B834c17f5156753",
  "0x51BD2bdB1C965116cf96A0180D6dDb8a5607b730",
  "0x89717B70BC33DA4ad38ECD37E1a63be9F5A22584",
  "0xEfa9e61C00156bB2D32EdF10eD803bAb6C6FaA77",
  "0x293815d82A0b6DE53280c4Aa5B738451c7FCd935",
  "0x271e1238A1D56BBD79B36Be55f35b97C50C30C1A",
  "0xF92100CAAaDBB7556bf481B6eb187AF5d4568597",
  "0x646ef6DcB82F9BE28343084851a45790CDe62F11",
  "0x2c70b3175b286434e3131cbAfaca7b02446744cf",
  "0xb6D75efA4c0dA5234C590bcC00165203195A728f",
  "0x2ba4723cBFeC5dBdB9B0b2A46080cF8a1060006E",
  "0x02eCe6BC0f18A1B1356d6ba63F385326060e15A0",
  ];
  @override
  Widget build(BuildContext context) {
    return BlocListener<NewWalletBloc, NewWalletState>(
      listener: (context, state) {
        if (state.verificationStatus == VerificationStatus.passed) {
          /// TODO: probably want to create the wallet step-by-step once the API is available
          final random = Random();
          final uuid = random.nextInt(99999999);
          context.read<NewWalletBloc>().add(
                AddWallet(
                  wallet: Wallet(
                    walletName: 'dummy_wallet',
                    currencySymbol: 'GNU',
                    currencyName: 'GNUS',
                    address: eth_addr[random.nextInt(eth_addr.length)].toString(),
                    balance: 0,
                    transactions: [],
                  ),
                ),
              );

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
      title: title,
      subtitle: subtitle,
      body: Center(
        child: DesktopBodyContainer(
          padding: DesktopBodyContainer.defaultPadding.copyWith(top: 40),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            mainAxisSize: MainAxisSize.min,
            children: [
              const _InputAndWords(),
              const SizedBox(height: 100),
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
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
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
          inputEnabled: true,
        ),
      ],
    );
  }
}
