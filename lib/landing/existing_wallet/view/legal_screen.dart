import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genius_wallet/app/widgets/app_screen_with_header.dart';
import 'package:genius_wallet/landing/existing_wallet/bloc/existing_wallet_bloc.dart';
import 'package:genius_wallet/widgets/components/continue_button/isactive_false.g.dart';
import 'package:genius_wallet/widgets/components/continue_button/isactive_true.g.dart';
import 'package:genius_wallet/widgets/components/custom/wallet_agreement_custom.dart';
import 'package:genius_wallet/widgets/components/wallet_button/type_existing.g.dart';

class LegalScreen extends StatelessWidget {
  const LegalScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AppScreenWithHeader(
        title: 'Legal',
        subtitle:
            'Please review the Privacy Policy and Terms of Service of the GNUS wallet before proceeding',
        bodyWidgets: [
          ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: 50,
              minWidth: MediaQuery.of(context).size.width * 0.8,
              maxHeight: MediaQuery.of(context).size.width * 0.5,
              maxWidth: MediaQuery.of(context).size.width * 0.8,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  height: 50,
                  width: MediaQuery.of(context).size.width * 0.8,
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      return TypeExisting(
                        constraints,
                        ovrIalreadyhaveawallet: 'Privacy Policy',
                      );
                    },
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  height: 50,
                  width: MediaQuery.of(context).size.width * 0.8,
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      return TypeExisting(
                        constraints,
                        ovrIalreadyhaveawallet: 'Terms of Service',
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
        footer: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              height: 30,
              width: MediaQuery.of(context).size.width * 0.8,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return WalletAgreementCustom(
                    value:
                        context.watch<ExistingWalletBloc>().state.acceptedLegal,
                    onChanged: (value) =>
                        context.read<ExistingWalletBloc>().add(ToggleLegal()),
                  );
                },
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.8,
              height: 50,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return BlocBuilder<ExistingWalletBloc, ExistingWalletState>(
                      builder: (context, state) {
                    if (state.acceptedLegal) {
                      return MaterialButton(
                        onPressed: () {
                          context
                              .read<ExistingWalletBloc>()
                              .add(ChangeStep(step: FlowStep.importWallet));
                        },
                        child: IsactiveTrue(constraints),
                      );
                    }
                    return IsactiveFalse(constraints);
                  });
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
