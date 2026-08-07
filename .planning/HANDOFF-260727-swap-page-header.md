# HANDOFF — Swap page header & buildout

**Sesja:** design (2026-07-26) · **Gałąź:** `redesign/jakub-260725b`
**Rola:** ta sesja **nie** była egzekutorem — nie tknęła `lib/`, `test/`, `macos/`, `packages/`.
**Produkt:** szkice 040 + 041, jeden todo, ta notatka.

---

## 1. O co chodziło

Jakub: *„chciałbym żeby Swap tab miał tytuł w page tam gdzie inne strony mają, praktycznie
top left — czy możemy jakoś to zdesignować by miało to ręce i nogi?"*

Stan wyjściowy: `GWPageHeader` rozciągał się na ramkę strony (`GeniusBreakpoints.xxl` = 1600),
a kolumna swapa była wycentrowana na 560px. Na 1700px dawało to **trzy niezależne osie** — tytuł
przy lewej rynnie, ikona `tune` przy prawej krawędzi, karta na środku — i nic ich nie wiązało.

---

## 2. Decyzja

**Szkic 041, wariant 3 · Ledger** — wybrany przez Jakuba 2026-07-26.

Tytuł zostaje **wyrównany do lewej**, na X ramki strony, tak jak Transactions / Markets / News.
Sensu nadaje mu **rozbudowa strony**: formularz 560px po lewej, a prawa strona to panel
**`Your swaps`** — lista historii z badge'ami statusu plus panel `Summary`.

Do tego dwie rzeczy dowiezione razem z wyborem:

- **Cały UI po angielsku** — `Your swaps`, `Completed / Pending / Failed`, `Total swaps`,
  `Fees paid`, `View all →`, daty `2h ago / Yesterday / 3d ago`, liczby w `en-US`.
- **Slippage: presety + ręczne pole z walidacją** — patrz sekcja 4.

Plik: `.planning/sketches/041-swap-page-buildout/index.html#ledger`
README z pełnym uzasadnieniem: `.planning/sketches/041-swap-page-buildout/README.md`

---

## 3. Ustalenia z kodu — czytaj przed planowaniem

Te cztery zmieniają obraz sprawy i **dwa z nich obalają wcześniejsze decyzje**.

| Źródło | Stan | Dowód |
|---|---|---|
| Historia swapów | ✅ **realna, produkowana przez ten sam ekran** | `swap_screen.dart:247` tworzy `Transaction(type: TransactionType.swap)`; model niesie `fromSymbol/toSymbol/fromAmount/toAmount/exchangeRate/fromIconUrl/toIconUrl/timeStamp/transactionStatus` — `packages/genius_api/lib/models/transaction.dart:74-134` |
| Trasa i koszty | ✅ realne, tylko niepokazane | `SquidRouteResponse`: `route` (lista hopów), `gasCosts[]`, `feeCosts[]`, `exchangeRate`, `aggregatePriceImpact`. `RouteDetailsCard` pokazuje z tego 4 wiersze |
| Dane rynkowe pary | ⚠️ model jest, integracji nie ma | `CoinGeckoMarketData` ma `sparkline`, `high24h`, `low24h`, `priceChangePercentage24h`, `ath`; ekran Swap go nie czyta |
| Salda tokenów | ⛔ **mock** | `squid_token_service.dart:36` → `return mockSquidBalances;`, prawdziwy fetch zakomentowany (linie 39-54) |

