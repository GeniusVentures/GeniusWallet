# Phase 41 - Context (decisions from Braian, 2026-10-11)

Scope: make Linux behave like Windows for web content. No new design work.

## Locked decisions
- No UI-SPEC. Reuse the Windows behaviour and existing components; no restyling.
- Banxa checkout on Linux stays the same dialog as Windows. Only remove what breaks the native view (the rounded clip); no full-screen redesign.
- Articles and legal pages: the Linux browser honours includeBackButton the way the Windows browser does. No route or behaviour change on Windows, macOS, Android or iOS.
- Overlays: hide the web view only while a dialog, bottom sheet or popup menu is above it (needed for it to work). Toasts are out of scope.
- Fallback when WebKit is missing: open in the system browser as today; a short message is acceptable but not required.
- Plugin: vendored in third_party/ (pristine upstream import and our patch as separate commits). No GitHub fork in this phase.
