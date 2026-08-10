# HANDOFF - Feedback page frame + drawer language rollout

**Data:** 2026-07-26 (do wczesnych godzin 27) · **Branch:** `redesign/jakub-260726b`
**Rola sesji:** design + planowanie GSD. **Nie tknęła `lib/`, `test/`, `macos/`, `packages/`.**
**Produkt:** 2 szkice, 2 nowe fazy w roadmapie (20 i 21), 7 planów, 2 pliki CONTEXT.
**Zero commitów.** `STATE.md` i `HANDOFF.json` nietknięte celowo (jeden slot, żyje druga sesja).

---

## 1. Co powstało

| Artefakt | Stan |
|---|---|
| `.planning/sketches/153-feedback-page/` | 6 widoków (dziś + A-E). **Jakub wybrał B · Focused frame** |
| `.planning/sketches/154-transaction-details-drawer/` | 6 widoków (dziś + A-E). **Jakub wybrał A · 031-B1 as decided** |
| `.planning/ROADMAP.md` | **Phase 20** i **Phase 21** dopisane; wpis Phase 19 naprawiony; tabela postępu i mapa własności powierzchni uzupełnione |
| `.planning/phases/20-feedback-page-frame-.../` | `20-CONTEXT.md` (D-01..D-07) + `20-01-PLAN.md` |
| `.planning/phases/21-drawer-language-rollout-.../` | `21-CONTEXT.md` (D-01..D-09) + `21-01..21-06-PLAN.md` |

Oba zestawy planów przeszły `gsd-plan-checker` → **VERIFICATION PASSED**, bez blokerów i ostrzeżeń.

---

## 2. Phase 20 - Feedback page frame (153-B)

**1 plan, 1 fala, 3 zadania, test-first.** Jeden plik pod `lib/`: `lib/logs/submit_logs_screen.dart`.

Ramka `xxl` → `GeniusBreakpoints.large` (1024, istniejący token), tytuł wraca na lewą krawędź ramki,
`LayoutBuilder` daje formularz 640 + szynę „What gets sent", pasek chipów znika z formularza, plus fix
stopki w stanie Failed. Nowy check: `test/logs/submit_logs_page_frame_test.dart`.

**⚠ Ta faza usuwa `centered: true` z `submit_logs_screen.dart:440`** - niezacommitowaną zmianę
równoległej sesji, opisaną w `HANDOFF-swap-feedback-header-and-coin-sketches.md` jako świadomą.
Jakub wybrał 153-B z tym konfliktem na stole. **Sama flaga `centered` w `GWPageHeader` zostaje**,
`swap_screen.dart` jest poza zakresem (to decyzja Phase 8).

**Phase 20 supersedes wyłącznie klauzulę „centered `GWPageHeader`" z celu Phase 19.** Phase 19 zostaje
`status: passed` - jego walk i podpisany override dalej obowiązują dla karty, której 20 nie dotyka.

---

## 3. Phase 21 - Drawer language rollout

**6 planów, 3 fale, 15 zadań, 7 checków.** Żadne dwa plany w tej samej fali nie dzielą pliku.

| Fala | Plan | Pliki |
|---|---|---|
| 1 | 21-01 | `responsive_drawer.dart`, nowy `drawer_content.dart`, `genius_wallet_gradient.dart`, `token_selector_drawer.dart` |
| 2 | 21-02 | listy: sieć, konta, SDK accounts, bridge |
| 2 | 21-03 | `transaction_displays.dart` - paragon transakcji |
| 2 | 21-04 | 5 drawerów wynikowych (swap ×3, banxa ×2) |
| 2 | 21-05 | `approve_transaction_drawer.dart`, `approve_dapp_connection_drawer.dart` + threat model |
| 3 | 21-06 | Receive, reszta, **sweep** + todo z defektami poza zakresem |

**Fala 1 musi wejść pierwsza.** D-01 wymaga, żeby wspólny padded body istniał zanim ktokolwiek go
przyjmie, i żeby ad-hoc padding każdego wywołującego znikał w tej samej zmianie, która przyjmuje
wspólny. Inaczej ktoś zostanie wypełniony podwójnie albo wcale.

### Trzy decyzje, które planner podjął sam - nie „popraw" ich bez czytania uzasadnienia

1. **Linia fiat w drawerze podpisującym jest wycięta, nie gwiazdkowana.** 033-B1 miał `*`. Wpięcie
   ceny na żywo dokłada dane do ścieżki podpisu; zostawienie niewpiętej liczby drukuje potencjalnie
   błędną kwotę obok sumy, którą użytkownik autoryzuje. Zapisane w planie, w komentarzu w kodzie i w
   summary, ze ścieżką odwrotu. **Jedyny element zatwierdzonego szkicu, którego faza nie implementuje.**
2. **D-03 „kwota zostaje neutralna" przeinterpretowane** na *paragon nie zawiera koloru kwoty
   wyprowadzonego ze statusu*. Powód: `txRowContent.tone` jest zależny od statusu z założenia i został
   przeliczony do AA w 12-02; wymuszenie neutralnej kwoty poróżniłoby drawer z jego własnym wierszem.
