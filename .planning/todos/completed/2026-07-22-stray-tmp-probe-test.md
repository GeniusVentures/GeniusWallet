# Stray `test/_tmp_probe_test.dart` in the working tree

**Found:** 2026-07-22, during the Phase 14 design session (observed, not caused by it)
**Kind:** looks wrong but harmless — todo, keep moving

## What

`test/_tmp_probe_test.dart` is untracked in the working tree. The `_tmp_` prefix and `probe` name
read as a scratch file from a measurement session (the boot-sequence timing work, most likely —
`test/boot_sequence_test.dart` and `lib/screens/boot_sequence.dart` are untracked alongside it).

## Why it matters

Low stakes, but two ways it bites:

- It sits in `test/`, so any future `flutter test` run picks it up. The harness does not currently
  compile (APP-02), so this is latent rather than active — it becomes real the moment someone fixes
  the harness.
- A file named `_tmp_*` left in a tree for long enough stops looking temporary and someone commits it.

## Suggested fix

Confirm with whoever ran the boot-sequence measurements whether it is still needed. If not, delete.
If it is a keeper, rename it to say what it probes.

**Not done in this session** — it is not this session's file, and deleting someone's in-flight
measurement scaffold without asking is the wrong trade.

---

## RESOLVED 2026-07-22 — and the attribution was wrong

The file is gone. It was **not** from the boot-sequence work: it was a throwaway measurement probe
written by the Phase 15 `15-01` executor while checking what `txRowContent` actually produces for a
processing job and a failed transaction, rather than deriving those strings by hand. That executor
deleted it when it finished, which is why the file no longer exists.

Worth keeping the habit, not the file: measuring the real output beat reasoning about it — the fee
row's value line came out `$0.36 fee`, not the `$0.32` the sketch had guessed.
