import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genius_wallet/dashboard/wallets/cubit/wallet_details_cubit.dart';
import 'package:genius_wallet/widgets/components/copy_wallet_i_d.g.dart';

import 'package:flutter/material.dart';

class CopyWalletIDCustom extends StatefulWidget {
  final Widget? child;
  CopyWalletIDCustom({
    Key? key,
    this.child,
  }) : super(key: key);

  @override
  _CopyWalletIDCustomState createState() => _CopyWalletIDCustomState();
}

class _CopyWalletIDCustomState extends State<CopyWalletIDCustom> {
  @override
  Widget build(BuildContext context) {
    return MaterialButton(
      onPressed: () {
        context.read<WalletDetailsCubit>().copyWalletAddress();
      },
      child: widget.child!,
    );
  }
}
