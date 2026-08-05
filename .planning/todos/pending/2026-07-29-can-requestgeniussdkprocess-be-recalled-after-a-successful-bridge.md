# Can `requestGeniusSDKProcess` be re-called after a successful bridge?

**Found:** 2026-07-29, Phase 14 research.
**Type:** **backend / native SDK semantics, not UI.** Parked by Jakub the same day, deliberately.
**Decides:** whether the *bridged but not processed* terminal state gets a retry CTA or stays
informational. Phase 14 ships it **informational only** until this is answered.

## The situation in shipped code

`submit_job_cubit.dart:184-218` runs two money operations behind one "Purchase" button:

1. `bridgeOut()` - **burns GNUS** and returns a transaction hash
2. `requestGeniusSDKProcess()` - starts the job

If the second fails, the tokens are already gone. Worse, the cubit emits `processErrorMessage` and
returns **without ever writing `txHash` to state** - the hash is bound at `:193` and proven valid at
`:195`, then dropped. Phase 14 fixes the dropped hash. It does **not** answer whether the user can
recover the job.

## The question

After a successful `bridgeOut` whose `requestGeniusSDKProcess` failed, is calling
`requestGeniusSDKProcess` again with the same job JSON:

- **safe** - does it consume anything, or is it purely a request against already-burned credit?
- **idempotent** - can a retry that partially succeeded leave the node in a corrupt state?
- **meaningful** - does the SDK still associate the burned tokens with this job, or is that
  association lost the moment the first call returned an error?

`_processErrorMessage` maps seven SDK return codes (`submit_job_cubit.dart:258-275`). The answer may
well differ per code - `GENIUS_NODE_ERROR_MINT` and `GENIUS_NODE_INVALID_ARGUMENT` are not obviously
in the same category.

## Why it is not a UI question

A "Try the job again" button is one line of Dart. Whether pressing it can **burn a second round of
GNUS** or desynchronise the node is a property of the native SuperGenius layer, and nothing in the
Flutter tree records it. Shipping the button on an assumption would put real money behind a guess.

## What would close this

Read the SuperGenius native implementation behind `requestGeniusSDKProcess`, or ask whoever owns it.
Answer per return code where the answer differs. If retry turns out to be safe, the terminal state
gains a CTA and the design already has the slot for it.

Related: [[2026-07-29-stall-detector-needs-a-traced-processing-feed]] - the other Phase 14 item
parked as backend logic on the same day.
