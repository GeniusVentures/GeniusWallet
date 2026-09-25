# Handoff 2026-09-24: v2.0 closed, backlog triaged, two PRs merged

## Shipped (both merged to develop, rebase)
- **PR #246**: four backlog fixes. A PIN read error no longer sends the user to onboarding. Swap refuses amounts with more decimals than the token supports. dApp token labels are matched by chain. Base Sepolia uses a working RPC. The same PR closed milestone v2.0 by hand: the archive is `milestones/v2.0-*`. v1.0 is still live in `ROADMAP.md` and `REQUIREMENTS.md`, so the stock complete-milestone flow was not used. There is no `v2.0` tag; Braian chose to skip it.
- **PR #247**: seven quick wins:
  - swap history rows carry their chain ID, and the WalletConnect result drawer uses it too
  - the dead `/backup_phrase` route is deleted
  - `PasteField.height` is removed
  - account drawer rows show a short address and format the balance
  - SDK add-account validates input through a cubit and wipes key bytes, including in `toTWString`
  - a second app instance shows "already running" (checked on Windows)
  - the swap FAB hides under popups and has its bottom offset fixed

  It also closed 9 stale todos and re-filed 5 of them down to their open remainder.

## Todo triage
All 40 pending todos were checked against the code and against what MetaMask, Trust, Rainbow, Coinbase and Phantom do. Two lists came out of it:
- **Worth building next:**
  - wallet header identity (a spoofing risk)
  - Android `FLAG_SECURE` on the seed screens
  - a testnet toggle in the network picker
  - chart timeframe wiring
  - the switch ON-state contrast
  - status-colour text in light mode
  - the bottom bar at large text sizes
  - the Material text-slot mapping
- **Needs a decision first:**
  - Receive showing the wrong network's address (product)
  - the `com.example` rename (needs a migration)
  - the 320px minions clip (Jakub)
  - the SDK retry and stall-detector questions (SDK owner)

## Open
- `lib/reown` and the dev tools still build some rows without a chain ID. Only dev mocks are affected.
- The SDK init paths free the mnemonic and key buffers but don't zero them. This predates both PRs.
- Not checked by eye: the swap FAB glow at its new 20px bottom offset, and SDK add-account against a real SDK.
