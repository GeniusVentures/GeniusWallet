// lib/dev/generated_closure_canary.dart
//
// WHAT THIS GATES
// -----------------
// Phase 3 plan 03-04 ported 9 Parabeac-scaffolded widgets under paths ending
// `.g.dart`, which made `analysis_options.yaml:5`'s `lib/**/*.g.dart` exclude
// hide them from `flutter analyze` entirely. Phase 22 plan 03 (this plan)
// renamed all 9 to plain `.dart` paths -- they were always hand-maintained
// production widgets, not output of a regeneration pipeline, and the
// generated-looking suffix was a naming defect, not a true generated-code
// marker. They are now fully covered by `flutter analyze` like any other
// file under `lib/components/`.
//
// This canary predates that rename and is kept for what it still proves:
// nothing reachable from `main.dart` imports these 9 widgets or their 4
// additive `custom/` siblings this phase (their real callers are all screens
// in un-ported phases), so even a full `flutter build`/`flutter run` would
// not compile them at all without this file forcing the import. The
// analyzer now checks their bodies directly (via the rename), and this file
// additionally forces every entry point INTO them to resolve: an
// unresolvable import, a missing class, a renamed symbol, or a constructor
// whose signature moved all become hard `flutter analyze` errors here too.
//
// WHAT THIS DOES NOT PROVE
// --------------------------
// That any of these 9 widgets renders correctly. No `build()` is called and
// no widget is mounted anywhere in this file -- it is a compile/analyze gate,
// not a render test. Correctness of rendering is established by whichever
// later phase first mounts each widget (Phase 5/6/7 per 03-UI-SPEC.md §2.8).
// Claiming render correctness from this file would be exactly the unearned
// PASS 02-VERIFICATION.md was written to prevent.
//
// DEV-ONLY
// ---------
// This file lives under lib/dev/ and is never imported from anything
// reachable in a release build. Plan 03-07 imports it from the design
// gallery (itself dev-gated, see lib/dev/dev_flags.dart's kShowDevTools),
// which makes the generated set reachable from an entry point -- upgrading
// the gate again, from "analyzer resolves the symbols" to "the Dart
// front-end compiles the generated libraries' bodies for real" during
// `flutter run`. Do not make this file reachable from anything that is not
// dev-gated.
//
// THE WalletsOverview SHADOW
// -----------------------------
// `wallets_overview.dart` declares `WalletsOverview`/`WalletsOverviewState`,
// the same class names as develop's `lib/components/wallet_overview.dart`
// (GAP-06, Phase 5). See `.planning/phases/03-gw-component-library/03-SHADOW-NAMES.md`
// for the full writeup. This canary is the ONE permitted importer of the
// shadow path, allowlisted explicitly in `tool/verify_additive_boundary.sh`'s
// WalletsOverview pair check. Do not add a second importer.

import 'package:flutter/material.dart';

import 'package:genius_wallet/components/continue_button/isactive_false.dart';
import 'package:genius_wallet/components/continue_button/isactive_true.dart';
import 'package:genius_wallet/components/genius_back_button.dart';
import 'package:genius_wallet/components/incorrect_pin.dart';
import 'package:genius_wallet/components/recoveryword.dart';
import 'package:genius_wallet/components/registration_header.dart';
import 'package:genius_wallet/components/wallet_information.dart';
import 'package:genius_wallet/components/wallet_preview.dart';
import 'package:genius_wallet/components/wallets_overview.dart';

import 'package:genius_wallet/components/custom/genius_back_button_custom.dart';
import 'package:genius_wallet/components/custom/isactive_false_custom.dart';
import 'package:genius_wallet/components/custom/isactive_true_custom.dart';
import 'package:genius_wallet/components/custom/wallet_agreement_custom.dart';

/// Every public class the 9 renamed Parabeac-scaffolded widget files + 4 additive
/// `custom/` siblings export, referenced by `Type` literal. A `Type`
/// literal resolves the symbol and forces the declaring library to be
/// imported and analyzed, without needing to satisfy constructors that
/// require live dependencies (e.g. `WalletsOverview`'s `GeniusApi`).
/// Read from each ported file directly -- not guessed from the filename.
const List<Type> generatedClosureClasses = <Type>[
  // The 9 Parabeac-generated widgets (plus their public State classes,
  // where the source declares them public rather than private).
  IsactiveFalse,
  IsactiveTrue,
  GeniusBackButton,
  IncorrectPin,
  Recoveryword,
  RegistrationHeader,
  WalletInformation,
  WalletInformationState,
  WalletPreview,
  WalletPreviewState,
  WalletsOverview, // shadow -- see header note above and 03-SHADOW-NAMES.md
  WalletsOverviewState,

  // The 4 additive hand-written `custom/` siblings.
  GeniusBackButtonCustom,
  IsactiveFalseCustom,
  IsactiveTrueCustom,
  WalletAgreementCustom,
];

/// Where a constructor is trivially satisfiable without a live
/// `BuildContext` or external dependency (a `BlocProvider`-supplied cubit,
/// `GeniusApi`, ...), a `Widget Function()` closure additionally forces the
/// analyzer to check the constructor's parameter list against a real call
/// site -- upgrading the gate from "class exists" to "constructor signature
/// is what callers expect". None of these closures is ever called; nothing
/// here is mounted. `WalletsOverview` requires a live `GeniusApi` and
/// `Account` and is deliberately NOT included here -- the `Type` literal
/// above is its only gate this plan, per the file header's "what this does
/// not prove".
final List<Widget Function()> generatedClosureConstructors =
    <Widget Function()>[
  () => const IsactiveFalseCustom(),
  () => const IsactiveTrueCustom(),
  () => const GeniusBackButtonCustom(),
  () => const WalletAgreementCustom(),
  () => const IsactiveFalse(BoxConstraints()),
  () => const IsactiveTrue(BoxConstraints()),
  () => const GeniusBackButton(BoxConstraints()),
  () => const IncorrectPin(BoxConstraints()),
  () => const Recoveryword(BoxConstraints()),
  () => const RegistrationHeader(BoxConstraints()),
  () => const WalletPreview(),
  () => WalletInformation(const BoxConstraints(), ovrAddressField: '0x0'),
];
