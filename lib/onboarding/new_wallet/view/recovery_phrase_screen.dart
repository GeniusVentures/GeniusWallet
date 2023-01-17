import 'package:auto_size_text/auto_size_text.dart';
import 'package:clipboard/clipboard.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genius_wallet/app/utils/breakpoints.dart';
import 'package:genius_wallet/app/widgets/app_screen_view.dart';
import 'package:genius_wallet/app/widgets/app_screen_with_header.dart';
import 'package:genius_wallet/app/widgets/desktop_body_container.dart';
import 'package:genius_wallet/onboarding/new_wallet/bloc/new_wallet_bloc.dart';
import 'package:genius_wallet/onboarding/widgets/recovery_words.dart';
import 'package:genius_wallet/widgets/components/continue_button/isactive_true.g.dart';
import 'package:genius_wallet/widgets/components/registration_header.g.dart';

class RecoveryPhraseScreen extends StatefulWidget {
  const RecoveryPhraseScreen({super.key});

  @override
  State<StatefulWidget> createState() {
    return _RecoveryPhraseScreenState();
  }
}

class _RecoveryPhraseScreenState extends State<RecoveryPhraseScreen> {
  @override
  Widget build(BuildContext context) {
    context.read<NewWalletBloc>().add(LoadRecoveryPhrase());
    return Scaffold(
      body: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          if (GeniusBreakpoints.useDesktopLayout(context)) {
            return const _RecoveryPhraseViewDesktop();
          }
          return const _RecoveryPhraseViewMobile();
        },
      ),
    );
  }
}

class _RecoveryPhraseViewDesktop extends StatelessWidget {
  const _RecoveryPhraseViewDesktop({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppScreenWithHeader(
      title: 'Your Recovery Phrase',
      subtitle:
          'Write down or copy these words in the right order and save them somewhere safe',
      bodyWidgets: [
        DesktopBodyContainer(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Container(
                margin: const EdgeInsets.only(top: 20),
                child: const _WordsAndCopy(),
              ),
              const SizedBox(height: 80),
              Container(
                margin: const EdgeInsets.only(bottom: 20),
                height: 50,
                child: LayoutBuilder(
                  builder: (BuildContext context, BoxConstraints constraints) {
                    return MaterialButton(
                      onPressed: () {
                        context
                            .read<NewWalletBloc>()
                            .add(RecoveryPhraseContinue());
                      },
                      child: IsactiveTrue(constraints),
                    );
                  },
                ),
              )
            ],
          ),
        ),
      ],
    );
  }
}

class _RecoveryPhraseViewMobile extends StatelessWidget {
  const _RecoveryPhraseViewMobile({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppScreenView(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          SizedBox(
            width: MediaQuery.of(context).size.width,
            height: 190,
            child: LayoutBuilder(
              builder: (context, constraints) {
                return RegistrationHeader(
                  constraints,
                  ovrTitle: 'Your Recovery Phrase',
                  ovrSubtitle:
                      'Write down or copy these words in the right order and save them somewhere safe',
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.only(top: 20),
            width: MediaQuery.of(context).size.width * 0.8,
            child: const _WordsAndCopy(),
          ),
        ],
      ),
      footer: SizedBox(
        width: MediaQuery.of(context).size.width * .8,
        height: 50,
        child: MaterialButton(
          onPressed: () {
            context.read<NewWalletBloc>().add(RecoveryPhraseContinue());
          },
          child: LayoutBuilder(builder: (context, constraints) {
            return IsactiveTrue(constraints);
          }),
        ),
      ),
    );
  }
}

class _WordsAndCopy extends StatefulWidget {
  const _WordsAndCopy({Key? key}) : super(key: key);

  @override
  State<_WordsAndCopy> createState() => _WordsAndCopyState();
}

class _WordsAndCopyState extends State<_WordsAndCopy> {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        BlocBuilder<NewWalletBloc, NewWalletState>(
          builder: (context, state) {
            if (state.recoveryPhraseStatus == NewWalletStatus.loaded) {
              return RecoveryWords(recoveryWords: state.recoveryWords);
            }
            return const CircularProgressIndicator();
          },
        ),
        MaterialButton(
          onPressed: () async {
            await FlutterClipboard.copy(
                context.read<NewWalletBloc>().state.recoveryWords.join(' '));
            if (!mounted) {
              return;
            }
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Recovery phrase copied to clipboard!'),
              ),
            );
          },
          child: const AutoSizeText(
            'Copy',
            style: TextStyle(
              fontSize: 18,
            ),
          ),
        ),
      ],
    );
  }
}
