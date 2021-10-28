import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geniuswallet/bloc/dex_tab_custom/dex_tab_custom_cubit.dart';

import 'package:geniuswallet/bloc/dex_tab_custom/dex_tab_custom_state.dart';
import 'package:geniuswallet/bloc/navigation_bloc/navigation_cubit.dart';
import 'package:geniuswallet/bloc/navigation_bloc/navigation_state.dart';

class DexTabCustom extends StatefulWidget {
  final Widget child;
  DexTabCustom({Key key, this.child}) : super(key: key);

  @override
  _DexTabCustomState createState() => _DexTabCustomState();
}

class _DexTabCustomState extends State<DexTabCustom> {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NavigationCubit, NavigationState>(
        builder: (context, state) {
      if (state is! InDex) {
        return GestureDetector(
          child: widget.child,
          onTap: () => context.read<NavigationCubit>().gotToDex(context),
        );
      }
      return widget.child;
    });
  }
}