**Obalone:** szkic **105** odrzucił wariant A2 („Recent swaps") twierdząc, że danych nie ma.
Szkic **040** powtórzył ten sam błąd przy wariancie C. Obie decyzje były oparte na niesprawdzonym
założeniu. Historia swapów jest realna i **zapisywana przez ten sam ekran, który jej nie pokazuje**.

**Dlatego Desk (wariant 1) został odrzucony mimo że wygląda najlepiej** — jego lewa szyna stoi na
`mockSquidBalances`. Panel portfela na zmyślonych saldach w portfelu kryptowalutowym to nie
kwestia estetyki.

---

## 4. Slippage — osobny, niezależny defekt

Realny `SwapSettingsDrawer` (`swap_settings_drawer.dart:32-53`) ma **tylko** pole tekstowe i
`double.tryParse` **bez jakiegokolwiek zakresu**. Przyjmuje `0` (każdy swap padnie) i `900`
(użytkownik akceptuje dowolną cenę — scenariusz MEV). Brak presetów.

Wzorzec z walidacją: funkcja `slipState()` w `041/index.html`, czysta, bez DOM, z uruchamialnym
checkiem (`selfCheck()` — 10 przypadków, 4 poziomy, wynik w konsoli przy każdym ładowaniu).
Granice: `0 < x ≤ 50`, ostrzeżenie `> 5%` i `< 0.05%`, przecinek jako separator.

**Todo:** `.planning/todos/pending/2026-07-26-swap-slippage-has-no-range-validation.md`
**Ważne:** to jest **niezależne od layoutu**. Można naprawić wcześniej, osobno, bez czekania.

---

## 5. ⛔ BLOKER — konflikt w drzewie, rozwiąż PRZED kodowaniem

W drzewie leży **niezacommitowana** zmiana od równoległej sesji, która rozwiązuje ten sam problem
**w przeciwną stronę**:

```
lib/squid_router/swap_screen.dart:573-576
GWPageHeader(title: "Swap", subtitle: ..., centered: true, ...)

lib/components/scaffold/gw_page_header.dart  — nowa flaga `centered`
```

Komentarz w kodzie: *„Header lives INSIDE the focused column and centres over it (Jakub's call,
26-07): a left-gutter title with the form parked in the middle of a 1536 frame left the two
agreeing on nothing."*

To jest powrót do szkicu **105 A1** — tytuł wycentrowany nad kartą. **Ledger zakłada tytuł po
lewej.** Obie odpowiedzi są sensowne i wzajemnie się wykluczają.

**Dowód, że to nie pomyłka:** w snapshocie na starcie tej sesji `gw_page_header.dart` był czysty;
mtime obu plików to 2026-07-26 06:56-06:57. Zmiany są niezacommitowane, więc **nie ma ich w
reflogu** — nie szukaj tam.

**Rozstrzygnięcie należy do Jakuba.** Kolejność w tej rozmowie: najpierw poprosił o tytuł
top-left, potem — już po tym, jak `centered: true` wylądowało w drzewie — poprosił o rozbudowę
strony tak, **żeby left align miał sens**, i wybrał Ledger. Czyli **ostatnia wypowiedziana wola to
tytuł po lewej**. Ale nie potwierdzam tego za niego: zapytaj, zanim cofniesz cudzą pracę.

Flaga `centered` w `GWPageHeader` **nie musi ginąć** — jest additive i przyda się dla Feedback.
Do cofnięcia jest tylko `centered: true` w `swap_screen.dart` i przeniesienie nagłówka z powrotem
poza kolumnę 560px.

---

## 6. Stan sesji równoległej

**Aplikacja działa** — PID 42347 (`flutter run`) + 43362 (`Genius Wallet.app`), start 07:23.
To instancja **drugiej, egzekucyjnej sesji**, tej samej, która edytowała `swap_screen.dart`.
**Nie ubiłem jej.** Jeśli zaczynasz swoją sesję i widzisz czarne okno — to jest ta blokada
Hive, nie bug. Najpierw sprawdź `pgrep`, potem ubijaj, ale upewnij się, że tamta sesja skończyła.

---

## 7. Co ta sesja zapisała

| Plik | Uwaga |
|---|---|
| `.planning/sketches/040-swap-page-header/` | 6 widoków: dziś, A pasek, B jedna oś, C companion, D hybryda, A\|B obok siebie. Bez zwycięzcy — 041 go zastąpił |
| `.planning/sketches/041-swap-page-buildout/` | 5 schematów + dziś. **Zwycięzca: 3 · Ledger** |
| `.planning/todos/pending/2026-07-26-swap-slippage-has-no-range-validation.md` | nowy |
| `.planning/sketches/MANIFEST.md` | dwa wiersze dopisane |

**Przyznaję się do jednego przekroczenia:** wg `CLAUDE.md` `MANIFEST.md` jest plikiem
executor-only, a ja jako sesja design do niego dopisałem. Dwa wiersze, dopisane na koniec tabeli,
bez ruszania istniejących — ale jeśli druga sesja też go tknęła, to jest kandydat na konflikt.
**Nie** pisałem `HANDOFF.json`, `STATE.md` ani `ROADMAP.md` — właśnie dlatego, że druga sesja
żyje i ma jeden slot.

---

## 8. Czego ta sesja NIE zweryfikowała

**Nie widziałem renderu żadnego szkicu.** Playwright nie ma zainstalowanego Chrome
(`/Applications/Google Chrome.app` — brak), a rozszerzenie Claude-in-Chrome nie było podłączone.
Weryfikacja była wyłącznie strukturalna:

- 040: 149/149 divów, skrypt parsuje się
- 041: 186/186 divów, skrypt parsuje się, **zero polskich znaków w markupie okna**,
  check slippage przechodzi (10 przypadków, 4 poziomy)

Ktokolwiek to otworzy jako pierwszy — sprawdź, czy się nie rozjeżdża, i popraw, zamiast zakładać,
że jest dobrze.

Nie uruchamiałem też `flutter test` ani nie cytuję baseline'u — nie moja rola, a druga sesja
trzyma lock.

---

## 9. Następny krok dla sesji egzekucyjnej

1. **Rozstrzygnij bloker z sekcji 5 z Jakubem.** Nie zaczynaj od kodu.
2. Slippage (sekcja 4) można wziąć **od razu** — nie zależy od punktu 1.
3. Dopiero potem layout Ledger: `Your swaps` + `Summary` po prawej, tytuł po lewej.
   Źródło danych już jest, integracji do napisania zero — brakuje tylko odczytu istniejących
   `Transaction(type: swap)` i widoku.
