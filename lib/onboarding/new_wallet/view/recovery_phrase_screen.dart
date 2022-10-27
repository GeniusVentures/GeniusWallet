import 'package:auto_size_text/auto_size_text.dart';
import 'package:clipboard/clipboard.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genius_wallet/app/widgets/app_screen_view.dart';
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
      body: AppScreenView(
        body: Column(
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
            const SizedBox(
              height: 100,
            ),
            BlocBuilder<NewWalletBloc, NewWalletState>(
              builder: (context, state) {
                if (state.recoveryPhraseStatus == NewWalletStatus.loaded) {
                  return RecoveryWords(recoveryWords: state.recoveryWords);
                }
                return const CircularProgressIndicator();
              },
            ),
            const SizedBox(
              height: 25,
            ),
            MaterialButton(
              onPressed: () async {
                await FlutterClipboard.copy(context
                    .read<NewWalletBloc>()
                    .state
                    .recoveryWords
                    .join(' '));
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
      ),
    );
  }
}
