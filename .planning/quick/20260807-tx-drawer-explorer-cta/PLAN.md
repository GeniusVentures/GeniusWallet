---
phase: quick-260807-exp
plan: 01
type: execute
wave: 1
depends_on: []
files_modified:
  - lib/theme/genius_wallet_consts.dart
  - lib/components/bottom_drawer/responsive_drawer.dart
  - lib/components/overlay/responsive_overlay.dart
  - test/components/drawer_footer_inset_test.dart
  - lib/dashboard/home/widgets/transaction_displays.dart
autonomous: false
requirements: [QUICK-260807-EXP]

must_haves:
  truths:
    - "The transaction receipt drawer's footer no longer reserves the raw 34pt iOS home-indicator area below its button; the reserved amount is capped by the same rule the mobile tab bar already ships."
    - "Every drawer footer in the app gains the fix at once, because the inset is the shell's and not each caller's."
    - "The cap value exists in exactly ONE place in the codebase, so the tab bar and the drawer footer cannot drift apart."
    - "A test fails if the footer ever goes back to reserving the raw inset."
    - "The View on Explorer button's SIZE is not changed until Jakub picks an option, because the census proves the current size is the app-wide drawer footer standard rather than an outlier."
    - "Whatever is chosen, the button stays gradientOutline: hollow, one per surface, and the panel's only action."
  artifacts:
    - test/components/drawer_footer_inset_test.dart
  key_links:
    - "responsive_drawer.dart's footer reads the inset explicitly instead of wrapping in SafeArea, which is the pattern _MobileTabBar already uses at responsive_overlay.dart:282-285; if it reverts to SafeArea the new test fails."
    - "responsive_overlay.dart's _kMaxBottomInset is REPLACED by the shared constant rather than left beside it; two constants with the same job is the drift this task exists to prevent."
    - "test/components/drawer_padding_invariant_test.dart asserts per-call-site bodyPadding classification only. It does NOT read footer geometry and will NOT catch this change, which is why the new test is required."
---

<objective>
Two complaints Jakub raised on his iPhone about the transaction receipt drawer, which
have two different causes and deserve two different answers.

The dead space under the View on Explorer button is a measured defect with a known root
cause, already diagnosed and fixed once this session in the mobile tab bar. It gets
fixed here, in the shell, for every drawer at once.

The button being "too big" is not a defect. The census below proves this button is
exactly what every other single-action drawer footer in the app is, and that the code
comment above it is still true. Changing it is a design decision with app-wide
consequences, so it goes to Jakub as a decision with a stated recommendation rather than
being quietly applied.

Purpose: Jakub, 2026-08-07, live on his iPhone. Verbatim: "jak klikne w transactions, to
mam taki duzy CTA view on explorer. Chcialbym, zeby ten CTA byl wielkosci CTA, ktory jest
normalnie na dashboardzie w sekcji assets: receive albo buy genius. Dodatkowo, ten CTA
jest znacznie wyzej; jest jakis taki duzy padding od spodu. Mysle, ze to jest to samo, co
jest na homepage, bylo z navigation bottom barem, wiec dostosuj go rowniez."

Output: one shell fix, one shared constant, one guard test, one decision put to Jakub,
and a blocking on-device check against the exact buttons he named as the reference.
</objective>

<execution_context>
@$HOME/.claude/gsd-core/workflows/execute-plan.md
@$HOME/.claude/gsd-core/templates/summary.md
</execution_context>

<context>
@AGENTS.md
@lib/components/bottom_drawer/responsive_drawer.dart
@lib/components/overlay/responsive_overlay.dart
@lib/dashboard/home/widgets/transaction_displays.dart
@lib/components/buttons/gw_button.dart
@lib/components/coins/view/coins_screen.dart
@lib/dashboard/assets/assets_screen.dart
@test/components/drawer_padding_invariant_test.dart
</context>

<findings>

## What was measured against the real source before planning

Everything below was read from the tree on `redesign/navigation-260806`. Three claims in
the briefing turned out to be wrong and are corrected here, because the plan is built on
what the code does rather than on what it was believed to do.

### 1. The dead space: the mechanism, named, and the number

The footer pays the bottom inset TWICE over, through two layers that stack.

