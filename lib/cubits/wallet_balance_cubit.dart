import 'package:flutter_bloc/flutter_bloc.dart';

class WalletBalanceCubit extends Cubit<WalletBalanceModel> {
  WalletBalanceCubit() : super(WalletBalanceModel());
}

class WalletBalanceModel {
  var balance = 0.00;
}
