import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geniuswallet/bloc/about_button_custom/about_button_custom_cubit.dart';

import 'package:geniuswallet/bloc/about_button_custom/about_button_custom_state.dart';

class AboutButtonCustom extends StatefulWidget {
  final Widget child;
  AboutButtonCustom({Key key, this.child}) : super(key: key);

  @override
  _AboutButtonCustomState createState() => _AboutButtonCustomState();
}

class _AboutButtonCustomState extends State<AboutButtonCustom> {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => AboutButtonCustomCubit(AboutButtonCustomInitial()),
      child: BlocBuilder<AboutButtonCustomCubit, AboutButtonCustomState>(
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
