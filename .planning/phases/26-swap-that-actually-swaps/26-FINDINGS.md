---
phase: 26
date: 2026-09-17
status: fixed-pending-walk
found-by: walking 26-06 and 26-07 on a real wallet
---

# Six defects the walk found, and what each cost

All six were found by trying to swap 0.005 ETH on Base mainnet with a real wallet, and then
by completing that swap for real. **None was visible to the test suite**, which was green at
1347 passing throughout — three of them because the fixtures encoded the same wrong assumption
the code did.

1-3 blocked the swap outright. 4-6 were found by using the screen once it worked.

## 1. Base's native coin was labelled BASE and priced at $0

**Symptom.** A wallet holding 0.005 ETH on Base showed `0.005 BASE` worth `$0`.

**Cause.** `assets/json/networks/networks.json` gave chain 8453 `symbol: "base"` and
`coinGeckoId: "base"`. Base's native gas coin is ETH; there is no native coin called BASE.
The price lookup asked CoinGecko for the wrong asset and got nothing.

**Why it was not a one-word fix.** `Network.symbol` was doing two incompatible jobs:
the native currency ticker AND the chain key that `getExplorerUrl` resolves a receipt's
URL from (`'base' -> basescan.org`). Renaming it to `eth` would have pointed every Base
receipt at etherscan, where the hash does not resolve — trading a visible bug for a
silent one.

**Fix.** Split the roles. `Network` gained `nativeSymbol`; Base now declares
`symbol: "base"` (chain key, explorer unchanged), `nativeSymbol: "eth"`,
`coinGeckoId: "ethereum"`. `read_asset.dart` is the only consumer. 84531 got the same
treatment.

## 2. The swap screen read a dollar total as an ETH quantity

**Severity: this is the one that could have moved the wrong amount of money.**

**Symptom.** The "You Pay" picker was empty — the wallet appeared to hold nothing
spendable.

**Cause.** `swap_screen.dart` took the native token's balance from
`selectedWalletBalance`. That field is not a quantity: `coins_screen.dart` sets it from
`assetsTotal(...)` = the sum of `balance x price` across every coin, in USD. The swap
screen read those dollars as an amount of ETH.

**How the two chained.** Defect 1 made the price lookup fail, so the fiat total was
`"0.00"`, so the native balance read as zero, so the holdings filter removed every
token. The empty picker was a symptom of the price bug — but **fixing defect 1 alone
would have armed defect 2**: with a working price, 0.005 ETH at ~$2450 becomes `"12.25"`,
and the form would have believed the wallet held 12.25 ETH. The CTA's insufficient
balance guard would have accepted a swap ~2450x larger than the real holding.

**Fix.** New pure `nativeCoinBaseUnits()` reads the quantity from the native holding's
own `Coin.balance` — the holding with no contract address. `selectedWalletBalance` is
never read as a quantity again. An absent holding yields an absent balance, so the token
is simply not spendable, rather than a guess.

**Why the suite missed it.** Two fixtures seeded `selectedWalletBalance` with
quantity-shaped values (`'1.5'`, `'1'`, `'5'`), encoding the wrong assumption. One test
was even named "the native coin takes the figure the app already shows". The fixtures
now set a fiat-shaped total that differs from the quantity, so the source is proven.

## 3. Live API drift #5 — no route could be quoted for a native swap

**Symptom.** "Couldn't fetch a route. Check your connection and try again."
The message is misleading: nothing was wrong with the connection.

**Cause.** Squid answered **HTTP 200 with a valid route**. The generated client could not
deserialize it. A same-chain NATIVE swap wraps ETH into WETH first, so the route carries
a `wrap` action, and the generated `WrapDetails` requires three non-nullable fields the
live API no longer sends at the top level:

| Required by the generated model | Live response |
|---|---|
| `wrapper` | absent |
| `coinAddresses` | absent — now nested under `properties` |
| `calls` | absent |

**Impact beyond this walk.** Any same-chain native swap is affected, so **ETH -> USDC on
Base could not be quoted at all.**

**Why the suite missed it.** The recorded fixture `route_response.json` is two plain
swaps with no wrap action, so it still parses. The fixture had gone stale relative to the
live API and the suite stayed green.

**Fix.** The quote path now reads `/v2/route` raw off the generated client's own dio and
hand-maps the estimate, which is what the catalogue, the executable route and the status
poll already do — the fourth instance of an established pattern, not a new one.
`squidrouter/` is auto-generated and was not touched. The bypass is safe rather than
merely convenient because **the quote never reads `actions`** — the model was rejecting
the response over a field we do not use.

