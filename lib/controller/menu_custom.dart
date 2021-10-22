import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geniuswallet/bloc/menu_custom/menu_custom_cubit.dart';

import 'package:geniuswallet/bloc/menu_custom/menu_custom_state.dart';

class MenuCustom extends StatefulWidget {
  final Widget child;
  MenuCustom({Key key, this.child}) : super(key: key);

  @override
  _MenuCustomState createState() => _MenuCustomState();
}

class _MenuCustomState extends State<MenuCustom> {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => MenuCustomCubit(MenuCustomInitial()),
      child: BlocBuilder<MenuCustomCubit, MenuCustomState>(
          builder: (context, state) {
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
