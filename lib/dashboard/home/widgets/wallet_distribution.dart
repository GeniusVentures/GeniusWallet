// TODO: build out the wallet balance distributions screen
// https://www.figma.com/design/7T7GiBEszjus4tpyOAiPaI/GNUS-FInal-Build?node-id=238-7949&m=dev
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genius_wallet/app/bloc/app_bloc.dart';
import 'package:genius_wallet/theme/genius_wallet_colors.g.dart';
import 'package:genius_wallet/theme/genius_wallet_consts.dart';

class WalletDistribution extends StatelessWidget {
  const WalletDistribution({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AppBloc, AppState>(builder: (context, state) {
      return Container(
          decoration: const BoxDecoration(
            color: GeniusWalletColors.deepBlueCardColor,
            borderRadius: BorderRadius.all(
                Radius.circular(GeniusWalletConsts.borderRadiusCard)),
          ),
          child: Center(
            child: Text('Coming Soon'),
          ));
    });
  }
}