3. **Dwa drawery w `wallet_information.g.dart:151,195` wyłączone z konwersji** - plik jest poza
   `flutter analyze`, jedyny importer to canary dev-owy, żadnej żywej trasy. Wpisane na listę wyjątków
   w sweepie, więc wypłyną, gdyby je kiedyś zamontowano.

### Inwentarz w roadmapie był mój i był błędny w czterech miejscach

Planner sprawdził, checker potwierdził przeciwko źródłu: `coins_screen.dart` **nie ma** drawera
„Assets" (to `GWSectionTitle`), „Rename Wallet"/„Delete wallet" to `GWDialog.show`, „Network Changed"
to toast, „No coins yet" to `GWEmptyState`. Wpisy w ROADMAP zostały skorygowane. Lista drawerów-list
ma **5** pozycji, nie 6.

---

## 4. Znaleziska z kodu (fakty, nie opinie)

| Ustalenie | Dowód |
|---|---|
| Drawer transakcji nie ma paddingu poziomego | `_buildDetailsCard`, `transaction_displays.dart:421` - `EdgeInsets.symmetric(vertical: space2)` i nic więcej |
| 07-06 **celowo** nie dodał globalnego paddingu | `07-06-SUMMARY.md`: część z ~19 wywołujących paduje się sama, globalny padding by je zdublował. Phase 21 rozwiązuje to prymitywem opt-in |
| `_statusPill` **istnieje i jest poprawny**, ale drawer go nie używa | `transaction_displays.dart:49-75`, cztery stany z właściwymi tokenami, w tym `cancelled` → slate |
| Paragon **wyrzuca** fiat i kwotę dokładną | `showTransactionDetails:432` woła `txRowContent(tx, prices: livePricesBySymbol())`, `valueLine` i `exactAmount` są liczone i nieużyte. **To koryguje szkic 031** („the receipt has no fiat" - było prawdą, gdy 031 powstawał) |
| Padding ciała drawerów jest dziś pisany na 5 sposobów | `all(8)`, `all(16)`, `space10`, `space16`, `symmetric(...)`, plus brak |
| Feedback: `_candidateLogNames` to **dwuelementowa stała** | `submit_logs_screen.dart:97` - szyna nigdy nie pokaże więcej niż dwóch logów |

---

## 5. Stan drzewa - przeczytaj przed egzekucją

**Równoległa sesja pisała do `lib/` w trakcie tej rozmowy.** Na starcie były zmodyfikowane 3 pliki
`lib/`; na koniec 8 - doszły `bridge_screen.dart`, `route_details_card.dart`, `swap_field.dart`,
`formatters.dart`. **`bridge_screen.dart` jest w zakresie planu 21-02.** Upewnij się, że tamta sesja
skończyła, zanim odpalisz falę 2.

Aplikacja prawdopodobnie nadal chodzi (PID 42347 `flutter run`, 43362 `Genius Wallet.app`) - jeśli
zobaczysz czarne okno, to lock Hive, nie bug.

`.planning/sketches/MANIFEST.md` jest brudny od drugiej sesji. **Nie dopisywałem do niego** (plik
executor-only). Gotowe wiersze dla szkiców 153 i 154 leżą w ich README, w sekcji „MANIFEST row";
zadanie 3 planu `20-01` dopisuje wiersz 153 append-only ze sprawdzeniem duplikatu.

---

## 6. Zrobione świadomie NIE

- **Zero commitów** (`CLAUDE.md`), mimo że `commit_docs` w GSD jest `true`.
- **`STATE.md` nietknięty** - ma jeden slot i śledzi Phase 07/08 drugiej sesji. Roadmapa niesie pełny
  zapis obu nowych faz, więc nic się nie gubi. Kroki 13b/13d workflow plan-phase pominięte świadomie.
- **`HANDOFF.json` nietknięty** - ten sam powód.
- Nie uruchamiałem `flutter test` ani nie cytuję baseline'u - nie moja rola, drzewo dzielone.
- Light mode nietknięty (zasada dark-first).
- Frontmatter `winner:` w README szkiców 153 i 154 nadal `null`. Dla 153 ustawia go zadanie 3 planu
  20-01. **Dla 154 nikt tego nie robi - do dopisania ręcznie przy egzekucji Phase 21.**

---

## 7. Następne kroki

1. `/gsd-execute-phase 20` - jeden plik, najmniejsze ryzyko, dobra rozgrzewka.
2. `/gsd-execute-phase 21` - **fala 1 przed resztą**. Fala 2 dopiero, gdy równoległa sesja zwolni
   `bridge_screen.dart`.
3. Po 21-06: przejrzeć wygenerowany plik todo z pięcioma defektami poza zakresem (martwy przycisk
   cancel w Banxie, niezabezpieczony `launchWebSite` w `swap_result_drawer.dart`, nieużywany wymagany
   `dappName`, bliźniacze shelle swapa).
4. Walk obu faz - nic z tej sesji nie było oglądane w działającej aplikacji.
