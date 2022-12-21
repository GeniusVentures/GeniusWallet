import 'package:flow_builder/flow_builder.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genius_wallet/onboarding/bloc/new_pin_cubit.dart';
import 'package:genius_wallet/onboarding/bloc/new_pin_state.dart';
import 'package:genius_wallet/onboarding/new_wallet/bloc/new_wallet_bloc.dart';
import 'package:genius_wallet/onboarding/new_wallet/view/backup_phrase_screen.dart';
import 'package:genius_wallet/onboarding/new_wallet/view/recovery_phrase_screen.dart';
import 'package:genius_wallet/onboarding/new_wallet/view/verify_recovery_phrase_screen.dart';
import 'package:genius_wallet/onboarding/view/confirm_and_save_pin_screen.dart';
import 'package:genius_wallet/onboarding/view/create_pin_screen.dart';
import 'package:go_router/go_router.dart';

class NewUserNewWalletFlow extends StatelessWidget {
  const NewUserNewWalletFlow({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final newPinCubit = context.read<NewPinCubit>();
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
          case NewWalletStep.confirmPin:
            return [
              const MaterialPage(child: BackupPhraseScreen()),
              MaterialPage(
                child: BlocProvider.value(
                  value: newPinCubit,
                  child: CreatePinScreen(
                    onCompleted: (value) {
                      newPinCubit.pinEntered(value);
                      context.read<NewWalletBloc>().add(PinCreated());
                    },
                  ),
                ),
              ),
              MaterialPage(
                child: BlocProvider.value(
                  value: newPinCubit,
                  child: BlocListener<NewPinCubit, NewPinState>(
                    listener: (context, state) {
                      if (state.pinConfirmStatus == PinConfirmStatus.failed) {
                        context.read<NewWalletBloc>().add(PinConfirmFailed());
                      } else if (state.pinConfirmStatus ==
                              PinConfirmStatus.passed &&
                          state.pinSaveStatus == PinSaveStatus.saved) {
                        context.read<NewWalletBloc>().add(PinConfirmPassed());
                      }
                    },
                    child: const ConfirmAndSavePinScreen(),
                  ),
                ),
              ),
            ];
          case NewWalletStep.createPin:
            return [
              const MaterialPage(child: BackupPhraseScreen()),
              MaterialPage(
                child: BlocProvider.value(
                  value: newPinCubit,
                  child: CreatePinScreen(
                    onCompleted: (value) {
                      newPinCubit.pinEntered(value);

                      context.read<NewWalletBloc>().add(PinCreated());
                    },
                  ),
                ),
              ),
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
