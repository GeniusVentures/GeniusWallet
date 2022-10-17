import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genius_api/genius_api.dart';
import 'package:genius_wallet/app/bloc/verification_cubit.dart';
import 'package:genius_wallet/dashboard/wallets/cubit/wallet_cubit.dart';
import 'package:genius_wallet/dashboard/wallets/send/cubit/send_cubit.dart';
import 'package:genius_wallet/dashboard/wallets/send/routes/send_flow.dart';

class SendButtonCustom extends StatefulWidget {
  final Widget? child;
  SendButtonCustom({
    Key? key,
    this.child,
  }) : super(key: key);

  @override
  _SendButtonCustomState createState() => _SendButtonCustomState();
}

class _SendButtonCustomState extends State<SendButtonCustom> {
  @override
  Widget build(BuildContext context) {
    final walletCubit = context.read<WalletCubit>();
    return MaterialButton(
      onPressed: () {
        Navigator.of(context).push(MaterialPageRoute(builder: (context) {
          return MultiBlocProvider(
            providers: [
              BlocProvider(
                create: (context) => SendCubit(
                  initialState: SendState(
                    currentTransaction: Transaction(
                      fromAddress: walletCubit.state.selectedWallet!.address,
                      toAddress: '',
                      amount: '',
                      fees: '',
                      timeStamp: '',
                      transactionDirection: TransactionDirection.sent,
                    ),
                  ),
                ),
              ),
              BlocProvider.value(
                value: walletCubit,
              ),
              BlocProvider(
                  create: (context) =>
                      VerificationCubit(geniusApi: context.read<GeniusApi>())),
            ],
            child: const SendFlow(),
          );
        }));
      },
      child: widget.child!,
    );
  }
}
