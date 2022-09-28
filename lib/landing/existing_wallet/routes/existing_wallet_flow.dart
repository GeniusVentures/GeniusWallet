import 'package:flow_builder/flow_builder.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genius_wallet/landing/existing_wallet/bloc/existing_wallet_bloc.dart';
import 'package:genius_wallet/landing/existing_wallet/view/confirm_passcode_screen.dart';
import 'package:genius_wallet/landing/existing_wallet/view/create_passcode_screen.dart';
import 'package:genius_wallet/landing/existing_wallet/view/import_security_screen.dart';
import 'package:genius_wallet/landing/existing_wallet/view/import_wallet_screen.dart';
import 'package:genius_wallet/landing/existing_wallet/view/legal_screen.dart';

class ExistingWalletFlow extends StatelessWidget {
  const ExistingWalletFlow({super.key});

  @override
  Widget build(BuildContext context) {
    return FlowBuilder(
      onGeneratePages: (state, pages) {
        return [
          const MaterialPage(child: LegalScreen()),
          if (state.currentStep == FlowStep.createPasscode)
            const MaterialPage(child: CreatePasscodeScreen()),
          if (state.currentStep == FlowStep.confirmPasscode)
            const MaterialPage(child: ConfirmPasscodeScreen()),
          if (state.currentStep == FlowStep.importWallet)
            const MaterialPage(child: ImportWalletScreen()),
          if (state.currentStep == FlowStep.importWalletSecurity)
            MaterialPage(
              child: ImportSecurityScreen(walletName: state.selectedWallet),
            ),
        ];
      },
      state: context.watch<ExistingWalletBloc>().state,
    );
  }
}