**Layer one, the modal route.** `ResponsiveDrawer.show` opens the mobile branch with
`showModalBottomSheet(..., useSafeArea: true)` (`responsive_drawer.dart:167`). It is
natural to assume `useSafeArea: true` protects the bottom. It does not. Verified in the
pinned SDK at `/Users/jakub/development/flutter/packages/flutter/lib/src/material/bottom_sheet.dart:1121-1123`:

```
Widget bottomSheet = useSafeArea
    ? SafeArea(bottom: false, child: content)
    : MediaQuery.removePadding(context: context, removeTop: true, child: content);
```

`bottom: false`. So the route neither consumes the bottom padding nor strips it from the
MediaQuery. The full value passes straight through to whatever the sheet builds.

**Layer two, the shell's own footer.** `_ResponsiveDrawerScaffold` puts the footer in
`bottomNavigationBar` wrapped in a second SafeArea (`responsive_drawer.dart:327-336`):

```
bottomNavigationBar: footer != null
    ? SafeArea(
        top: false,
        child: Container(
          padding: kDrawerFooterPadding,
          ...
```

This one has no `bottom: false`, so it consumes the whole thing. And
`kDrawerFooterPadding` is `EdgeInsets.all(GeniusWalletConsts.space10)` = 20 on every side
(`responsive_drawer.dart:43-45`).

**The arithmetic.** On Jakub's iPhone `viewPadding.bottom` is 34.

| region | value | source |
|---|---|---|
| above the button | 20 | `kDrawerFooterPadding` top |
| button | 56 | `GWButtonSize.lg`, `gw_button.dart:89-90` |
| below the button, footer pad | 20 | `kDrawerFooterPadding` bottom |
| below the button, SafeArea | 34 | raw `viewPadding.bottom` |
| **total below the button** | **54** | |

20 above, 54 below. A 2.7 to 1 asymmetry under a single hollow button. That is the "duzy
padding od spodu", and it is a real defect rather than a taste question.

**Jakub's diagnosis is correct.** It is the same cause as the tab bar. That fix lives at
`responsive_overlay.dart:243` and `:282-285`: `_kMaxBottomInset = 20.0`, applied by
reading `MediaQuery.viewPaddingOf(context).bottom` explicitly instead of wrapping in a
SafeArea, then capping. Its own comment records the reasoning, which transfers here
without change: 34 is the area iOS reserves for the home indicator, not what the
indicator needs, since the indicator is a ~5pt bar whose top edge sits ~13pt above the
screen bottom. 20 clears it with room to spare. Devices with no indicator report 0 and
are untouched, because the cap only ever removes.

Capping the drawer footer the same way takes 54 down to 40 and recovers the same 14pt.

One detail worth carrying over: the tab bar reads `viewPaddingOf`, whereas SafeArea reads
`paddingOf`, which is viewPadding minus viewInsets. With the keyboard closed both are 34,
so this does not change today's number. `viewPaddingOf` is the better read anyway because
it keeps the footer stable rather than collapsing to 0 if a keyboard ever opens beneath
it.

### 2. The button size: the census, and why it changes the question

The briefing expected this button to be an outlier. It is the opposite. Every file
passing `footer:` to `ResponsiveDrawer.show`, 12 in total, 11 product plus the dev
gallery:

| file | footer shape | size |
|---|---|---|
| `dashboard/home/widgets/transaction_displays.dart:835` | 1 button, `expand: true`, gradientOutline | **lg** |
| `account/account_drawer.dart:55` | 1 button, `expand: true`, gradient | **lg** |
| `account/sdk_account_manager.dart:148` | 1 button, `expand: true`, gradient | **lg** |
| `squid_router/swap_settings_drawer.dart:99` | 1 button, `expand: true`, gradient | **lg** |
| `banxa/banxa_components/buy_success_drawer.dart:23` | 1 button, `expand: true`, gradient | **lg** |
| `banxa/banxa_components/buy_cancelled_drawer.dart:20` | 1 button, `expand: true`, gradientOutline | **lg** |
| `reown/approve_transaction_drawer.dart:74` | Row, 2 buttons | lg |
| `reown/approve_dapp_connection_drawer.dart:98` | Row, 2 buttons | lg |
| `reown/swap_result_drawer.dart:79` | Column, 2 buttons | lg |
| `screens/banxa_buy_screen.dart:1389` | composite order footer | lg |
| `submit_job/view/job_drawer.dart:56` | composite step footer | composite |
| `dev/design_gallery_screen.dart:787` | dev gallery demo | n/a |

