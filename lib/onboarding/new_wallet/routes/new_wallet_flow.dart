import 'package:flow_builder/flow_builder.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genius_wallet/onboarding/new_wallet/bloc/new_wallet_bloc.dart';
import 'package:genius_wallet/onboarding/new_wallet/view/backup_phrase_screen.dart';
import 'package:genius_wallet/onboarding/new_wallet/view/recovery_phrase_screen.dart';
import 'package:genius_wallet/onboarding/new_wallet/view/verify_recovery_phrase_screen.dart';

class NewWalletFlow extends StatelessWidget {
  const NewWalletFlow({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FlowBuilder(
      onGeneratePages: (state, pages) {
        switch (state.currentStep) {
          case NewWalletStep.verifyRecoveryPhrase:
            return [
              const MaterialPage(child: BackupPhraseScreen()),
              const MaterialPage(child: RecoveryPhraseScreen()),
              const MaterialPage(child: VerifyRecoveryPhraseScreen()),
            ];
          case NewWalletStep.copyPhrase:
            return [
              const MaterialPage(child: BackupPhraseScreen()),
              const MaterialPage(child: RecoveryPhraseScreen()),
            ];
          case NewWalletStep.agreement:
          default:
            return [const MaterialPage(child: BackupPhraseScreen())];
        }
      },
      state: context.watch<NewWalletBloc>().state,
    );
  }
}
