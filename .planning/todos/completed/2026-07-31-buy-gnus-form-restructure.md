# Buy GNUS form: restructure to the design's order

**Raised:** 2026-07-31 by Jakub, with a screenshot of the target.
**Status:** queued as the 4th quick task of the day. Blocked ONLY by ordering, not by a
decision: it edits `lib/screens/banxa_buy_screen.dart`, the same file as quick task
`260731-ope`, so it starts once that one lands.

## What he asked for

> "Genius Tab powinien wygladac tak jak tutaj: masz 'You spend' kwote, masz jakies mozliwosci
> do klikniecia (shortcuty), potem masz 'Currency', a 'Payment Method' pod nimi. Tutaj, co nie
> jest w designie, ale powinno byc, to 'Wallet Address', tak jak mamy obecnie. Nastepnie
> 'You get', 'Rate', 'Banxa fee' i 'Buy GNUS'."

Target order:

1. `YOU SPEND` kicker + the amount field, rendered large (`$500.00` in the shot)
2. A row of amount shortcut chips - `$100` `$500` `$1,000` `$5,000`, the active one filled
3. `CURRENCY` and `PAYMENT METHOD` selects SIDE BY SIDE, two columns
4. `Wallet Address` - NOT in the design, kept deliberately at his instruction
5. The `You get` / `Rate` / `Banxa fee` grid
6. The gradient `Buy GNUS` CTA

## What it is today (`banxa_buy_screen.dart:250-345`)

A single stacked column: `Fiat` select, `Crypto Currency` select, `Payment Method` select,
amount field, wallet field, `GWDetailGrid`, CTA. Every control is full width and the amount
field - the one number the user actually types - is fourth from the top at body size.

## The forks that need Jakub before building

1. **The `Crypto Currency` select is absent from the design.** The screen is "Buy GNUS", so the
   design assumes GNUS. Today the select is live and populated from `state.cryptos`. Options:
   drop it and pin GNUS, keep it but demote it, or keep it only when more than one crypto is
   offered. Dropping it is a behaviour change, not a layout change - do not let it be made
   silently as part of "restructuring".
2. **Do the shortcut chips follow the selected fiat?** The shot shows dollars. With EUR selected,
   `$100` is wrong. And Banxa enforces a min/max per payment method, so a fixed ladder can offer
   an amount the API will reject.
3. **The CTA reads `Buy GNUS` in the design, unconditionally.** Today it reads `Get quote` until
   a quote exists and only then `Buy GNUS` (`:162`). Whether the design intends to remove the
   two-step quote flow, or just drew the post-quote state, is not something the picture settles.

## Invariants that must survive

- The form card's height must not change when a quote arrives. There is an explicit comment at
  `:322-325` and another at `:349-356` recording this, both written to stop the orders rail
  beside it from shifting. A restructure that reflows on quote arrival breaks it.
- The `Couldn't load currencies.` retry row (`:217-249`) is an error surface, not chrome.
