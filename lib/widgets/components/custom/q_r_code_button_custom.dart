import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genius_wallet/dashboard/wallets/cubit/wallet_details_cubit.dart';
import 'package:go_router/go_router.dart';

class QRCodeButtonCustom extends StatefulWidget {
  final Widget? child;
  const QRCodeButtonCustom({
    Key? key,
    this.child,
  }) : super(key: key);

  @override
  _QRCodeButtonCustomState createState() => _QRCodeButtonCustomState();
}

class _QRCodeButtonCustomState extends State<QRCodeButtonCustom> {
  @override
  Widget build(BuildContext context) {
    return MaterialButton(
      onPressed: () {
        context.push('/receive', extra: context.read<WalletDetailsCubit>());
      },
      child: widget.child!,
    );
  }
}
