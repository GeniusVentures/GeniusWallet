import 'package:flow_builder/flow_builder.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genius_wallet/landing/existing_wallet/bloc/existing_wallet_bloc.dart';
import 'package:genius_wallet/landing/existing_wallet/view/confirm_passcode_screen.dart';
import 'package:genius_wallet/landing/existing_wallet/view/create_passcode_screen.dart';
import 'package:genius_wallet/landing/existing_wallet/view/import_security_screen.dart';
import 'package:genius_wallet/landing/existing_wallet/view/import_wallet_screen.dart';
import 'package:genius_wallet/landing/existing_wallet/view/legal_screen.dart';
import 'package:genius_wallet/landing/view/confirm_pin_screen.dart';
import 'package:genius_wallet/landing/view/create_pin_screen.dart';

class ExistingWalletFlow extends StatelessWidget {
  const ExistingWalletFlow({super.key});

  @override
  Widget build(BuildContext context) {
    return FlowBuilder(
      onGeneratePages: (state, pages) {
        switch (state.currentStep) {
          case FlowStep.confirmPin:
            return [
              const MaterialPage(child: LegalScreen()),
              const MaterialPage(child: ImportWalletScreen()),
              MaterialPage(
                  child:
                      ImportSecurityScreen(walletType: state.selectedWallet)),
              const MaterialPage(child: CreatePinScreen()),
              MaterialPage(
                  child: ConfirmPinScreen(
                pinToConfirm: state.createdPin,
              )),
            ];
          case FlowStep.createPin:
            return [
              const MaterialPage(child: LegalScreen()),
              const MaterialPage(child: ImportWalletScreen()),
              MaterialPage(
                  child:
                      ImportSecurityScreen(walletType: state.selectedWallet)),
              const MaterialPage(child: CreatePinScreen())
            ];
          case FlowStep.importWalletSecurity:
            return [
              const MaterialPage(child: LegalScreen()),
              const MaterialPage(child: ImportWalletScreen()),
              MaterialPage(
                  child:
                      ImportSecurityScreen(walletType: state.selectedWallet)),
            ];
          case FlowStep.importWallet:
            return [
              const MaterialPage(child: LegalScreen()),
              const MaterialPage(child: ImportWalletScreen()),
            ];
          case FlowStep.legal:
          default:
            return [
              const MaterialPage(child: LegalScreen()),
            ];
        }
        return [
          const MaterialPage(child: LegalScreen()),
          const MaterialPage(child: CreatePasscodeScreen()),
          if (state.currentStep == FlowStep.confirmPasscode)
            const MaterialPage(child: ConfirmPasscodeScreen()),
          if (state.currentStep == FlowStep.importWallet)
            const MaterialPage(child: ImportWalletScreen()),
          if (state.currentStep == FlowStep.importWalletSecurity)
            MaterialPage(
              child: ImportSecurityScreen(walletType: state.selectedWallet),
            ),
          if (state.currentStep == FlowStep.createPin)
            const MaterialPage(child: CreatePinScreen()),
          if (state.currentStep == FlowStep.confirmPin)
            MaterialPage(
                child: ConfirmPinScreen(pinToConfirm: state.createdPin))
        ];
      },
      state: context.watch<ExistingWalletBloc>().state,
    );
  }
}
