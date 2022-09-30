import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genius_wallet/landing/new_wallet/bloc/new_wallet_bloc.dart';
import 'package:genius_wallet/landing/new_wallet/routes/new_wallet_flow.dart';

class TypeCreateCustom extends StatefulWidget {
  final Widget? child;
  TypeCreateCustom({
    Key? key,
    this.child,
  }) : super(key: key);

  @override
  _TypeCreateCustomState createState() => _TypeCreateCustomState();
}

class _TypeCreateCustomState extends State<TypeCreateCustom> {
  @override
  Widget build(BuildContext context) {
    return MaterialButton(
      onPressed: () => Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => BlocProvider(
            create: (context) => NewWalletBloc(),
            child: const NewWalletFlow(),
          ),
        ),
      ),
      child: widget.child,
    );
  }
}
