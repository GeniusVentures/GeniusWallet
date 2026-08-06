---
name: review-pr
description: Use when reviewing a pull request on GeniusWallet — the project rules a reviewer checks against, in the order they cause real damage.
---

# Reviewing a PR

Check the diff against these, hardest consequence first. `AGENTS.md` is the
full rule set; this is what a reviewer actually looks for.

## Wallet safety — none of these are style preferences

- A private key or mnemonic **must not** be a field on a Cubit/Bloc state
  class. States are equatable, printable, and reach `BlocObserver` logs.
- Nothing derived from a seed phrase or key gets logged, `toString()`d or sent
  to Sentry.
- `Random.secure()` only. A plain `Random()` in key generation is how a real
  Flutter wallet shipped a 32-bit key.
- Prefer `Uint8List` over `String` for secrets — a `String` is immutable and
  cannot be zeroed.
- Anything holding key material must be disposed, and disposed by an owner
  that can (a `StatelessWidget` cannot).

## Correctness the tests will not catch

- **Does it work on mobile?** `android/` and `ios/` are real targets. Platform
  APIs behave differently — e.g. from Android API 29 an app without focus can
  neither read nor write the clipboard, so a background timer touching it does
  nothing at all.
- **Does a test pin the defect instead of the fix?** A passing assertion can
  be holding a bug in place. Ask what the test would do if the bug were fixed.
- **Does a test anchor on an accident?** Locating a widget by error text that
  only appears because a fetch failed will break the moment the fetch works.

## Accessibility — explicitly not something this repo is lazy about

- Every interactive control reachable and operable from a keyboard
  (WCAG 2.1.1, Level A). A bare `GestureDetector` is not.
- Colour contrast meets AA in **both** appearance modes and in every state.
  Light mode is where this repo has historically broken.
- Disabled states stay visibly distinct.

## Design system

- Colours and spacing from tokens, via `Theme.of(context).extension<GWColors>()`.
  No `Colors.*` or `Color(0x…)` outside `lib/theme/` — `Colors.transparent` is
  the one permitted exception.
- Never cache a theme-derived value in a long-lived object; re-read it in
  `build`.
- Extract a `StatelessWidget`, never a `_buildFoo()` returning a `Widget`.
- Widgets do not reach past the repository layer: no `Hive.box`, `File`,
  `http` or direct SDK calls in a widget or its `State`. Go through a
  bloc/cubit.

## Shape of the change

- **Was it needed at all?** YAGNI. Then: does the stdlib do it? A native
  platform feature? An already-installed dependency? Only then write it.
  Reimplementing something Material already provides is the common miss.
- **Rule of Three.** Two occurrences do not justify a shared component; three
  do. If the shared version needs a boolean flag to serve both callers, or you
  cannot name it clearly, it should not exist.
- **Braces on every `if`**, body on its own line. `tool/check_brace_style.sh`
  enforces it.
- **Intentional shortcuts carry a `ponytail:` comment** naming the ceiling and
  the upgrade path.
- **Comment length in proportion to the code.** A 7-line function does not
  need 27 lines of preamble; that history belongs in the commit message.

## Verification

The PR must state a baseline someone actually ran — `dart format`,
`flutter analyze`, `flutter test`, and the `tool/*.sh` gates. Treat an
unquoted claim as unverified.

## How to give the feedback

Say what is wrong and why it matters, in a sentence or two. A short question
often lands better than an assertion — "Does this work on mobile?" found a
real bug in PR #222 in six words. Reserve blocking for things that break
users, security or accessibility; everything else is a comment.
