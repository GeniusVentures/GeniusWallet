import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genius_api/genius_api.dart';
import 'package:genius_wallet/wallets/buy/bloc/buy_event.dart';

part 'buy_state.dart';

class BuyBloc extends Bloc<BuyEvent, BuyState> {
  final GeniusApi geniusApi;
  BuyBloc({
    required BuyState initialState,
    required this.geniusApi,
  }) : super(initialState) {
    on<ConvertCurrency>(
      onBuyEvent,
      transformer: restartable(),
    );
  }

  Future<void> onBuyEvent(ConvertCurrency event, Emitter emit) async {
    final fiatAmountNum = num.tryParse(event.amount) ?? 0.0;

    emit(state.copyWith(conversionStatus: ConversionStatus.loading));

    //   try {
    //     final cryptoConversion =
    //         await geniusApi.getConversion(fiatAmountNum, state.cryptoCurrency);
    //     emit(state.copyWith(
    //       approxCryptoConversion: cryptoConversion.toString(),
    //       conversionStatus: ConversionStatus.success,
    //     ));
    //   } catch (e) {
    //     emit(state.copyWith(conversionStatus: ConversionStatus.error));
    //   }
  }
}
