---
sketch: 062
name: ledger-variants
question: "Skoro tytuł Swapa idzie po lewej (041/3 Ledger), czym wypełnić prawą stronę — i które dane naprawdę mamy?"
winner: null
tags: [layout, swap, ledger, data-provenance]
depends_on: [041, 060]
---

# Sketch 062: Ledger — 5 wariantów z metryką pochodzenia danych

## Design Question

041/3 „Ledger" wygrał: tytuł Swapa wraca na X ramki strony, a sens nadaje mu rozbudowa
prawej strony. Ten szkic pyta o **dwie rzeczy naraz**:

1. Jaki kształt ma ta rozbudowa? (5 wariantów)
2. **Które dane pod nią naprawdę istnieją?** Każdy punkt danych w każdym wariancie nosi
   metrykę: `HAVE` / `EASY` / `BUILD`.

Punkt 2 jest tu ważniejszy. Historia tego ekranu to dwa odrzucenia na fałszywej przesłance
(105-A2 i 040-C odpadły, bo ktoś założył, że danych nie ma) i jedno przyjęcie na przesłance
zbyt optymistycznej (041 ogłosiło Ledger „zero mocków"). Metryki są po to, żeby trzeci raz
się to nie zdarzyło.

## How to View

```
open .planning/sketches/062-ledger-variants/index.html
open '.planning/sketches/062-ledger-variants/index.html?empty=1'   # od razu pusty portfel
```

Przełączniki w pasku legendy: **Metryki** (pokaż/ukryj pigułki + obwódki),
**Wypełnione / Pusty portfel**, **Oś tytułu**, motyw, szerokość okna (1740 / 1536 / 1280 / 1024).

## Warianty

- **A · Rail ★** — formularz 560, po prawej `Your swaps` (elastyczna) + `Summary` 300. Prosta realizacja 041/3.
- **B · Ribbon** — podsumowanie jako pełnowymiarowy pas pod tytułem, potem formularz + historia.
- **C · Receipt** — szyna zmienia rolę: rozbite koszty trasy gdy wpisujesz kwotę, historia gdy formularz pusty.
- **D · Ledger** — formularz + statystyki + rozbicie kosztów na górze, pod spodem **pełnowymiarowa tabela** swapów.
- **E · Console** — trzy kolumny (tokeny / formularz / activity). **Odrzucony** — lewa szyna stoi na mocku.

---

## Metryka pochodzenia — pełna tabela z dowodami

### `HAVE` — mamy, ten ekran już to czyta albo zapisuje

| Dana | Dowód |
|---|---|
| **Historia swapów** — cała lista | `swap_screen.dart:277` → `transactionsCubit.addTransaction(tx)` **oraz** `:280` → `TransactionStorageService().addTransaction(...)`. Cubit jest już czytany w tym pliku (`:232`), więc odczyt to jeden `BlocBuilder` + filtr `type == TransactionType.swap`. |
| `fromSymbol` `toSymbol` `fromAmount` `toAmount` `exchangeRate` `timeStamp` `fromIconUrl` `toIconUrl` | `transaction.dart:95-134` — pola 10-16, dodane wprost pod swapy. Wszystkie zapisywane przez `swap_screen.dart:236-268`. |
| **Sortowanie po dacie** | `transactions_cubit.dart:_sorted()` sortuje malejąco po `timeStamp`. Za darmo. |
| **Wyceny USD** | `livePricesBySymbol()` (`transaction_utils.dart:133`) czyta Hive `marketDataBox`, który panel Assets już wypełnia. **Zero nowych zapytań sieciowych.** Sufit: pokrycie = to, co pobrał Assets. |
| **Agregaty** (Volume, Top pair) | Czysty `fold` po liście, którą już mamy. Zero nowego źródła. Logika w `summarize()` w tym szkicu, z uruchamialnym checkiem. |

> **Zmiana 26-07 (Jakub):** `Total swaps` i `Settled` **usunięte z panelu Summary**. Liczba swapów
> nie jest informacją, po którą ktoś przychodzi na tę stronę, a jako pierwsze dwa wiersze spychały
> `Volume` i `Top pair` na dół panelu. `summarize()` nadal je liczy — używa ich pas statystyk w B/D.

### `EASY` — jest w modelu/odpowiedzi, nikt tego nie renderuje

| Dana | Dowód |
|---|---|
| `gasCosts[].gasPrice` `.maxFeePerGas` `.maxPriorityFeePerGas` `.estimate` `.limit` `.amountUSD` | `squid_token_service.dart:105-118` — komplet w odpowiedzi. `RouteDetailsCard` (`:54-63`) pokazuje **cztery wiersze** z całości. |
| `feeCosts[].name` `.description` `.percentage` `.amountUSD` | `squid_token_service.dart:127-148`. „Gas Receiver Fee" ma opis, którego nikt nie wyświetla. |
| `fromChain` / `toChain` / `routeId` | `squid_route_response.dart:6-9`. |
| `SquidBalance.decimals` / `.chainId` + własne helpery formatujące | `squid_balance.dart:3-8, 49-62`. |
| **Gotowy wiersz transakcji** | `TransactionRow(tx:, onTap:)` — `transaction_displays.dart:200`. Obsługuje swapy przez `txRowContent`. Listy **nie piszemy od zera**. |
| **Drawer szczegółów** | `showTransactionDetails()` — `transaction_displays.dart:430`, ma swap-specyficzne wiersze From/To/Rate. Kliknięcie wiersza ma działający cel. |
| **Badge'y statusów** | `TransactionBadge` + `badgeSpec()` — `transaction_badge.dart:43,160`. Swap / pending / failed już istnieją. |

> ⚠️ **Zastrzeżenie do całego `EASY`:** odczyt jest łatwy, ale odpowiedź to `mockSquidRoute`
> (`squid_token_service.dart:59`). Liczby są **prawdziwie ukształtowane, nie prawdziwe.**

### `BUILD` — brak kodu albo integracja stoi na mocku

| Brak | Dowód | Kogo dotyczy |
|---|---|---|
| **Salda tokenów** | `squid_token_service.dart:36` → `return mockSquidBalances;`, prawdziwy fetch zakomentowany (39-54) | wiersze `Balance` w formularzu **wszędzie**; cała lewa szyna w **E** |
| **Trasa i kwotowanie** | `squid_token_service.dart:59` → `return mockSquidRoute;` | karta `Pricing / Slippage / Price impact / Fees` **wszędzie** |
| **Lista hopów** | `mockSquidRoute.route` to dosłownie `[/* ... as before ... */]` — **pusta tablica** | panel `Route` w **C** |
| **Statusy `Pending` / `Failed`** | `swap_screen.dart:246` hardkoduje `transactionStatus: TransactionStatus.completed`. Żadna ścieżka kodu nie produkuje dla swapa innego statusu | badge'y w **A/B/C/E**, kolumna `Status` w **D** |
| **Hash / link do explorera** | `swap_screen.dart:238` → `hash: ""` | kolumna `Tx` w **D** |
| **Sam swap** | `swap_screen.dart:227` → `// TODO: invoke Squid API`. Transakcja jest zapisywana dla swapa, **który się nie wykonał** | fundament pod wszystkim powyżej |
| **Opłaty** — i to jest **błąd, nie luka** | `swap_screen.dart:243` → `fees: fromAmount`. Do pola opłaty trafia wymieniana kwota, a `transaction_displays.dart:474` renderuje ją jako **„Network Fee"** | `Fees paid` w Summary. Osobny todo: `2026-07-26-swap-writes-the-swap-amount-into-the-fees-field.md` |
| **`initialFilter` dla „View all"** | Cel **istnieje** (`/transactions` + `Filters.swap`, `transactions_slim_view.dart:92`), ale `selectedFilter` to prywatny stan startujący na `Filters.all` (`:181`) | link `View all →`. ~20 linii w 3 plikach, addytywnie. **Jedyna pozycja, która nie czeka na Squid.** |

---

## Korekta wobec HANDOFF-swap-page-header.md

Tamten dokument opisał Ledger jako *„jedyny wariant zbudowany w 100% na danych, które ten ekran
sam już zapisuje. Zero nowych integracji, zero mocków."*

**Połowa jest prawdą.** Historia faktycznie jest realna i persystowana — to ustalenie się broni.
Ale zdanie pomija, że rekord opisuje swap, który nigdy się nie odbył, ma pusty hash i jeden
możliwy status. Trzystanowe badge'y z 041 **nie mają dziś producenta**.

To nie unieważnia wyboru Ledgera — unieważnia oczekiwanie, że wystarczy narysować.

## Rachunek backendu w samym szkicu

Pod oknem aplikacji siedzi sekcja **„Backend — czego nie ma"**: 7 pozycji, każda z wagą
(`bloker` / `błąd` / `mock` / `brak`), plikiem i linią, skutkiem i tym, **których wariantów dotyczy**.
Przełączenie wariantu przelicza licznik i podświetla tylko te pozycje, które jego obciążają —
`A · Rail` ma **4 z 7**, `E · Console` wszystkie.

Elementy `BUILD` w samym mockupie mają skos na tle, nie tylko pigułkę: skos widać, zanim
ktokolwiek przeczyta etykietę.

Lista ma własny uruchamialny check (`backendCheck()`): pada, jeśli pozycja straci źródło
`plik:linia`, wskaże nieistniejący wariant albo jeśli któryś wariant zostanie bez ani jednej
pozycji. Literówka w `hits` sprawiłaby, że wariant wygląda na tańszy, niż jest — czyli dokładnie
ten błąd, który ten szkic ma eliminować.

## What to Look For

1. **Przełącz na `Pusty portfel`, zanim cokolwiek ocenisz.** Wypełniony stan pochlebia każdemu
   wariantowi. B pokazuje wtedy cztery kafle z trzema kreskami tuż pod tytułem — to jego realny koszt.
2. **Włącz `Oś tytułu`.** Ledger stoi na jednej obietnicy: tytuł, treść i pigułka slippage
   zgadzają się co do lewej i prawej rynny. Pierwsza wersja tego szkicu **łamała to w A i C**
   (szyna 440 kończyła treść na 1024, a pigułka wisiała na 1600 — trzy osie, ta sama choroba,
   którą Ledger miał wyleczyć). Poprawione: szyna dociąga do rynny.
3. **Policz żółte pigułki w każdym wariancie.** To jest miara „ile z tego mogę zobaczyć w tym
   tygodniu". A ma ich najmniej poza samym formularzem; C i D mają najwięcej.
4. **W C skasuj kwotę w polu `From`** — szyna przełącza się z kosztów na historię.
5. Szerokości: sprawdź **1280**, nie tylko 1740. Realna ramka aplikacji to 1536.

## Rekomendacja

**★ A · Rail** — nie dlatego, że najładniejszy (D wygląda najmocniej), tylko dlatego, że jest
jedynym wariantem, którego prawa strona nie obiecuje niczego, czego dziś nie ma. Jeden
`BlocBuilder`, jeden `fold`, zero nowych źródeł.

**Wicelider: D · Ledger.** Najlepiej wykorzystuje 1536px i jako jedyny pokazuje wszystkie pola,
które `Transaction` naprawdę niesie. Stanie się najmocniejszy **po** podpięciu prawdziwego swapa —
dziś jego dwie ostatnie kolumny są martwe, a tabela z pustymi kolumnami czyta się jak zepsuta.

**Odrzucony: E · Console.** Lewa szyna to `mockSquidBalances`. Panel „twoje tokeny" ze zmyślonymi
saldami w portfelu kryptowalutowym to nie kwestia gustu. Ta sama wada wyeliminowała 041/1 Desk.

## Zweryfikowane

- Wyrenderowane w Chrome for Testing (headless), wszystkie 5 wariantów, stan pełny i pusty.
  *(Poprzednia sesja zgłosiła brak Chrome — szukała tylko `/Applications/Google Chrome.app`;
  binarka jest w `~/Library/Caches/ms-playwright/chromium_headless_shell-1228/`.)*
- `summarize()` — 9 przypadków, przechodzi (pusty portfel, mieszane statusy, brak ceny).
  Check leci w konsoli przy każdym załadowaniu. To ta logika pójdzie do Darta jako `fold`.
- Znaczniki zbilansowane (88/88 `div`), JS parsuje się (`node --check`).
- Zero polskich znaków w oknie aplikacji — cały UI po angielsku, zgodnie z decyzją z 041.
- **Nie sprawdzone:** light mode (zasada „dark first"), szerokości poniżej 1024.
