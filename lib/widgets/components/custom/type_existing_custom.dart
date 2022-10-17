import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genius_api/genius_api.dart';
import 'package:genius_wallet/onboarding/existing_wallet/bloc/existing_wallet_bloc.dart';
import 'package:genius_wallet/onboarding/existing_wallet/routes/existing_wallet_flow.dart';

class TypeExistingCustom extends StatefulWidget {
  final Widget? child;
  const TypeExistingCustom({
    Key? key,
    this.child,
  }) : super(key: key);

  @override
  _TypeExistingCustomState createState() => _TypeExistingCustomState();
}

class _TypeExistingCustomState extends State<TypeExistingCustom> {
  @override
  Widget build(BuildContext context) {
    return MaterialButton(
      onPressed: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => BlocProvider(
              create: (context) => ExistingWalletBloc(
                geniusApi: context.read<GeniusApi>(),
              ),
              child: const ExistingWalletFlow(),
            ),
          ),
        );
      },
      child: widget.child!,
    );
  }
}
