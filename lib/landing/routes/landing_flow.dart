// import 'package:flow_builder/flow_builder.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:genius_wallet/landing/bloc/landing_bloc.dart';
// import 'package:genius_wallet/landing/bloc/landing_state.dart';
// import 'package:genius_wallet/landing/view/backup_phrase_screen.dart';
// import 'package:genius_wallet/landing/existing_wallet/existing_wallet/confirm_passcode_screen.dart';
// import 'package:genius_wallet/landing/existing_wallet/existing_wallet/create_passcode_screen.dart';
// import 'package:genius_wallet/landing/existing_wallet/existing_wallet/import_security_screen.dart';
// import 'package:genius_wallet/landing/existing_wallet/existing_wallet/legal_screen.dart';

// class LandingFlow extends StatelessWidget {
//   const LandingFlow({
//     Key? key,
//   }) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return FlowBuilder<LandingState>(
//       state: context.watch<LandingBloc>().state,
//       onGeneratePages: (state, pages) {
//         if (state is ExistingWallet) {
//           print(state.acceptedLegal);
//           return [
//             const MaterialPage(child: LegalScreen()),
//             if (state.acceptedLegal)
//               const MaterialPage(child: CreatePasscodeScreen()),
//             // const MaterialPage(child: ConfirmPasscodeScreen()),
//             // const MaterialPage(child: ImportSecurityScreen()),
//             // const MaterialPage(child: ImportSecurityScreen()),
//           ];
//         } else {
//           return [
//             MaterialPage(
//                 child: Container(
//               color: Colors.purple,
//             )),
//           ];
//         }
//       },
//     );
//   }
// }
