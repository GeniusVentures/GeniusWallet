import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genius_wallet/dashboard/wallets/cubit/wallet_details_cubit.dart';
import 'package:go_router/go_router.dart';

class BuyButtonCustom extends StatefulWidget {
  final Widget? child;
  BuyButtonCustom({
    Key? key,
    this.child,
  }) : super(key: key);

  @override
  _BuyButtonCustomState createState() => _BuyButtonCustomState();
}

class _BuyButtonCustomState extends State<BuyButtonCustom> {
  @override
  Widget build(BuildContext context) {
    return MaterialButton(
      onPressed: () {
        context.push('/buy', extra: context.read<WalletDetailsCubit>());
      },
      child: widget.child!,
    );
  }
}
