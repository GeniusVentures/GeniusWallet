---
phase: 41
slug: linux-in-app-webview
# status lifecycle: draft (seeded by plan-phase) → validated (set by validate-phase §6)
# audit-milestone §5.5 distinguishes NOT-VALIDATED (draft) from PARTIAL (validated + nyquist_compliant: false) (#2117)
status: draft
nyquist_compliant: true
wave_0_complete: false
created: 2026-10-11
---

# Phase 41 — Validation Strategy

> Per-phase validation contract for feedback sampling during execution.

---

## Test Infrastructure

| Property | Value |
|----------|-------|
| **Framework** | flutter_test (Flutter 3.41.9, `../flutter/flutter/bin/flutter` from the worktree root) |
| **Config file** | analysis_options.yaml |
| **Quick run command** | `flutter test test/web test/banxa test/dashboard/transaction_recovery_states_test.dart` |
| **Full suite command** | `flutter test` |
| **Static** | `dart format --output=none --set-exit-if-changed lib test`; `flutter analyze lib test` (exits 1 on infos, judge `$?`); `bash tool/check_brace_style.sh`; `bash tool/check_raw_colors.sh` |
| **Estimated runtime** | ~41 seconds (quick run) |

CI's `quality` job runs on Linux with the plugin absent: no test may construct a real `WebViewController`, and assertions about the in-app decision use `opensInApp(os, ...)` or compare against `inAppWeb`, never a hard-coded platform answer.

---

## Sampling Rate

- **After every task commit:** the quick run plus the static checks
- **After every plan wave:** `flutter test`
- **Before `/gsd-verify-work`:** full suite green, and every walk below has its evidence
- **Max feedback latency:** 41 seconds (unit); a container rebuild plus walk is ~3-5 minutes

---

## Walk harness (agent-driven Linux walks)

- **Scripts:** `.claude/skills/spike-findings-geniuswallet/sources/005-wallet-surfaces-in-app/{sync,build,run,lx}.sh` and `nowebkit.c`. Copy them to your session scratchpad and fix the hard-coded paths: worktree `/mnt/c/Users/User/Documents/Projects/GNUS/GW-linux-webview`, shots to `.planning/phases/41-linux-in-app-webview/walk/`, the `nowebkit.c` path. Keep the anchored `/banxa` excludes in `sync.sh` (unanchored also drops `lib/banxa`).
- **Build:** Docker image `gw-spike006` (AlmaLinux 8 CI image + `webkit2gtk3-devel` + Flutter 3.41.9). If it is gone, rebuild it from `.planning/spikes/006-almalinux8-build/Dockerfile`. `sync.sh` then `build.sh`; pass = `BUILD_RC=0`.
- **Run:** WSL `Ubuntu-20.04` with WSLg (WebKitGTK 4.0, 2.38.6). `run.sh` starts a fresh profile (create a throwaway wallet once, then `KEEP=1`); its `app.log` must contain `webview_all_linux: loaded libwebkit2gtk-4.0.so.37`. `NOWEBKIT=1 run.sh` makes every `dlopen` of WebKitGTK fail.
- **Ubuntu 24.04:** `gw005-u2404` (WebKitGTK 4.1, libsoup3, keyring and secret store; `.planning/spikes/005-wallet-surfaces-in-app/Dockerfile.walk`) on the WSLg X socket, flags as in `.planning/spikes/007-webkit-runtime-loading/run-bundle.sh`, with run.sh's dbus and keyring setup inside the container. No-WebKit 24.04: an image FROM `gw007-nowebkit` with Dockerfile.walk's packages minus `python3-gi` and the `gir1.2-*` entries (they pull WebKitGTK).
- **Walk-only code:** a walk may apply reference hunks or a test hook to the working tree, never to the index; `git checkout -- lib` (plus deleting any file it created) restores the tree before the next commit.
- **Drive:** `lx.sh click X Y | type TEXT | key KEY | shot NAME`, then read the PNG. Typing needs the window raised on the Windows desktop. `wsl.exe` expands `$vars` itself: put commands in a script file and call it with `MSYS_NO_PATHCONV=1 wsl.exe -d Ubuntu-20.04 bash <file>`.
- **One at a time:** one build and one running wallet; `run.sh` kills any running wallet. This is why the plans run in four sequential waves.
- **Evidence:** at most four PNGs per plan in `walk/`, named `NN-what.png`; the plan's SUMMARY says what each shows.

---

## Per-Task Verification Map

