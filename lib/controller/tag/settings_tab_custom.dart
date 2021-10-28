import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geniuswallet/bloc/navigation_bloc/navigation_cubit.dart';
import 'package:geniuswallet/bloc/navigation_bloc/navigation_state.dart';
import 'package:geniuswallet/bloc/settings_tab_custom/settings_tab_custom_cubit.dart';

import 'package:geniuswallet/bloc/settings_tab_custom/settings_tab_custom_state.dart';

class SettingsTabCustom extends StatefulWidget {
  final Widget child;
  SettingsTabCustom({Key key, this.child}) : super(key: key);

  @override
  _SettingsTabCustomState createState() => _SettingsTabCustomState();
}

class _SettingsTabCustomState extends State<SettingsTabCustom> {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NavigationCubit, NavigationState>(
        builder: (context, state) {
      if (state is! InSettings) {
        return GestureDetector(
            child: widget.child,
            onTap: () {
              context.read<NavigationCubit>().goToSettings(context);
            });
      }
      return widget.child;
    });
  }
}