**Six single-action drawer footers. Six of six are `lg` plus `expand: true`.** The
subject is not the odd one out on height or on width. The comment above it is still
accurate and the decision it records still holds.

**And "change every drawer footer" is not available in this task.** Of those six, three
sit under `lib/banxa` and `lib/squid_router`, which the constraints put out of bounds.
Touchable: `transaction_displays.dart`, `account_drawer.dart`, `sdk_account_manager.dart`.
Off limits: `swap_settings_drawer.dart`, `buy_success_drawer.dart`,
`buy_cancelled_drawer.dart`. A sweep would therefore split the six three and three, which
is a worse outcome than either extreme.

Note especially `buy_cancelled_drawer.dart`: gradientOutline, lg, `expand: true`, single
action. It is a structural twin of the subject, and it is one of the three that cannot be
touched.

### 3. Correction: the reference buttons ARE `expand: true`

The briefing states the Receive and Buy GNUS buttons are not `expand: true`. They are.
Both live in a Row of two `Expanded` children with a `space4` = 8 gap, which is what
halves them, and each still passes `expand: true` to fill its own half.

Both call sites are identical in shape:

- `lib/dashboard/assets/assets_screen.dart:496-515`, the /assets page.
- `lib/components/coins/view/coins_screen.dart:453-472`, the dashboard Assets panel.
  This one renders only when `isDashboard && total == 0`, so on a funded wallet Jakub is
  most likely looking at the /assets pair.

Both: `GWButtonSize.sm` = 44 (`gw_button.dart:85-86`), Receive is `gradientOutline`, Buy
GNUS is `gradient`.

So the real delta against the reference is 56 versus 44 in height, and full bleed versus
roughly half width. But the reference is a different archetype: an in-page panel CTA pair
sitting in a scrolling column, not a drawer footer pinned above the home indicator behind
a top rule. Jakub is asking for one archetype to adopt the other's metrics.

### 4. Correction: the census test will not catch this, and nothing else will either

`test/components/drawer_padding_invariant_test.dart` asserts two things: that the set of
files containing a `ResponsiveDrawer.show` call matches its hand-written census, and that
each call site's `bodyPadding` argument matches its classification. It pumps no widget
and reads no footer code. Editing the shell's footer changes neither the file set nor any
`bodyPadding` argument, so **that test will not fail and does not need updating**.

That is not reassuring, it is the gap. A scan of `test/` for `kDrawerFooterPadding`,
`bottomNavigationBar` and the button's label finds nothing covering drawer footer
geometry. The footer inset is currently unguarded, which is why Task 1 adds a test.

### 5. Baseline, verified

`flutter analyze` reports `No issues found!` on this branch as of now. `flutter test` is
recorded at 1077 passing. Task 1 adds cases, so the expected new total is 1077 plus the
number of cases added, with zero failures.

</findings>

<tasks>

<task type="auto">
  <name>Task 1: Cap the drawer footer's bottom inset in the shell, from one shared constant, with a test</name>
  <files>lib/theme/genius_wallet_consts.dart, lib/components/overlay/responsive_overlay.dart, lib/components/bottom_drawer/responsive_drawer.dart, test/components/drawer_footer_inset_test.dart</files>
  <behavior>
    - With `viewPadding.bottom` of 34, the drawer footer's total padding below its child is 40, not 54.
    - With `viewPadding.bottom` of 0, it is 20, unchanged from today.
    - With `viewPadding.bottom` of 12, it is 32: the cap removes and never adds.
    - The footer's top padding stays 20 in all three cases.
    - The top rule above the footer still paints.
  </behavior>
  <action>
Fix the measured defect from finding 1. Three edits and one new test.

