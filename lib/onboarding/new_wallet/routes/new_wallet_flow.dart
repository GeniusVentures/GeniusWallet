import 'package:flow_builder/flow_builder.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genius_api/genius_api.dart';
import 'package:genius_wallet/app/bloc/pin_cubit.dart';
import 'package:genius_wallet/onboarding/new_wallet/bloc/new_wallet_bloc.dart';
import 'package:genius_wallet/onboarding/new_wallet/view/backup_phrase_screen.dart';
import 'package:genius_wallet/onboarding/new_wallet/view/recovery_phrase_screen.dart';
import 'package:genius_wallet/onboarding/new_wallet/view/verify_recovery_phrase_screen.dart';
import 'package:genius_wallet/onboarding/view/confirm_pin_screen.dart';
import 'package:genius_wallet/onboarding/view/create_pin_screen.dart';
import 'package:go_router/go_router.dart';

class NewWalletFlow extends StatelessWidget {
  const NewWalletFlow({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final confirmPinCubit = PinCubit(
      pinMaxLength: 6,
      geniusApi: context.read<GeniusApi>(),
    );
    return FlowBuilder(
      onGeneratePages: (state, pages) {
        switch (state.currentStep) {
          case NewWalletStep.confirmPin:
            return [
              const MaterialPage(child: BackupPhraseScreen()),
              const MaterialPage(child: RecoveryPhraseScreen()),
              const MaterialPage(child: VerifyRecoveryPhraseScreen()),
              MaterialPage(
                  child: BlocProvider(
                create: (context) => PinCubit(
                    pinMaxLength: 6, geniusApi: context.read<GeniusApi>()),
                child: const CreatePinScreen(),
              )),
              MaterialPage(
                  child: BlocProvider.value(
                value: confirmPinCubit,
                child: ConfirmPinScreen(pinToConfirm: state.createdPin),
              ))
            ];
          case NewWalletStep.createPin:
            return [
              const MaterialPage(child: BackupPhraseScreen()),
              const MaterialPage(child: RecoveryPhraseScreen()),
              const MaterialPage(child: VerifyRecoveryPhraseScreen()),
              MaterialPage(
                  child: BlocProvider(
                create: (context) => PinCubit(
                  pinMaxLength: 6,
                  geniusApi: context.read<GeniusApi>(),
                ),
                child: const CreatePinScreen(),
              ))
            ];
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
      onComplete: (value) {
        context.go('/dashboard');
      },
    );
  }
}
