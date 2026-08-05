# The drawer shell says "filled gradient CTA"; the CTA weight rule says fill means commitment

**Created:** 2026-07-31. **Area:** drawers / design system. **Severity:** contradiction between two
approved rules. **Deferred by Jakub on 2026-07-31 to the ~19-drawer walk.**

## The contradiction

Sketch **030 B1 "Quiet band"**, the approved drawer shell that all ~19 drawers sit in, specifies the
footer as: *"stopka z górną krawędzią, CTA jako wypełniony gradient"* - a filled gradient CTA, with
no stated exception.

The project's **CTA weight rule** says the opposite for this case: a fill means commitment, an
outline means everything else, and a surface carries at most one fill.

Both are approved. They cannot both be followed by a drawer whose footer action commits to nothing.

## Where it surfaced

The `New processing job` drawer, step 1. Its footer renders `GWButtonVariant.secondary` - an outline
button labelled `Choose a JSON file` (`lib/submit_job/view/widgets/job_steps.dart:492`).

Jakub noticed it on a live walk on 2026-07-31 and read the drawer as not matching the others. The
step shape itself is NOT the problem and is not in question: the vertical numbered steps are the
approved `F1 · Drawer, vertical steps`, chosen 2026-07-29, with six of Phase 14's plans already
executed against it.

## Which rule is probably right, and why this was not decided on the spot

Opening a file picker commits the user to nothing. The commitment in this flow arrives three steps
later, at `Confirm`, where 12.40 GNUS is spent irreversibly and cannot be recovered - the same burn
that makes `bridgedNotProcessed` unrecoverable. Giving `Choose a JSON file` the same visual weight as
that button is what the CTA weight rule exists to prevent.

So the outline is very likely correct and **030 B1's footer clause is the thing that is too
absolute** - it needs an exception clause, not an enforcement pass.

It was deliberately NOT decided in isolation. The whole point of the question is consistency across
drawers, and that cannot be judged from one screenshot: the answer depends on how many of the ~19
footers carry a non-committing action. Deciding it from a single drawer would risk fixing this one and
breaking the pattern everywhere else.

## A SECOND, simpler defect found the same day - and this one is not a rule conflict

Jakub pointed at the same button again on 2026-07-31 and named the real problem: it is **blue**,
while every other outline CTA in the app carries the brand gradient. That is not the weight
question above; it is the wrong outline entirely.

`GWButtonVariant.secondary` paints `brandPrimaryOnSurface` as both border and label
(`gw_button.dart:139-150`) - a flat blue. The app's outline treatment that belongs beside a
gradient fill is `GWButtonVariant.gradientOutline`, documented in the enum as the *"outline twin of
gradient - transparent fill, gradient border + label"*.

Census of CTA variants across every drawer-bearing file in `lib/` (2026-07-31):

| File | Variants used |
|---|---|
| `buy_success_drawer`, `buy_cancelled_drawer`, `approve_transaction_drawer`, `approve_dapp_connection_drawer`, `swap_result_drawer`, `swap_settings_drawer`, `transaction_displays`, `coins_screen`, `token_info_screen` | `gradient` and/or `gradientOutline` |
| **`job_steps.dart`** | `gradient` + **`secondary`** |
| `account_drawer.dart`, `sdk_account_manager.dart` | `gradient` + **`primary`** + `destructive` |
| `design_gallery_screen.dart` | all of them - it is the component showcase, correctly |

**`job_steps.dart` is the only drawer in the app using `secondary`.** `account_drawer` and
`sdk_account_manager` are off-pattern too, on `primary`. Three drawers never got the Phase 21
language applied to their CTAs - which fits, since Phase 21 rolled out four archetypes (receipt,
list, confirm, receive) and a wizard and a settings form are neither.

**These two defects must be fixed together, not separately.** Deciding "outline or fill" without
also deciding "which outline" would leave the blue in place; swapping blue for `gradientOutline`
without settling the weight question would ship an outline the shell says should be a fill. One
change, both answers.

## What to do at the drawer walk

1. Census the ~19 `ResponsiveDrawer` call sites: for each footer, is the primary action a commitment
   (spends money, signs, sends, deletes) or a step (picks a file, opens a picker, advances a wizard)?
2. If non-committing footers are a real class and not a one-off, amend 030 B1 with the exception and
   leave `job_steps.dart:492` alone.
3. If this drawer is genuinely the only one, the cheaper fix is to make it conform and keep 030 B1
   absolute.

Related: [[2026-07-27-checkout-options-sheet-visual-contract-was-derived-not-specified]] is the other
recorded drawer question waiting on the same walk. Sketch 156's own note already records that "the
walk is still owed".

**2026-07-31, later the same day:** the colour half is closed - every `GWButtonVariant.secondary` in
`job_steps.dart` (there were four: step 1 and step 2's footers, and the terminal footer's `Close` /
`Get help`) is now `gradientOutline`, so this drawer no longer paints the app's one flat-blue CTA.
The weight half (outline vs. fill for a non-committing footer action, i.e. 030 B1's exception
clause) is untouched and still awaits the drawer walk above.
