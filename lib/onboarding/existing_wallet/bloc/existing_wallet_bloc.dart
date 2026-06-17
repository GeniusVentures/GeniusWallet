import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genius_api/ffi/trust_wallet_api_ffi.dart';
import 'package:genius_api/genius_api.dart';
import 'package:genius_api/types/security_type.dart';

part 'existing_wallet_event.dart';
part 'existing_wallet_state.dart';

class ExistingWalletBloc
    extends Bloc<ExistingWalletEvent, ExistingWalletState> {
  final GeniusApi geniusApi;
  ExistingWalletBloc({
    ExistingWalletState initialState = const ExistingWalletState(),
    required this.geniusApi,
  }) : super(initialState) {
    on<ToggleLegal>(
      (event, emit) =>
          emit(state.copyWith(acceptedLegal: !state.acceptedLegal)),
    );

    on<ImportWalletSelected>(_onImportWalletSelected);

    on<WalletSecurityEntered>(_onWalletSecurityEntered);

    on<PinCreated>((event, emit) {
      emit(state.copyWith(currentStep: ImportWalletStep.confirmPin));
    });

    /// On [PinCheckFailed], send user back a screen and reset pin state
    on<PinConfirmFailed>((event, emit) {
      emit(state.copyWith(currentStep: ImportWalletStep.createPin));
    });

    on<PinConfirmPassed>((event, emit) {
      emit(state.copyWith(currentStep: ImportWalletStep.importWallet));
    });

    on<LegalAccepted>(_onLegalAccepted);

    on<GoBack>(_onGoBack);
  }

  void _onImportWalletSelected(
    ImportWalletSelected event,
    Emitter<ExistingWalletState> emit,
  ) => emit(
    state.copyWith(
      currentStep: ImportWalletStep.importWalletSecurity,
      selectedCoinType: event.coinType,
      selectedWallet: event.walletName,
    ),
  );

  FutureOr<void> _onWalletSecurityEntered(
    WalletSecurityEntered event,
    Emitter<ExistingWalletState> emit,
  ) async {
    emit(state.copyWith(importWalletStatus: ExistingWalletStatus.loading));

    try {
      final isSaved = await geniusApi.validateWalletImport(
        coinType: event.coinType,
        walletName: event.walletName,
        walletType: event.walletType,
        securityType: event.securityType,
        securityValue: event.pasteFieldText,
        password: event.password,
      );

      if (isSaved) {
        emit(state.copyWith(importWalletStatus: ExistingWalletStatus.success));
      } else {
        emit(state.copyWith(importWalletStatus: ExistingWalletStatus.error));
      }
    } catch (e) {
      emit(state.copyWith(importWalletStatus: ExistingWalletStatus.error));
    }
  }

  void _onLegalAccepted(
    LegalAccepted event,
    Emitter<ExistingWalletState> emit,
  ) {
    if (event.userExists) {
      emit(state.copyWith(currentStep: ImportWalletStep.importWallet));
    } else {
      emit(state.copyWith(currentStep: ImportWalletStep.createPin));
    }
  }

  void _onGoBack(GoBack event, Emitter<ExistingWalletState> emit) {
    switch (state.currentStep) {
      case ImportWalletStep.legal:
        break; // First step — PopScope handles route pop
      case ImportWalletStep.createPin:
        emit(state.copyWith(currentStep: ImportWalletStep.legal));
      case ImportWalletStep.confirmPin:
        emit(state.copyWith(currentStep: ImportWalletStep.createPin));
      case ImportWalletStep.importWallet:
        emit(state.copyWith(currentStep: ImportWalletStep.legal));
      case ImportWalletStep.importWalletSecurity:
        emit(state.copyWith(currentStep: ImportWalletStep.importWallet));
    }
  }
}
