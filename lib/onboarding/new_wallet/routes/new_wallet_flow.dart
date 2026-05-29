import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genius_wallet/bloc/app_bloc.dart';
import 'package:genius_wallet/onboarding/bloc/new_pin_cubit.dart';
import 'package:genius_wallet/onboarding/new_wallet/bloc/new_wallet_bloc.dart';
import 'package:genius_wallet/onboarding/existing_wallet/view/legal_screen.dart';
import 'package:genius_wallet/onboarding/new_wallet/view/recovery_phrase_screen.dart';
import 'package:genius_wallet/onboarding/new_wallet/view/verify_recovery_phrase_screen.dart';
import 'package:genius_wallet/onboarding/view/confirm_and_save_pin_screen.dart';
import 'package:genius_wallet/onboarding/view/create_pin_screen.dart';
import 'package:go_router/go_router.dart';

class NewWalletFlow extends StatelessWidget {
  const NewWalletFlow({super.key});

  static const _firstStep = NewWalletStep.agreement;

  @override
  Widget build(BuildContext context) {
    final newPinCubit = context.read<NewPinCubit>();
    return BlocListener<NewWalletBloc, NewWalletState>(
      listenWhen: (prev, curr) =>
          prev.walletSaveStatus != NewWalletStatus.loaded &&
          curr.walletSaveStatus == NewWalletStatus.loaded,
      listener: (context, state) {
        context.read<AppBloc>().add(LoadWallets());
        context.go('/dashboard');
      },
      child: BlocBuilder<NewWalletBloc, NewWalletState>(
        builder: (context, state) {
          return PopScope(
            canPop: state.currentStep == _firstStep,
            onPopInvokedWithResult: (didPop, result) {
              if (!didPop) {
                context.read<NewWalletBloc>().add(GoBack());
              }
            },
            child: Scaffold(
              appBar: AppBar(
                leading: IconButton(
                  icon: const Icon(Icons.chevron_left, size: 20),
                  onPressed: () {
                    if (state.currentStep == _firstStep) {
                      Navigator.of(context).pop();
                    } else {
                      context.read<NewWalletBloc>().add(GoBack());
                    }
                  },
                ),
              ),
              body: _buildStep(context, newPinCubit, state),
            ),
          );
        },
      ),
    );
  }

  Widget _buildStep(
      BuildContext context, NewPinCubit newPinCubit, NewWalletState state) {
    switch (state.currentStep) {
      case NewWalletStep.agreement:
        return LegalScreen(
          accepted: state.acceptedWarning,
          onToggle: () =>
              context.read<NewWalletBloc>().add(ToggleCheckbox()),
          onContinue: () {
            final userExists = context.read<AppBloc>().state.userStatus ==
                UserStatus.exists;
            context
                .read<NewWalletBloc>()
                .add(AgreementAccepted(userExists: userExists));
          },
        );
      case NewWalletStep.verifyRecoveryPhrase:
        return const VerifyRecoveryPhraseScreen();
      case NewWalletStep.copyPhrase:
        return const RecoveryPhraseScreen();
      case NewWalletStep.confirmPin:
        return BlocProvider.value(
          value: newPinCubit,
          child: ConfirmAndSavePinScreen(
            onFailed: () =>
                context.read<NewWalletBloc>().add(PinConfirmFailed()),
            onPassed: () =>
                context.read<NewWalletBloc>().add(PinConfirmPassed()),
          ),
        );
      case NewWalletStep.createPin:
        return BlocProvider.value(
          value: newPinCubit,
          child: CreatePinScreen(
            onCompleted: (value) {
              newPinCubit.pinEntered(value);
              context.read<NewWalletBloc>().add(PinCreated());
            },
          ),
        );
    }
  }
}
