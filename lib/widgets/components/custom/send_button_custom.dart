import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genius_wallet/dashboard/wallets/cubit/wallet_details_cubit.dart';
import 'package:go_router/go_router.dart';

class SendButtonCustom extends StatefulWidget {
  final Widget? child;
  const SendButtonCustom({
    Key? key,
    this.child,
  }) : super(key: key);

  @override
  _SendButtonCustomState createState() => _SendButtonCustomState();
}

class _SendButtonCustomState extends State<SendButtonCustom> {
  @override
  Widget build(BuildContext context) {
    final walletCubit = context.read<WalletDetailsCubit>();
    return MaterialButton(
      onPressed: () {
        context.push('/send', extra: walletCubit);
      },
      child: widget.child!,
    );
  }
}