Squid's actual response is recorded as `test/squid_router/fixtures/route_response_wrap.json`.

This is the **fifth** live drift in this submodule. The other four are in the
2026-09-16 handoff. The pattern is consistent: the checked-in spec has drifted from the
live API, and every instance was found by calling it, not by reading it.

## 4. Price impact printed at whatever precision the aggregator chose

`route_details_card.dart` rendered `'${quote.priceImpact}%'` — Squid's own string, verbatim.
A real impact would have read `-0.0234567%`. New `formatPercent` in `squid_util.dart` trims to
two decimals and drops trailing zeros. Two values are deliberately NOT rendered as a plain `0`:
an unreadable string passes through untouched rather than becoming an invented number, and a
value too small to survive two decimals renders `~0`, because printing `0` would claim an
impact the route does not have. [SwapQuote] still holds the raw string, so no float rounding
enters before the display step.

**Fees `$0` is NOT a defect.** Squid reported `gasCosts.amountUsd = "0.00"`; Base gas on this
route really was 0.00000107 ETH, about a third of a cent. The same reader returns `0.01`,
`0.02` and a `0.48` bridge fee on the other fixtures, and a test pins the exact value so a
mapper that silently read nothing could not pass as "cheap".

## 5. The receive side jumped ~976px left whenever a route failed

`swap_field.dart` put the amount slot in a `Flexible`, whose two branches have very different
intrinsic widths: a `TextField` fills the row, the em-dash placeholder is one character wide.
A failed quote clears the amount, the placeholder branch is taken, and the token selector slid
from x=1085.5 to x=109.1 — measured, then fixed by making the slot an `Expanded` so it owns the
width regardless of what is drawn inside it.

The existing comments show the two branches had been carefully aligned on one *baseline*.
Nothing had pinned their *width*.

## 6. A completed swap left its spent quote on screen

Found by walking: after the swap succeeded, opening the explorer link and returning showed the
amounts still seated. The success path stored its row and never cleared the form.

The asymmetry is the tell — `_reportFailure` clears these fields after a FAILED swap, with the
reason written down: "a stale figure beside a failure message is a number the user might still
act on". After a SUCCESSFUL swap that is truer: the balance behind the figure has changed, the
router has consumed the quote id, and `fetchedQuote` staying seated returns the CTA to its
`ready` rung — so a second tap would submit against a quote that cannot be filled again.

Now cleared on any outcome that stored a row. The two tokens stay seated, because swapping the
same pair again is the likely next action and re-picking them is the tedious part.

## Verification

Real output, this machine, this branch:

```
flutter test --no-pub       1364 pass / 5 skip / 0 fail, exit 0   (entering: 1347)
flutter analyze --no-pub    No issues found, exit 0 — root AND packages/genius_api
dart format (lib + test)    exit 0
tool/check_brace_style.sh   0
```

Every new case was run red against the old code before the fix. Three pin the traps
specifically:

- the native balance is **not** `999.99` when that is the seeded fiat total
- `symbol` stays `"base"` and `getExplorerUrl("base", ...)` still resolves to basescan
- the generated model **still rejects** the wrap fixture, so the bypass cannot be quietly
  removed while the drift is live; and the raw mapper agrees with the generated one on
  the two older fixtures, where both can read

## Still open

- **26-06 is WALKED** — a real swap executed, hash
  `0xc74e959425605f69b0782ef5822dfaaa2ad9d9fc416fa01f9b426da9135b27f7`, recorded in
  `26-06-SUMMARY.md`. **26-07 is not**, and still needs an underfunded send.
- **Why 26-07 did not happen.** MAX was pressed on the full balance and the send was
  expected to fail for gas. It succeeded: the route spent 0.004983074278833122 ETH and
  ~0.0000169 ETH (about $0.04) remained, which covered the 0.00000107 ETH of gas. Whether
  that headroom comes from Squid trimming a native `fromAmount` or from the app's own MAX
  is **not established and should not be guessed** — it decides whether a user can strand
  themselves holding tokens with no gas to move them.
- All six fixes are **outside phase 26's plans** — deviations found by walking, and they
  belong in the phase record as such rather than folded in silently.
- `26-VERIFICATION.md` still does not exist, so GSD reports the phase as `executed`, not
  `complete`.
