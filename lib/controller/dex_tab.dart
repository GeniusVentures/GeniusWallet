import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:geniuswallet/bloc/navigation_bloc/navigation_cubit.dart';
import 'package:geniuswallet/bloc/navigation_bloc/navigation_state.dart';

class DexTab extends StatefulWidget {
  final Widget child;
  DexTab({Key key, this.child}) : super(key: key);

  @override
  _DexTabState createState() => _DexTabState();
}

class _DexTabState extends State<DexTab> {
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
