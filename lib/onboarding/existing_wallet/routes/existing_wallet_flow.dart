import 'package:flow_builder/flow_builder.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genius_wallet/onboarding/bloc/new_pin_cubit.dart';
import 'package:genius_wallet/onboarding/existing_wallet/bloc/existing_wallet_bloc.dart';
import 'package:genius_wallet/onboarding/existing_wallet/view/import_security_screen.dart';
import 'package:genius_wallet/onboarding/existing_wallet/view/import_wallet_screen.dart';
import 'package:genius_wallet/onboarding/existing_wallet/view/legal_screen.dart';
import 'package:genius_wallet/onboarding/view/confirm_and_save_pin_screen.dart';
import 'package:genius_wallet/onboarding/view/create_pin_screen.dart';
import 'package:go_router/go_router.dart';

class ExistingWalletFlow extends StatelessWidget {
  const ExistingWalletFlow({super.key});

  @override
  Widget build(BuildContext context) {
    final newPinCubit = context.read<NewPinCubit>();
    return FlowBuilder(
      onGeneratePages: (state, pages) {
        switch (state.currentStep) {
          case FlowStep.importWalletSecurity:
            return [
              const MaterialPage(child: LegalScreen()),
              const MaterialPage(child: ImportWalletScreen()),
              MaterialPage(
                child: ImportSecurityScreen(walletType: state.selectedWallet),
              ),
            ];
          case FlowStep.importWallet:
            return [
              const MaterialPage(child: LegalScreen()),
              const MaterialPage(child: ImportWalletScreen()),
            ];
          case FlowStep.confirmPin:
            return [
              const MaterialPage(child: LegalScreen()),
              MaterialPage(
                child: BlocProvider.value(
                  value: newPinCubit,
                  child: CreatePinScreen(
                    onCompleted: (value) {
                      newPinCubit.pinEntered(value);
                      context
                          .read<ExistingWalletBloc>()
                          .add(PinCreated(pin: value));
                    },
                  ),
                ),
              ),
              MaterialPage(
                child: BlocProvider.value(
                  value: newPinCubit,
                  child: ConfirmAndSavePinScreen(
                    onFailed: () {
                      context
                          .read<ExistingWalletBloc>()
                          .add(PinConfirmFailed());
                    },
                    onPassed: () {
                      context
                          .read<ExistingWalletBloc>()
                          .add(PinConfirmPassed());
                    },
                  ),
                ),
              ),
            ];
          case FlowStep.createPin:
            return [
              const MaterialPage(child: LegalScreen()),
              MaterialPage(
                child: BlocProvider.value(
                  value: newPinCubit,
                  child: CreatePinScreen(
                    onCompleted: (value) {
                      newPinCubit.pinEntered(value);

                      context
                          .read<ExistingWalletBloc>()
                          .add(PinCreated(pin: value));
                    },
                  ),
                ),
              ),
            ];
          case FlowStep.legal:
          default:
            return [
              const MaterialPage(child: LegalScreen()),
            ];
        }
      },
      state: context.watch<ExistingWalletBloc>().state,
      onComplete: (state) {
        context.go('/dashboard');
      },
    );
  }
}
