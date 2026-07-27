---
sketch: 060
name: swap-companion-rail
question: "Czym wypełnić stronę Swap, żeby tytuł wyrównany do lewej miał czym rządzić - pięć całych schematów, każdy z uczciwym stanem pustym?"
winner: null
tags: [swap, page-layout, companion, rail, left-align, data-honesty, squid, route, balances, recent-swaps, empty-state]
---

# Sketch 060: Swap companion rail

## Design Question

Jakub: *„co byś dodał do tego detajlu, oprócz po prostu opcji swapa, żebyśmy faktycznie mogli
utrzymać ten swap title po lewej stronie, left-aligned?"*

Szkic 040 zdiagnozował problem (tytuł na ramce 1600px nad kolumną 560px = trzy niezależne osie).
Ten szkic odpowiada na drugie pytanie: **czym zapełnić resztę strony**, żeby lewy tytuł przestał
być sierotą - i ile każdy wariant za to płaci.

## ⚠ Kolizja numeracji

Ten szkic powstał jako **042** i został przenumerowany na **060**, bo równoległa sesja miała już
`042-navbar-no-cta` (i `041-navbar-cluster-heights` obok `041-swap-page-buildout`). To trzecia
kolizja numerów w tym repo - dokładnie ta, przed którą ostrzega `CLAUDE.md`.

**Sesja równoległa zadała to samo pytanie w `041-swap-page-buildout`** (warianty: Desk / Para /
Ledger / Trasa / Warsztat). Oba szkice są niezależne i warto je obejrzeć razem: 041 wybiera treść
szyny na podstawie audytu danych, 060 pokazuje pięć różnych **struktur strony** dla tej treści.
Zgadzają się w dwóch punktach: „Warsztat" jako kafle i trasa jako główny kandydat na szynę.

## Ustalenia z kodu (przed rysowaniem)

| Źródło | Stan | Dowód |
|---|---|---|
| Historia swapów | ✅ **realna** | `swap_screen.dart:247` zapisuje `Transaction(type: TransactionType.swap)`; `transactions_slim_view.dart:92` już filtruje po tym typie |
| Trasa i koszty | ⚠️ realny kształt, mockowane wartości | `SquidRouteResponse` niesie `fromChain/toChain`, `route` (hopy), `gasCosts[]`, `feeCosts[]`, `exchangeRate`, `aggregatePriceImpact`; `RouteDetailsCard` pokazuje z tego 4 wiersze. Ale `getRoute` → `return mockSquidRoute` (`squid_token_service.dart:59`) |
| Salda tokenów | ⚠️ mock | `fetchBalances` → `return mockSquidBalances` (`squid_token_service.dart:36`), prawdziwy POST zakomentowany |
| Kurs pary / wykres | ⛔ brak integracji | `CoinGeckoMarketData` istnieje, ekran Swap go nie czyta |

**Wniosek, który zmienia wcześniejsze decyzje:** cały ekran Swap stoi dziś na mockach
(`getRoute` i `fetchBalances` zwracają stałe), więc „szyna na mockach" nie jest gorsza niż
formularz obok. Za to **historia swapów jest realna** - co obala odrzucenie A2 w szkicu 105
i C w szkicu 040. Ja też to wcześniej w tej rozmowie powiedziałem źle; 041 złapał to pierwszy.

## How to View

```
open .planning/sketches/060-swap-companion-rail/index.html
```

Narzędzia w prawym dolnym rogu: Dark/Light · szerokość okna 1700/1280/900 ·
**Wypełnij / Pusty** (przełącza wszystkie warianty między stanem startowym a wyceną) ·
**Osie** (linie wyrównania + czerwona strefa niewykorzystanej szerokości) · **Navbar**.

Wszystko działa naprawdę: wpisz kwotę, przełącz tokeny, kliknij flip, kliknij token na liście
sald (ustawia go jako „You Pay"), MAX, slippage w ustawieniach.

## Variants

- **0 · Dziś** — stan z kodu jako punkt odniesienia. Trzy osie, ~1000px pustki wokół karty.
- **A · Szyna ★** — formularz 560 pod tytułem (wspólna lewa krawędź) + szyna 440: Route /
  Recent swaps / Your balances. Blok 1024. **Rekomendacja.**
- **B · Portfolio-first** — lista sald po lewej pod tytułem, formularz po prawej. Strona zaczyna
  się od „co mam", nie „co zamieniam". Cena: formularz przestaje być pierwszy od lewej, a poniżej
  1180px kolejność kolumn się odwraca.
- **C · Wstęga** — bez szyny: pas trasy i kosztów na pełną ramkę pod nagłówkiem, karta 560 zostaje
  **wycentrowana** (105 A1 nietknięte). Cena: przed wyceną wstęga to rząd myślników na 1600px.
- **D · Warsztat** — formularz + szyna 700 jako siatka 6 kafli (Rate / Impact / Gas / Fee / Hops /
  Slippage) + salda. Blok 1284, czyli najmniej pustki. Cena: 6 nowych komponentów i głośny stan pusty.
- **E · Checkout** — lepki panel „Order summary" po prawej, **z przyciskiem Swap w środku**.
  Najlepiej zrównoważony wizualnie, ale wyprowadza CTA z formularza. Cena: drabina stanów CTA
  (`swap_cta_state.dart`, D-09/D-11 „mechanics preserved verbatim") i bliźniak-bridge.

## What to Look For

1. **Zacznij od „Pusty".** Tak wygląda strona przy każdym wejściu na zakładkę. Który wariant
   przetrwa brak wyceny? To jest właściwy test, nie stan wypełniony.
2. **Potem „Wypełnij".** W 0 wycena rozpycha kartę i spycha CTA. W A / D / E nic się nie rusza,
   bo wycena ma własne miejsce. Przełącz między 0 i A kilka razy z wpisaną kwotą.
3. **Włącz „Osie" na A i D.** Tytuł, lewa krawędź formularza i lewa krawędź CTA na jednej linii -
   to jest cała stawka „title left-aligned". Czerwona strefa po prawej pokazuje, ile szerokości
   wariant nadal marnuje (A: ~576px, D: ~316px na 1700).
4. **Przełącz na 1280 i 900.** Każdy wariant schodzi do jednej kolumny poniżej 1180px. Sprawdź,
   co ląduje na górze - w B zmienia się kolejność czytania.
5. **Light mode.** Panele w jasnym motywie stoją na `--surface-elevated` = biały na `--surface-base`
   = #DCE0E6; sprawdź, czy szyna nadal odcina się od tła.
6. **Uczciwość danych.** Tagi przy nagłówkach paneli (`realne` / `mock` / `mock-shape`) mówią,
   co jest czym. Panel bez tagu nie istnieje.