| Task ID | Plan | Wave | Requirement | Threat Ref | Secure Behavior | Test Type | Automated Command | File Exists | Status |
|---------|------|------|-------------|------------|-----------------|-----------|-------------------|-------------|--------|
| 41-01-01 | 01 | 1 | LWV-01 | T-41-01, T-41-02 | Pristine import diffs clean against upstream; WebKit opened by fixed soname only; no WebKit link | build | `flutter analyze lib test`; `flutter test test/dashboard/transaction_recovery_states_test.dart test/web`; container `readelf -d` / `nm -D --undefined-only` on the bundle | existing | ⬜ pending |
| 41-01-02 | 01 | 1 | LWV-01, LWV-02 | T-41-02 | Real wallet loads 4.0 (20.04) and 4.1 with libsoup3 (24.04) with no abort; starts without WebKit (24.04 and shim) | **walk-gated** (four runs; blocker if 4.1 fails) | `grep -c "loaded libwebkit2gtk-4.1.so.0" walk/01-u2404.log` plus the other three filtered logs and shots | n/a | ⬜ pending |
| 41-01-03 | 01 | 1 | LWV-09 | T-41-04, T-41-SC | CI goes red if WebKit is linked or the plugin is missing | static + container script | `grep -c webkit2gtk3-devel .github/workflows/build.yml` prints 2; the new step's script exits 0 on the bundle and 1 on the negative control | n/a | ⬜ pending |
| 41-02-01 | 02 | 2 | LWV-03 | T-41-06, T-41-07, T-41-08, T-41-09 | Linux browser has no JS channel, TLS-error or permission handler | unit + walk | `flutter test test/web test/dashboard/transaction_recovery_states_test.dart` | ❌ created in task (`test/web/web_utils_test.dart`) | ⬜ pending |
| 41-02-02 | 02 | 2 | LWV-08 | — | N/A | **walk-gated** (grep and build only prove the hook exists) | container build exit 0; `grep -c button-press-event .../flutter_view.cc` prints 1; pass/fail is walk/02-focus.png | existing | ⬜ pending |
| 41-02-03 | 02 | 2 | LWV-07 | T-41-05 | A page is never drawn over a wallet dialog, drawer, sheet, menu or dropdown route (root and shell navigators) | widget + walk | `flutter test test/web/web_overlay_gate_test.dart` | ❌ created in task | ⬜ pending |
| 41-03-01 | 03 | 3 | LWV-04 | T-41-12 | N/A | widget + **walk-gated** (the test covers the control; showing it in WebViewLinux needs a native controller) | `flutter test test/web/web_page_close_button_test.dart test/web`; `bash tool/check_raw_colors.sh` | ❌ created in task | ⬜ pending |
| 41-03-02 | 03 | 3 | LWV-05, LWV-02 | T-41-11 | No web view is created when WebKit is missing | unit + walk | `flutter test test/web` | extends `test/web/web_utils_test.dart` | ⬜ pending |
| 41-04-01 | 04 | 4 | LWV-06 | T-41-13, T-41-17 | Only https Banxa URLs load; the walk-only hook is never committed | unit + **walk-gated** (page reaches onPageFinished while unpainted, or fallback) | `flutter test test/banxa` | extends `test/banxa/checkout_rules_test.dart` | ⬜ pending |
| 41-04-02 | 04 | 4 | LWV-06 | T-41-14 | Camera/microphone only on a trusted Banxa page, everything else denied; mobile and Windows constants map unchanged | unit | `flutter test test/banxa/checkout_rules_test.dart` | extends | ⬜ pending |
| 41-04-03 | 04 | 4 | LWV-07, LWV-02 | T-41-16 | Menu and dialogs over checkout are never cut by the page | full suite + walk | `flutter test` | existing | ⬜ pending |

*Status: ⬜ pending · ✅ green · ❌ red · ⚠️ flaky*

---

## Wave 0 Requirements

Existing infrastructure covers the phase. The three new test files (`test/web/web_utils_test.dart`, `test/web/web_overlay_gate_test.dart`, `test/web/web_page_close_button_test.dart`) are written test-first inside the tasks that need them (41-02-01, 41-02-03, 41-03-01), so no separate scaffold wave is needed.

Walk-gated tasks (41-01-02, 41-02-02, 41-03-01, 41-04-01) pass or fail on their walk evidence; their automated commands only prove the code is there. The real wallet on Ubuntu 24.04 (WebKit 4.1, libsoup3) moved from manual-only to the 41-01-02 agent walk, which plans 02-04 wait on.

---

## Manual-Only Verifications

| Behavior | Requirement | Why Manual | Test Instructions |
|----------|-------------|------------|-------------------|
| Real camera prompt, grant and deny, on WebKitGTK >= 2.40 | LWV-06 | No camera device reaches the agent; a camera prompt never fires without one | Linux machine with a webcam (Ubuntu 22.04/24.04), keyed CI build, Banxa sandbox order to the ID step: allow gives a preview, deny gives Banxa's error. On Ubuntu 20.04 (2.38.6) getUserMedia does not exist: expect failure there and use "Open in browser" |
| Fresh Banxa sandbox order to the email screen, then Done | LWV-06 | Local builds have no Banxa key; a replayed order URL ends blank in any WebKit | PR CI Linux tarball (sandbox, buys ETH): Buy, checkout in the dialog, email screen, finish or close; Done comes from the polled status |
| First CI run of the `linux_arm` row | LWV-09 | Needs a PR; aarch64 was never built (package listed in AlmaLinux 8 AppStream aarch64 at planning: 2.54.0-1.el8_10) | PR CI: `linux_arm` installs `webkit2gtk3-devel`, builds, link-check step green |
| Windows, macOS, Android, iOS unchanged | LWV-04 (D-03) | Other platforms | PR CI all rows green; on Windows an article still opens in `/web` with the cancel control |
| Real hardware graphics | LWV-01 | Walks run in containers and WSLg only | On real Linux hardware a page renders without `GDK_GL=gles` or `WEBKIT_DISABLE_COMPOSITING_MODE` |

---

## Validation Sign-Off

- [x] All tasks have `<automated>` verify or Wave 0 dependencies
- [x] Sampling continuity: no 3 consecutive tasks without automated verify
- [x] Wave 0 covers all MISSING references
- [x] No watch-mode flags
- [x] Feedback latency < 41s (unit runs; walks are per task, not per commit)
- [x] `nyquist_compliant: true` set in frontmatter

**Approval:** pending
