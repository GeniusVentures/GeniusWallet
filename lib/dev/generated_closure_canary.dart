// lib/dev/generated_closure_canary.dart
//
// WHAT THIS GATES
// -----------------
// `analysis_options.yaml:5` excludes `lib/**/*.g.dart` from `flutter analyze`.
// Phase 3 plan 03-04 ports 9 Parabeac-generated `.g.dart` widgets, and
// nothing reachable from `main.dart` imports any of them this phase (their
// real callers are all screens in un-ported phases) -- so even a full
// `flutter build`/`flutter run` would not compile them at all. Without this
// file, the 9 generated widgets and their 4 additive `custom/` siblings land
// completely unchecked by anything: not the analyzer (config exclude), not
// the compiler (unreachable), not a test (no test harness in this repo).
//
// This file is a plain `.dart` file, NOT `.g.dart`, so the exclude does not
// apply to it. The analyzer will not check inside the 9 generated files
// directly, but it fully checks this file's references INTO them. An
// unresolvable import, a missing class, a renamed symbol, or a constructor
// whose signature moved all become hard `flutter analyze` errors here,
// turning "the analyzer cannot see these" into "the analyzer type-checks
// every entry point into these".
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
// `wallets_overview.g.dart` declares `WalletsOverview`/`WalletsOverviewState`,
// the same class names as develop's `lib/components/wallet_overview.dart`
// (GAP-06, Phase 5). See `.planning/phases/03-gw-component-library/03-SHADOW-NAMES.md`
// for the full writeup. This canary is the ONE permitted importer of the
// shadow path, allowlisted explicitly in `tool/verify_additive_boundary.sh`'s
// WalletsOverview pair check. Do not add a second importer.

import 'package:flutter/material.dart';

import 'package:genius_wallet/components/continue_button/isactive_false.g.dart';
import 'package:genius_wallet/components/continue_button/isactive_true.g.dart';
import 'package:genius_wallet/components/genius_back_button.g.dart';
import 'package:genius_wallet/components/incorrect_pin.g.dart';
import 'package:genius_wallet/components/recoveryword.g.dart';
import 'package:genius_wallet/components/registration_header.g.dart';
import 'package:genius_wallet/components/wallet_information.g.dart';
import 'package:genius_wallet/components/wallet_preview.g.dart';
import 'package:genius_wallet/components/wallets_overview.g.dart';

import 'package:genius_wallet/components/custom/genius_back_button_custom.dart';
import 'package:genius_wallet/components/custom/isactive_false_custom.dart';
import 'package:genius_wallet/components/custom/isactive_true_custom.dart';
import 'package:genius_wallet/components/custom/wallet_agreement_custom.dart';

/// Every public class the 9 generated `.g.dart` files + 4 additive
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
