import 'package:flow_builder/flow_builder.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genius_wallet/app/bloc/pin_cubit.dart';
import 'package:genius_wallet/onboarding/existing_wallet/bloc/existing_wallet_bloc.dart';
import 'package:genius_wallet/onboarding/existing_wallet/view/import_security_screen.dart';
import 'package:genius_wallet/onboarding/existing_wallet/view/import_wallet_screen.dart';
import 'package:genius_wallet/onboarding/existing_wallet/view/legal_screen.dart';
import 'package:genius_wallet/onboarding/view/confirm_pin_screen.dart';
import 'package:genius_wallet/onboarding/view/create_pin_screen.dart';
import 'package:go_router/go_router.dart';

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
              MaterialPage(
                  child: BlocProvider(
                create: (context) => PinCubit(pinMaxLength: 6),
                child: const CreatePinScreen(),
              )),
              MaterialPage(
                  child: BlocProvider(
                create: (context) => PinCubit(pinMaxLength: 6),
                child: ConfirmPinScreen(
                  pinToConfirm: state.createdPin,
                ),
              )),
            ];
          case FlowStep.createPin:
            return [
              const MaterialPage(child: LegalScreen()),
              const MaterialPage(child: ImportWalletScreen()),
              MaterialPage(
                  child:
                      ImportSecurityScreen(walletType: state.selectedWallet)),
              MaterialPage(
                  child: BlocProvider(
                create: (context) => PinCubit(pinMaxLength: 6),
                child: const CreatePinScreen(),
              ))
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
      },
      state: context.watch<ExistingWalletBloc>().state,
      onComplete: (state){
        context.go('/dashboard');
      },
    );
  }
}