**A. One constant, shared.** `_kMaxBottomInset` is private to `responsive_overlay.dart`,
and the drawer shell must not import a navigation file. Promote it to
`lib/theme/genius_wallet_consts.dart` as a public constant, named for what it does rather
than for the tab bar, for example `kMaxBottomSafeInset`. Value stays 20.0, which equals
`GeniusWalletConsts.space10` and is therefore already on the 4-pt grid with no exception
needed. Carry the existing reasoning into its doc comment: 34 is the area iOS reserves,
the indicator itself needs about 13, 20 clears it, devices without an indicator report 0.

Then DELETE `_kMaxBottomInset` from `responsive_overlay.dart` and point that file's read
site at the shared constant. Leaving both in place is the drift this task exists to
prevent, so the old private constant must not survive.

**B. The footer stops using SafeArea.** In `_ResponsiveDrawerScaffold.build`
(`responsive_drawer.dart:327-336`), replace the SafeArea wrapper around the footer
Container with an explicit capped read, which is exactly the pattern `_MobileTabBar`
already uses at `responsive_overlay.dart:282-285`. Read
`MediaQuery.viewPaddingOf(context).bottom`, clamp it down to the shared constant, and add
the result to the Container's existing bottom padding, leaving the other three sides at
`kDrawerFooterPadding`. Keep the Container's top border decoration untouched.

Use the SUM, so the result is the 20 design inset plus at most 20 of clearance, giving 40
below on Jakub's iPhone. This is the same arithmetic the tab bar shipped and the same
14pt recovery Jakub has already seen and approved. Do NOT take the max of the two, which
would give a symmetric 20 above and 20 below. That is a legitimate alternative worth
34pt, and it is offered to Jakub at the Task 4 checkpoint rather than assumed here.

Note in the comment that dropping SafeArea also stops the footer's descendants having
their bottom padding removed from the MediaQuery. Nothing in any current footer reads it,
which was checked, but the next author should know the wrapper did two jobs and only one
is being replaced.

**C. Guard it.** Create `test/components/drawer_footer_inset_test.dart`. Pump the drawer
scaffold with a footer inside a `MediaQuery` whose `MediaQueryData.viewPadding.bottom` is
34, then 0, then 12, and assert the gap between the footer child's bottom edge and the
footer's own bottom edge for each, per the behavior block. Prefer geometry assertions via
`tester.getRect` over reading a Padding widget's fields, so the test survives a
refactor that moves the inset between widgets. Assert the top inset stays 20 in the same
pass, which is what catches an edit that accidentally makes the padding symmetric.

Reach the scaffold the way the existing drawer tests do rather than inventing a new
harness. Check `test/components/drawer_body_padding_test.dart` and
`test/components/responsive_drawer_body_padding_test.dart` first and follow whichever
already pumps this shell.

Do NOT touch `test/components/drawer_padding_invariant_test.dart`. Per finding 4 it
asserts call-site `bodyPadding` classification only, its census set is unchanged by this
work, and editing it would weaken a gate that is currently correct.

Every comment written in this task uses a plain hyphen with spaces around it. No em
dashes, in code or in test names.
  </action>
  <verify>
    <automated>flutter test test/components/drawer_footer_inset_test.dart test/components/drawer_padding_invariant_test.dart test/components/drawer_body_padding_test.dart test/components/responsive_drawer_body_padding_test.dart</automated>
    <automated>flutter analyze</automated>
  </verify>
  <done>
`flutter analyze` reports no issues. The new test passes and the three existing drawer
padding tests still pass untouched. `grep -rn "_kMaxBottomInset" lib` returns nothing,
proving the constant was moved rather than duplicated.
  </done>
</task>

<task type="checkpoint:decision" gate="blocking">
  <decision>
Whether the View on Explorer button changes size, given that it is currently identical to
every other single-action drawer footer in the app.
  </decision>
  <context>
Jakub asked for this button to match the Receive and Buy GNUS pair. The census in finding
2 says the button he wants changed is not an outlier: six single-action drawer footers
exist and all six are `lg` at 56 with `expand: true`. The comment above this one records
that it was set to `lg` precisely to stop it being the one footer 8px shorter than its
neighbours.

The reference he named is a different archetype. Receive and Buy GNUS are `sm` at 44 and
share a row, so each takes about half the width. They are in-page panel CTAs in a
scrolling column. This is a drawer footer, pinned above the home indicator behind a top
rule, and it is the panel's only action.

