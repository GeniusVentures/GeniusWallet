import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geniuswallet/bloc/navigation_bloc/navigation_cubit.dart';
import 'package:geniuswallet/bloc/navigation_bloc/navigation_state.dart';

class WalletTab extends StatefulWidget {
  final Widget child;
  WalletTab({Key key, this.child}) : super(key: key);

  @override
  _WalletTabState createState() => _WalletTabState();
}

class _WalletTabState extends State<WalletTab> {
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
