import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geniuswallet/bloc/menu/menu_cubit.dart';

import 'package:geniuswallet/bloc/menu/menu_state.dart';

class Menu extends StatefulWidget {
  final Widget child;
  Menu({Key key, this.child}) : super(key: key);

  @override
  _MenuState createState() => _MenuState();
}

class _MenuState extends State<Menu> {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => MenuCubit(MenuInitial()),
      child: BlocBuilder<MenuCubit, MenuState>(builder: (context, state) {
        /// TODO: @developer implement bloc and map the states to widgets as desired.
        /// For example, in a counter app you may have something like
        ///
        /// if(state is CounterInProgress){
        ///   return Text('${state.value}');
        /// } else {
        ///   return Text('0');
        /// }
        return widget.child;
      }),
    );
  }
}
