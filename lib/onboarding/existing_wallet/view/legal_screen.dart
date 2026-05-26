import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genius_wallet/bloc/app_bloc.dart';
import 'package:genius_wallet/utils/breakpoints.dart';
import 'package:genius_wallet/onboarding/existing_wallet/bloc/existing_wallet_bloc.dart';

class LegalScreen extends StatelessWidget {
  const LegalScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: GeniusBreakpoints.small * 2 / 3,
        child: Column(mainAxisSize: MainAxisSize.min, spacing: 20.0, children: [
          Text(
            "Legal",
            style: Theme.of(context).textTheme.headlineLarge,
          ),
          Text(
              'Please review the privacy policy and terms of service before proceeding.'),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () {},
              child: Text('Privacy Policy'),
            ),
          ),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () {},
              child: Text('Terms of Service'),
            ),
          ),
          CheckboxListTile(
            value: context.watch<ExistingWalletBloc>().state.acceptedLegal,
            onChanged: (value) =>
                context.read<ExistingWalletBloc>().add(ToggleLegal()),
            title: AutoSizeText(
              'I’ve read and accept the Terms of Service and Privacy Policy',
            ),
            controlAffinity: ListTileControlAffinity.leading,
          ),
          BlocBuilder<ExistingWalletBloc, ExistingWalletState>(
              builder: (context, state) {
            return SizedBox(
              width: double.infinity,
              child: FilledButton(
                  onPressed: state.acceptedLegal
                      ? () {
                          final userExists =
                              context.read<AppBloc>().state.userStatus ==
                                  UserStatus.exists;
                          context
                              .read<ExistingWalletBloc>()
                              .add(LegalAccepted(userExists: userExists));
                        }
                      : null,
                  child: Text("Continue")),
            );
          })
        ]),
      ),
    );
  }
}
