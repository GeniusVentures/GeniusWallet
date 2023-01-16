import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genius_wallet/app/bloc/app_bloc.dart';
import 'package:genius_wallet/app/utils/breakpoints.dart';
import 'package:genius_wallet/app/widgets/app_screen_with_header.dart';
import 'package:genius_wallet/onboarding/existing_wallet/bloc/existing_wallet_bloc.dart';
import 'package:genius_wallet/theme/genius_wallet_colors.g.dart';
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
          LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
              if (GeniusBreakpoints.useDesktopLayout(context)) {
                return const _LegalViewDesktop();
              }
              return const _LegalViewMobile();
            },
          ),
        ],
        footer: Builder(builder: (context) {
          if (!GeniusBreakpoints.useDesktopLayout(context)) {
            return const _Agreement();
          }
          return const SizedBox();
        }),
      ),
    );
  }
}

class _LegalViewMobile extends StatelessWidget {
  const _LegalViewMobile({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(
        minHeight: 50,
        minWidth: MediaQuery.of(context).size.width * 0.8,
        maxHeight: MediaQuery.of(context).size.width * 0.5,
        maxWidth: MediaQuery.of(context).size.width * 0.8,
      ),
      child: const _ToSButtons(),
    );
  }
}

class _LegalViewDesktop extends StatelessWidget {
  const _LegalViewDesktop({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: GeniusWalletColors.containerGray,
      width: 600,
      padding: const EdgeInsets.symmetric(
        vertical: 80,
        horizontal: 100,
      ),
      constraints: const BoxConstraints(minHeight: 500),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: const [
          _ToSButtons(),
          _Agreement(),
        ],
      ),
    );
  }
}

class _ToSButtons extends StatelessWidget {
  const _ToSButtons({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
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
    );
  }
}

class _Agreement extends StatelessWidget {
  const _Agreement({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          height: 30,
          width: MediaQuery.of(context).size.width * 0.8,
          child: LayoutBuilder(
            builder: (context, constraints) {
              return WalletAgreementCustom(
                value: context.watch<ExistingWalletBloc>().state.acceptedLegal,
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
                      final userExists =
                          context.read<AppBloc>().state.userStatus ==
                              UserStatus.exists;
                      context
                          .read<ExistingWalletBloc>()
                          .add(LegalAccepted(userExists: userExists));
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
    );
  }
}
