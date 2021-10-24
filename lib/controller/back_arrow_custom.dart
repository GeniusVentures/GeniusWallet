import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geniuswallet/bloc/back_arrow_custom/back_arrow_custom_cubit.dart';

import 'package:geniuswallet/bloc/back_arrow_custom/back_arrow_custom_state.dart';

class BackArrowCustom extends StatefulWidget {
  final Widget child;
  BackArrowCustom({Key key, this.child}) : super(key: key);

  @override
  _BackArrowCustomState createState() => _BackArrowCustomState();
}

class _BackArrowCustomState extends State<BackArrowCustom> {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => BackArrowCustomCubit(BackArrowCustomInitial()),
      child: BlocBuilder<BackArrowCustomCubit, BackArrowCustomState>(
          builder: (context, state) {
        return GestureDetector(
          child: widget.child,
          onTap: () => Navigator.of(context).pop(),
        );
      }),
    );
  }
}
