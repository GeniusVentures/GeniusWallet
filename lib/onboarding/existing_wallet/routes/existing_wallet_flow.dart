import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genius_wallet/bloc/app_bloc.dart';
import 'package:genius_wallet/onboarding/bloc/new_pin_cubit.dart';
import 'package:genius_wallet/onboarding/existing_wallet/bloc/existing_wallet_bloc.dart';
import 'package:genius_wallet/onboarding/existing_wallet/view/import_security_screen.dart';
import 'package:genius_wallet/onboarding/existing_wallet/view/select_wallet_type_screen.dart';
import 'package:genius_wallet/onboarding/existing_wallet/view/legal_screen.dart';
import 'package:genius_wallet/onboarding/view/confirm_and_save_pin_screen.dart';
import 'package:genius_wallet/onboarding/view/create_pin_screen.dart';
import 'package:go_router/go_router.dart';

class ExistingWalletFlow extends StatelessWidget {
  const ExistingWalletFlow({super.key});

  static const _firstStep = ImportWalletStep.legal;

  @override
  Widget build(BuildContext context) {
    final newPinCubit = context.read<NewPinCubit>();
    return BlocListener<ExistingWalletBloc, ExistingWalletState>(
      listenWhen: (prev, curr) =>
          prev.importWalletStatus != ExistingWalletStatus.success &&
          curr.importWalletStatus == ExistingWalletStatus.success,
      listener: (context, state) {
        context.read<AppBloc>().add(SubscribeToWallets());
        context.go('/dashboard');
      },
      child: BlocBuilder<ExistingWalletBloc, ExistingWalletState>(
        builder: (context, state) {
          return PopScope(
            canPop: state.currentStep == _firstStep,
            onPopInvokedWithResult: (didPop, result) {
              if (!didPop) {
                context.read<ExistingWalletBloc>().add(GoBack());
              }
            },
            child: Scaffold(
              appBar: AppBar(
                leading: IconButton(
                  icon: const Icon(Icons.chevron_left),
                  tooltip: "Go back",
                  onPressed: () {
                    if (state.currentStep == _firstStep) {
                      Navigator.of(context).pop();
                    } else {
                      context.read<ExistingWalletBloc>().add(GoBack());
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

  Widget _buildStep(BuildContext context, NewPinCubit newPinCubit,
      ExistingWalletState state) {
    switch (state.currentStep) {
      case ImportWalletStep.importWalletSecurity:
        return ImportSecurityScreen(
          walletType: state.selectedWallet,
          coinType: state.selectedCoinType,
        );
      case ImportWalletStep.importWallet:
        return const SelectWalletTypeScreen();
      case ImportWalletStep.confirmPin:
        return BlocProvider.value(
          value: newPinCubit,
          child: ConfirmAndSavePinScreen(
            onFailed: () =>
                context.read<ExistingWalletBloc>().add(PinConfirmFailed()),
            onPassed: () =>
                context.read<ExistingWalletBloc>().add(PinConfirmPassed()),
          ),
        );
      case ImportWalletStep.createPin:
        return BlocProvider.value(
          value: newPinCubit,
          child: CreatePinScreen(
            onCompleted: (value) {
              newPinCubit.pinEntered(value);
              context.read<ExistingWalletBloc>().add(PinCreated(pin: value));
            },
          ),
        );
      case ImportWalletStep.legal:
        return const LegalScreen();
    }
  }
}
