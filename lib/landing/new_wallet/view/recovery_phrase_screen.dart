import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genius_wallet/app/widgets/app_screen_view.dart';
import 'package:genius_wallet/landing/new_wallet/bloc/new_wallet_bloc.dart';
import 'package:genius_wallet/landing/widgets/recovery_words.dart';
import 'package:genius_wallet/widgets/components/continue_button/isactive_true.g.dart';
import 'package:genius_wallet/widgets/components/registration_header.g.dart';

class RecoveryPhraseScreen extends StatelessWidget {
  const RecoveryPhraseScreen({super.key});

  @override
  Widget build(BuildContext context) {
    context.read<NewWalletBloc>().add(LoadRecoveryPhrase());
    return Scaffold(
      body: BlocListener<NewWalletBloc, NewWalletState>(
        listener: (context, state) {
          if (state.recoveryPhraseCopied == NewWalletStatus.loaded) {
            ScaffoldMessenger.of(context)
                .showSnackBar(const SnackBar(content: Text('Phrase copied!')));
          } else if (state.recoveryPhraseCopied == NewWalletStatus.error) {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                content: Text('There was an error copying the text.')));
          }
        },
        child: AppScreenView(
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
              const RecoveryWords(),
              const SizedBox(
                height: 25,
              ),
              MaterialButton(
                onPressed: () {
                  context.read<NewWalletBloc>().add(CopyRecoveryPhrase());
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
            child: LayoutBuilder(builder: (context, constraints) {
              return IsactiveTrue(constraints);
            }),
          ),
        ),
      ),
    );
  }
}
