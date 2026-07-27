---
sketch: 061
name: coin-page-in-app-language
question: "Jak strona coina ma czytać się jak reszta aplikacji - skoro jako jedyna nie ma navbara, ma inną ramkę i inny nagłówek?"
winner: null
tags: [coin-detail, token-info, page-layout, gw-page-header, page-frame, shell-route, navbar, consistency, data-honesty, follows-152]
---

# Sketch 061: Coin page w języku reszty aplikacji

## Design Question

Jakub: *„coin page - zerknij jak inne strony są zrobione i przygotuj 5 designów w podobnej
koncepcji, żeby pasowało do reszty."*

Szkic **152** rozstrzygnął już układ wewnętrzny tej strony (A@≥768 + D@<768, Convert read-only,
bez zakładek 1H/1D/1W) i to jest zaimplementowane. To pytanie jest o poziom wyżej: **o chrome
strony** - ramkę, nagłówek i nawigację, czyli o wszystko, co odróżnia ją od Transactions /
Markets / News / Swap.

## Ustalenia z kodu (przed rysowaniem)

| Aspekt | Strona coina dziś | Każda zakładka |
|---|---|---|
| Nawigacja | **brak navbara** - `GoRoute('/token-info')` stoi **poza** `ShellRoute` (`router.dart:242`) | navbar zawsze na górze (`ShellRoute`, `router.dart:208`) |
| Nagłówek | Material `AppBar` 48px, `surfaceSunken`, okruszek „Markets / Bitcoin" | `GWPageHeader` w body, tytuł 28px |
| Ramka | `maxWidth: 1200`, **wycentrowana**, padding `space10`/`space8` | `maxWidth: xxl (1536)`, rynna 12px, odstęp górny `space32` (64) |
| Tytuł sekcji | lokalny `_buildSectionTitle` (`token_info_screen.dart:42`) | komponent `GWSectionTitle` (`components/cards/gw_section_title.dart`) |
| Info | pokazuje **4 pola**: marketCap, circulatingSupply, totalSupply, totalVolume | — |

**Model niesie znacznie więcej, niż strona pokazuje.** `CoinGeckoMarketData` ma dodatkowo
`marketCapRank`, `high24h`, `low24h`, `fullyDilutedValuation`, `ath`/`athChangePercentage`/`athDate`,
`atl`/`atlChangePercentage`, `priceChange24h`, `marketCapChangePercentage24h`, `maxSupply`,
`lastUpdated` - wszystko realne, wszystko już w Hive. To jest paliwo dla wariantu B, bez jednego
nowego requestu.

Utrzymane ustalenia z 152 i fazy 07: **Convert - cena read-only**, **brak zakładek 1H/1D/1W**
(nie ma per-range fetchu), **Send i Swap wyłączone** (D-01/D-02), **More** bramkowane GNUS-em.
W szkicu wszystkie te stany są narysowane tak, jak działają naprawdę.

## How to View

```
open .planning/sketches/061-coin-page-in-app-language/index.html
```

Narzędzia w prawym dolnym rogu: Dark/Light · szerokość 1700/1280/900/420 · **Osie**.
Wykres ma żywy crosshair z tooltipem (najedź), Convert liczy Total na żywo, wyłączone akcje
naprawdę nie klikają.

## Variants

- **0 · Dziś** — stan z kodu: AppBar + okruszek, ramka 1200, brak navbara. Punkt odniesienia.
- **A · W ramie aplikacji ★** — strona wraca **pod navbar** (do `ShellRoute`), chip „← Markets",
  tożsamość monety jako `GWPageHeader` (ikona + nazwa + „BTC · Ethereum · #1"), cena + pigułka
  w slocie `trailing`, ramka 1536 z rynną 12. Układ wewnętrzny bez zmian. **Rekomendacja.**
- **B · Pasek stat** — A plus rząd kafli KPI (Rank / Market cap / Volume 24h / 24h range / From ATH)
  i wykres pełną szerokością. Najbliżej języka zakładki Markets, zużywa pola, które model ma, a
  ekran ignoruje.
- **C · Band** — pełnoszerokościowy pas z tożsamością, ceną i akcjami pod navbarem (chwyt z News,
  szkic 102), treść poniżej. Najmocniejsze „wejście" na stronę, ale trzecia warstwa chromu.
- **D · Moja pozycja** — trzy kolumny; po lewej Twoje saldo i wartość (`Coin.balance`), w środku
  wykres i Info, po prawej Convert. Zmienia pytanie strony z „ile kosztuje" na „ile mam".
- **E · Detal bez navbara** — ścieżka bez zmian w routerze: AppBar zostaje, ale strona pod nim
  przyjmuje ramkę i typografię aplikacji. Najtańsze, ale nie leczy braku nawigacji.

## What to Look For

1. **Przełącz 0 → A i patrz na górę okna.** W 0 nie ma navbara - z ekranu monety nie da się
   przejść na News bez cofania. To jest największa różnica i nie widać jej na screenshocie treści.
2. **Włącz „Osie" na A, B, E.** Tytuł ma lądować na tym samym X co „Markets" na zakładce Markets
   (rynna 12). W 0 zobaczysz, że siedzi ~170px dalej, bo ramka 1200 jest wycentrowana.
3. **Porównaj Info w 0 i w A/B.** Te same dane, cztery wiersze kontra osiem - bez nowego requestu.
4. **Zejdź na 900 i 420.** Który wariant przeżywa telefon bez przebudowy? (152 zamroziło dla
   <768 układ D - jedna kolumna; sprawdź, czy Twój faworyt do niego dojeżdża.)
5. **Wyłączone akcje.** Send i Swap są szare we wszystkich wariantach, bo takie są w kodzie.
   Jeśli któryś wariant wygląda dobrze tylko z pełnym rzędem żywych przycisków - kłamie.
