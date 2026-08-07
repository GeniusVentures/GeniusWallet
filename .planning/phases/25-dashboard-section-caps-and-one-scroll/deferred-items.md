# Deferred items - phase 25

Out-of-scope discoveries logged rather than fixed, per the executor's scope
boundary (only auto-fix issues DIRECTLY caused by this plan's changes).

## `tool/check_brace_style.sh` fails on `test/components/gw_section_title_rhythm_test.dart`

**Found during:** 25-01 Task 3e, while running the project's own tooling gates.

**Status:** PRE-EXISTING, not caused by this plan. That file landed with quick
task 260806-wys (it is still untracked in the working tree); 25-01 edited only a
doc comment inside it.

**What fails:** six one-line `if` bodies in the file's private measurement
helpers, which `AGENTS.md` forbids ("YOU MUST brace every `if`, with the body on
its own line") and `tool/check_brace_style.sh` enforces:

```
test/components/gw_section_title_rhythm_test.dart:208   if (w is RawImage) return true;
test/components/gw_section_title_rhythm_test.dart:209   if (w is ColoredBox) return w.color.a > 0;
test/components/gw_section_title_rhythm_test.dart:210   if (w is DecoratedBox) return _decorationPaints(w.decoration);
test/components/gw_section_title_rhythm_test.dart:246   if (ro is! RenderBox || !ro.hasSize || ro.size.isEmpty) continue;
test/components/gw_section_title_rhythm_test.dart:248   if (top < y - 0.01) continue;
test/components/gw_section_title_rhythm_test.dart:249   if (best == null || top < best) best = top;
```

It is the ONLY file the script flags across `lib/` and `test/`, so fixing those
six lines returns the whole gate to green.

**Why not fixed here:** it is in neither this plan's `files_modified` beyond a
comment, nor caused by it, and `flutter analyze` does not see it
(`curly_braces_in_flow_control_structures` permits the one-line form - which is
exactly why the shell script exists). Six mechanical edits whenever the rhythm
quick task is closed out.

**Note:** `tool/check_raw_colors.sh` passes (exit 0).
