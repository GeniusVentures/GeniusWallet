import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genius_wallet/bloc/app_bloc.dart';
import 'package:genius_wallet/utils/breakpoints.dart';
import 'package:genius_wallet/components/app_screen_with_header_desktop.dart';
import 'package:genius_wallet/components/app_screen_with_header_mobile.dart';
import 'package:genius_wallet/components/desktop_body_container.dart';
import 'package:genius_wallet/onboarding/existing_wallet/bloc/existing_wallet_bloc.dart';
import 'package:genius_wallet/components/continue_button/isactive_false.g.dart';
import 'package:genius_wallet/components/continue_button/isactive_true.g.dart';
import 'package:genius_wallet/components/custom/wallet_agreement_custom.dart';
import 'package:genius_wallet/components/wallet_button/type_existing.g.dart';

class LegalScreen extends StatelessWidget {
  static const title = 'Legal';
  static const subtitle =
      'Please review the Privacy Policy and Terms of Service of the GNUS wallet before proceeding';
  const LegalScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          if (GeniusBreakpoints.useDesktopLayout(context)) {
            return const _LegalViewDesktop(
              title: title,
              subtitle: subtitle,
            );
          }
          return const _LegalViewMobile(
            title: title,
            subtitle: subtitle,
          );
        },
      ),
    );
  }
}

class _LegalViewMobile extends StatelessWidget {
  final String title;
  final String subtitle;
  const _LegalViewMobile({
    Key? key,
    required this.title,
    required this.subtitle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppScreenWithHeaderMobile(
      title: title,
      subtitle: subtitle,
      body: ConstrainedBox(
        constraints: BoxConstraints(
          minHeight: 50,
          minWidth: MediaQuery.of(context).size.width * 0.8,
          maxHeight: MediaQuery.of(context).size.width * 0.8,
          maxWidth: MediaQuery.of(context).size.width * 0.8,
        ),
        child: const _ToSButtons(),
      ),
      footer: const _Agreement(),
    );
  }
}

class _LegalViewDesktop extends StatelessWidget {
  final String title;
  final String subtitle;
  const _LegalViewDesktop({
    Key? key,
    required this.title,
    required this.subtitle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppScreenWithHeaderDesktop(
      title: '',
      subtitle: '',
      body: Center(
        child: DesktopBodyContainer(
          title: title,
          subText: subtitle,
          height: 500,
          width: 420,
          child: const Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _ToSButtons(),
              _Agreement(),
            ],
          ),
        ),
      ),
    );
  }
}

class _ToSButtons extends StatelessWidget {
  const _ToSButtons({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
        width: 300,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.8,
              height: 50,
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
              width: MediaQuery.of(context).size.width * 0.8,
              height: 50,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return TypeExisting(
                    constraints,
                    ovrIalreadyhaveawallet: 'Terms of Service',
                  );
                },
              ),
            ),
            const SizedBox(height: 10),
          ],
        ));
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
          height: 100,
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
        const SizedBox(height: 10),
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
