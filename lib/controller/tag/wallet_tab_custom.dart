import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geniuswallet/bloc/navigation_bloc/navigation_cubit.dart';
import 'package:geniuswallet/bloc/navigation_bloc/navigation_state.dart';
import 'package:geniuswallet/bloc/wallet_tab_custom/wallet_tab_custom_cubit.dart';

import 'package:geniuswallet/bloc/wallet_tab_custom/wallet_tab_custom_state.dart';

class WalletTabCustom extends StatefulWidget {
  final Widget child;
  WalletTabCustom({Key key, this.child}) : super(key: key);

  @override
  _WalletTabCustomState createState() => _WalletTabCustomState();
}

class _WalletTabCustomState extends State<WalletTabCustom> {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NavigationCubit, NavigationState>(
        builder: (context, state) {
      if (state is! InWallet) {
        return GestureDetector(
          child: widget.child,
          onTap: () => context.read<NavigationCubit>().goToWallet(context),
        );
      }
      return widget.child;
    });
  }
}
