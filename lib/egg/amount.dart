import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:geniuswallet/cubits/wallet_balance_cubit.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class Amount extends StatefulWidget {
  final Widget child;
  Amount({Key key, this.child}) : super(key: key);

  @override
  _AmountState createState() => _AmountState();
}

class _AmountState extends State<Amount> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Stack(children: [
        Positioned(
          left: 0,
          width: MediaQuery.of(context).size.width * 0.893,
          top: 0,
          height: MediaQuery.of(context).size.height * 0.193,
          child: Container(
            width: MediaQuery.of(context).size.width * 335.000,
            height: MediaQuery.of(context).size.height * 54.000,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(0)),
            ),
          ),
        ),
        Positioned(
          left: 0,
          width: MediaQuery.of(context).size.width * 0.893,
          top: 0,
          height: MediaQuery.of(context).size.height * 0.193,
          child: Container(
              width: 335.0,
              height: 50,
              child: Container(
                  child: AutoSizeText(
                "\$ ${context.watch<WalletBalanceCubit>().state.balance.toString()}",
                style: TextStyle(
                  fontFamily: 'Prompt',
                  fontSize: 36.0,
                  fontWeight: FontWeight.w700,
                  fontStyle: FontStyle.normal,
                  letterSpacing: 0.0,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ))),
        ),
      ]),
    );
  }
}
