---
sketch: 041
name: swap-page-buildout
question: "Czym rozbudować stronę Swap, żeby tytuł wyrównany do lewej faktycznie miał czym rządzić — używając wyłącznie danych, które aplikacja ma?"
winner: "3 · Ledger"
tags: [swap, page-layout, buildout, left-align, data-honesty, squid, transactions, coingecko, slippage]
---

# Sketch 041: Swap page buildout

## Design Question

Szkic 040 pokazał, że tytuł po lewej nad wycentrowanym formularzem 560px nie ma czym rządzić —
ramka strony ma 1600px, treść 560px, reszta to próżnia. Zamiast przesuwać tytuł, **rozbudowujemy
stronę**, żeby szerokość miała uzasadnienie. Pięć całych schematów.

## Ustalenia z kodu (przed rysowaniem)

| Źródło | Stan | Dowód |
|---|---|---|
| Historia swapów | ✅ **realna, produkowana przez ten ekran** | `swap_screen.dart:247` tworzy `Transaction(type: TransactionType.swap)`; model niesie `fromSymbol/toSymbol/fromAmount/toAmount/exchangeRate/fromIconUrl/toIconUrl/timeStamp/transactionStatus` (`packages/genius_api/lib/models/transaction.dart:74-134`) |
| Trasa i koszty | ✅ realne, tylko niepokazane | `SquidRouteResponse`: `route` (lista hopów), `gasCosts[]`, `feeCosts[]`, `exchangeRate`, `aggregatePriceImpact` — `RouteDetailsCard` pokazuje z tego 4 wiersze |
| Dane rynkowe pary | ⚠️ model jest, integracji nie ma | `CoinGeckoMarketData` ma `sparkline`, `high24h`, `low24h`, `priceChangePercentage24h`, `marketCap`, `ath`; ekran Swap go nie czyta |
| Salda tokenów | ⛔ **mock** | `squid_token_service.dart:36` → `return mockSquidBalances;`, prawdziwy fetch zakomentowany (linie 39-54) |

**To obala wcześniejszą decyzję.** Szkic 105 odrzucił wariant A2 („Recent swaps") twierdząc, że
danych nie ma, a szkic 040 powtórzył ten sam błąd przy wariancie C. Historia swapów jest realna
i zapisywana przez ten sam ekran, który jej nie pokazuje.

## How to View

```
open .planning/sketches/041-swap-page-buildout/index.html
```

Deep-linki: `#now` `#desk` `#pair` `#ledger` `#route` `#bench`.
Narzędzia (prawy dolny róg): Dark/Light · 1700/1280/900 · **Osie** · **Navbar**.

## Variants

We wszystkich pięciu tytuł stoi **na X lewej rynny ramki strony** — tym samym co Transactions,
Markets i News. Różni je to, czym ta szerokość zostaje wypełniona.

- **0 · Dziś** — punkt odniesienia, formularz sam na 1600px.
- **1 · Desk** — trzy kolumny: tokeny / formularz / historia. Najgęstszy.
  ⛔ Lewa szyna stoi na mocku (`SquidBalance`).
- **2 · Para** — pas tożsamości pary pod tytułem: cena, zmiana 24h, wykres 7d na całą ramkę,
  panel rynkowy z boku. ⚠️ Wymaga podpięcia `CoinGeckoMarketData` do ekranu Swap.
- **3 · Ledger ★** — formularz + „Twoje swapy" z badge'ami statusu i podsumowaniem.
  ✅ Zero nowych integracji.
- **4 · Trasa** — rozwinięty eksplorator trasy: hopy, gas per krok, rozbicie opłat.
  ✅ Dane są w `SquidRouteResponse`, tylko niepokazane.
- **5 · Warsztat** — pasek narzędzi z chipami + stos małych paneli. Najbardziej modularny,
  każdy panel dowożony osobno.

## Decyzja: 3 · Ledger (Jakub, 2026-07-26)

Wybrany. Dwie poprawki dowiezione razem z wyborem:

**1. Cały UI po angielsku.** Wszystkie stringi w oknie aplikacji są po angielsku — `Your swaps`,
`Completed / Pending / Failed`, `Total swaps`, `Fees paid`, `View all →`, daty jako `2h ago /
Yesterday / 3d ago`. Formatowanie liczb przełączone z `pl-PL` na `en-US`. Komentarz szkicu
(`.lede`) i ten README zostają po polsku — to notatki, nie interfejs.

**2. Slippage: presety + ręczne pole z walidacją.**

Realny `SwapSettingsDrawer` ma **tylko** pole tekstowe i `double.tryParse` bez żadnego zakresu
(`swap_settings_drawer.dart:32-53`) — przyjmuje `0`, przy którym każdy swap padnie, i `900`, przy
którym użytkownik zostaje obrobiony. Mój pierwszy mockup miał odwrotny błąd: same presety, zero
wpisywania. Teraz jest jedno i drugie:

| wejście | wynik |
|---|---|
| puste | presety rządzą, Apply trzyma aktywny |
| `0`, `-1`, `abc` | ⛔ blokada, Apply wyłączony |
| `> 50` | ⛔ `Slippage cannot exceed 50%` |
| `> 5` | ⚠️ `High slippage — your trade can be frontrun` |
| `< 0.05` | ⚠️ `Very low — the swap will likely fail` |
| `0,5` | ✅ przecinek akceptowany jako separator |

Granice: `SLIP_MIN = 0.05`, `SLIP_WARN_HI = 5`, `SLIP_MAX = 50`. Logika siedzi w `slipState()`,
czystej funkcji bez DOM, i ma **uruchamialny check** — 10 przypadków i 4 poziomy sprawdzane przy
każdym ładowaniu strony, wynik w konsoli (`slippage check OK`). Ten sam zestaw przypadków przechodzi
do Darta razem z portem.

## Uzasadnienie wyboru

★ **3 · Ledger.** Jedyny wariant zbudowany w całości na danych, które ten ekran **sam już
zapisuje** — zero nowych integracji, zero mocków, zero czekania na czyjąś robotę. Do tego mówi
tym samym językiem co zakładka Transactions, więc tytuł po lewej czyta się jak reszta aplikacji,
a nie jak wyjątek. Domyka też pętlę, która dziś jest urwana: robisz swap, ekran zapisuje
transakcję i natychmiast o niej zapomina.

**Wicelider: 4 · Trasa.** Dane równie realne, ale odpowiada na pytanie, które zadaje mniejszość
użytkowników („którędy właściwie idą moje pieniądze"). Świetny jako **druga** faza — 3 i 4 składają
się w jedną stronę bez konfliktu.

**Odrzucony: 1 · Desk.** Wygląda najlepiej ze wszystkich i jest najgorszym wyborem: lewa szyna
to `mockSquidBalances`. Shipowanie panelu portfela na zmyślonych saldach w portfelu
kryptowalutowym to nie kwestia estetyki.

## What to Look For

1. **Włącz „Osie".** We wszystkich wariantach tytuł i pierwsza kolumna treści dzielą jedną
   krawędź — sprawdź, czy to widać bez linijki.
2. **Zwęź do 1280 i 900.** Desk gubi szynę przy 1300, wszystkie schodzą do jednej kolumny
   przy 1000. Czy któryś rozpada się brzydko?
3. **Tagi pochodzenia** na nagłówkach paneli: zielony = dane realne, niebieski = model istnieje
   ale trzeba podpiąć, bursztynowy = mock. Policz bursztynowe przed wyborem.
4. **Light mode** — panele boczne mają w jasnym motywie inny kontrast niż karta formularza.