Also relevant to the sizing judgement: Task 1 has already removed 14pt of dead space from
directly beneath this button. The footer block goes from 130pt tall to 116pt. A size
change to `sm` would remove a further 12pt. So the fix already shipped is the larger of
the two effects, and part of what read as "too big" was the block, not the button.

Whatever is picked, the variant does not move. It stays `gradientOutline`: Jakub set that
on 2026-07-28 because this is the panel's only action so it carries the brand signature,
hollow because opening a block explorer commits to nothing. It also satisfies the
standing rule, since it is the single CTA on that surface and there is no filled gradient
beside it to pair against.
  </context>
  <options>
    <option id="leave-it">
      <name>RECOMMENDED. Leave the button at lg and expand, ship only the space fix</name>
      <pros>
Keeps all six single-action drawer footers identical, which is the state the existing
comment was written to protect. Delivers the larger of the two measured effects, 14pt
against 12pt. Zero risk to the other five drawers. Lets Jakub judge the button after the
dead space is gone, on the device, at the Task 4 checkpoint, which is the honest order
given the block and the button were being seen together.
      </pros>
      <cons>
Does not literally do what Jakub asked in the moment. If he looks at it after Task 1 and
still reads it as too big, this costs one extra round trip.
      </cons>
    </option>
    <option id="this-one-only">
      <name>Change this one footer to sm</name>
      <pros>
Exactly what was asked. One file, one line, trivially reversible.
      </pros>
      <cons>
Re-creates the defect the comment records, in the opposite direction: this becomes the
one drawer footer 12px SHORTER than its five siblings. The most visible collision is
`buy_cancelled_drawer.dart`, a structural twin at gradientOutline, lg, expand, single
action, which cannot be changed to match because it sits under `lib/banxa`.
      </cons>
    </option>
    <option id="sweep-all">
      <name>Change every single-action drawer footer to sm</name>
      <pros>
Preserves uniformity while granting the request.
      </pros>
      <cons>
Not available under this task's constraints. Three of the six live under `lib/banxa` and
`lib/squid_router` and are out of bounds, so the sweep would split the population three
and three, which is worse than either extreme. It is also a large app-wide visual change
Jakub did not ask for. If he genuinely wants this, it needs its own task with those
directories unlocked.
      </cons>
    </option>
    <option id="narrow-not-short">
      <name>Keep lg height, drop expand so the button is no longer full bleed</name>
      <pros>
Would preserve footer height uniformity while attacking width, which is the other half of
the delta against the reference.
      </pros>
      <cons>
The census kills this one too. All six single-action footers are full bleed, so dropping
`expand` makes this the only non-full-bleed drawer footer in the app. A lone 56pt hollow
button floating at intrinsic width inside a ruled full-width band also reads as unfinished
rather than smaller. Listed because the briefing asked for it to be evaluated; the
measurement does not support it.
      </cons>
    </option>
  </options>
  <resume-signal>Select: leave-it, this-one-only, sweep-all, or narrow-not-short</resume-signal>
</task>

<task type="auto">
  <name>Task 3: Apply the chosen option, or record that none was needed</name>
  <files>lib/dashboard/home/widgets/transaction_displays.dart</files>
  <action>
Conditional on Task 2.

**If `leave-it`:** change no code. Add one line to the existing comment block above the
button recording that the size was reviewed on 2026-08-07 against a full census of drawer
footers, found to match all six single-action footers, and deliberately left. While in
that comment block, replace the em dash on the `gradientOutline` line with a plain hyphen
surrounded by spaces, since the file is open and the project rule forbids it.

**If `this-one-only`:** change `size: GWButtonSize.lg` to `GWButtonSize.sm`. Keep
`variant: GWButtonVariant.gradientOutline` and keep `expand: true`. Rewrite the comment
above it: the current text claims `lg` prevents this being the odd footer out, and after
this edit that text is false and actively misleading. Replace it with what is now true,
naming the five siblings it no longer matches and naming Jakub and the date as the reason.

**If `narrow-not-short`:** remove `expand: true`, keep `lg` and keep `gradientOutline`,
and wrap the button so it is centred in the footer band rather than left aligned. Same
comment obligation as above.

