import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geniuswallet/bloc/navigation_bloc/navigation_cubit.dart';
import 'package:geniuswallet/bloc/navigation_bloc/navigation_state.dart';

class SettingsTab extends StatefulWidget {
  final Widget child;
  SettingsTab({Key key, this.child}) : super(key: key);

  @override
  _SettingsTabState createState() => _SettingsTabState();
}

class _SettingsTabState extends State<SettingsTab> {
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