**If `sweep-all`:** stop. Do not implement. Report back that this needs its own task with
`lib/banxa` and `lib/squid_router` unlocked, and that shipping a partial sweep across only
the three reachable files is explicitly not the fallback.

In every branch the variant stays `gradientOutline`. No em dashes in anything written.
  </action>
  <verify>
    <automated>flutter analyze</automated>
    <automated>flutter test</automated>
  </verify>
  <done>
`flutter analyze` reports no issues. Full suite green at 1077 plus the cases added in Task
1, zero failures. The comment above the button describes what the code now actually does.
  </done>
</task>

<task type="checkpoint:human-verify" gate="blocking">
  <what-built>
The drawer footer's bottom inset is capped in the shell, so the transaction receipt and
every other drawer stopped reserving the raw 34pt iOS home-indicator area. 54pt below the
button became 40pt. The cap now lives in one constant shared with the mobile tab bar. A
new test fails if it regresses. The button's size was handled per Task 2.
  </what-built>
  <how-to-verify>
On the iPhone, dark mode. Green tests prove the arithmetic, not the look, so this is the
gate that closes the item.

1. Open the app, go to Transactions, tap any transaction to open the receipt drawer.
2. Look at the strip below View on Explorer. Compare it against the strip above the
   button, between the top rule and the button. It should now read as close to balanced,
   40 below against 20 above, where before it was 54 against 20. Confirm the button is no
   longer floating high with a dead band under it.
3. Confirm the home indicator still has clear space and that nothing under the button is
   clipped or touching the screen edge.
4. **The comparison Jakub named.** Without closing your session, go to the Assets page and
   look at the Receive and Buy GNUS pair, which is the reference he cited. Then reopen the
   transaction receipt drawer. Judge the two on the same device back to back and answer:
   with the dead space now gone, does View on Explorer still read as too big? Note that
   the reference pair is 44pt and half width each, and this is 56pt and full width, and
   that the other five single-action drawer footers in the app all match the 56pt full
   width form.
5. Open one other drawer to confirm the shell fix did not hurt anything else. Any of these
   works: the account switcher via the header, Add account, or a Reown approval drawer.
   Its footer should look the same as before, minus the same dead band.
6. If step 4 still reads bottom heavy, say so. The stated fallback is the symmetric
   variant from Task 1, taking the max instead of the sum, which gives 20 above and 20
   below and recovers 34pt rather than 14pt. It is a one-line change from where the code
   now stands.
  </how-to-verify>
  <resume-signal>Type "approved", or describe what still looks wrong, naming whether it is the space, the button, or both</resume-signal>
</task>

</tasks>

<verification>
- `flutter analyze` reports no issues, matching the verified pre-task baseline.
- `flutter test` passes at 1077 plus the cases added in Task 1, zero failures.
- `grep -rn "_kMaxBottomInset" lib` returns nothing: the cap was moved to one shared
  constant, not duplicated.
- `test/components/drawer_padding_invariant_test.dart` passes UNCHANGED. If it needed
  editing, something touched a call site's `bodyPadding` or added a drawer, neither of
  which is in scope here.
- Nothing under `lib/banxa` or `lib/squid_router` was modified.
- No commits were created. The work is left in the working tree for Jakub.
- No em dashes were introduced in code, comments, test names or UI strings.
</verification>

<success_criteria>
- The transaction receipt drawer's footer reserves 40pt below its button on a 34pt device,
  not 54pt, and the change lives in the shell so all 12 drawer footers get it.
- The cap value exists in exactly one place and the tab bar reads that same place.
- A test exists that fails if the footer returns to reserving the raw inset.
- The button's size was decided by Jakub against a real census of all six single-action
  drawer footers, not changed silently, and the button is still `gradientOutline`.
- Jakub has compared the drawer against the Receive and Buy GNUS pair on his own device
  and either approved it or named what is still wrong.
</success_criteria>

<output>
Create `.planning/quick/20260807-tx-drawer-explorer-cta/SUMMARY.md` when done. Record the
option Jakub picked at Task 2 and his verdict at Task 4, since the next person to touch a
drawer footer needs to know whether the six-way uniformity still holds.

Do NOT create commits. Leave everything in the working tree.
</output>
