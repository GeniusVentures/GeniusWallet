# HANDOFF — page headers (Swap + Feedback) & coin-page sketches

**Data:** 2026-07-26 · **Branch:** `redesign/jakub-260725b` · **Sesja:** edytowała `lib/` i `test/` (rola executora)
**Uwaga na start:** w tym samym drzewie pracowała **druga sesja** i też edytowała `lib/` - patrz sekcja „Współdzielone drzewo".

Ten plik jest źródłem dla sesji, która robi pełne summary. Wszystko poniżej jest zweryfikowane
komendą, chyba że jawnie napisano inaczej.

---

## 1. Zmiany w kodzie (NIESKOMITOWANE)

Wszystkie trzy pliki `lib/` dotyczą jednego tematu: **gdzie siedzi tytuł strony na zakładkach formularzowych.**

### `lib/components/scaffold/gw_page_header.dart` (+79 linii, całość jest z tej sesji)
Nowy opcjonalny parametr **`centered`** (domyślnie `false`).
- `false` → dokładnie dotychczasowy render (Transactions / Markets / News nietknięte).
- `true` → tytuł i subtitle wyśrodkowane, `trailing` przypięty do prawej krawędzi przez `Stack`.

Dlaczego `Stack`, a nie Row z balansującym `SizedBox`: stary ręczny nagłówek swapa (przed migracją
`905a2a91`) balansował 24px pudełkiem 48px `IconButton`, czyli tytuł był o ~12px obok środka.
`Stack` centruje względem pełnej szerokości niezależnie od rozmiaru `trailing`.

### `lib/squid_router/swap_screen.dart`
`GWPageHeader` **przeniesiony z ramki strony (xxl) do wnętrza wyśrodkowanej kolumny 560**, z `centered: true`.
Ikona `tune` wraca na prawą krawędź kolumny, gdzie była przed `905a2a91`.

### `lib/logs/submit_logs_screen.dart`
To samo: nagłówek wewnątrz kolumny, `centered: true`, **karta zwężona 640 (`small`) → 560** (szerokość swapa),
plus `subtitle: 'Bug reports, ideas and questions go straight to the team.'`.

### `test/components/gw_page_header_centered_test.dart` (NOWY, untracked)
Dwa przypadki, arytmetyka na wyliczonej geometrii (nie golden):
tytuł i subtitle na środku kolumny (±0.5px), `trailing` na prawej krawędzi, wariant domyślny nadal do lewej.

> ⚠ **Nie przypisuj sobie całego diffu tych dwóch ekranów.** `submit_logs_screen.dart` i
> `swap_screen.dart` były `M` już **przed** startem tej sesji (patrz snapshot git w pierwszym
> promptcie). Z tej sesji pochodzą wyłącznie hunki nagłówka/szerokości opisane wyżej.
> `gw_page_header.dart` był czysty na starcie - ten diff jest w 100% z tej sesji.

### Historia decyzji (żeby nikt tego nie „poprawił" w tę i z powrotem)
1. Start: Feedback miał tytuł w lewej rynience + wycentrowaną kartę 640 → tytuł wisiał w próżni.
2. Próba 1: karta przy lewej krawędzi pod tytułem → **Jakub odrzucił**, „słabo wygląda".
3. Próba 2: powrót do wycentrowanej karty, tytuł zostaje w rynience → **odrzucone**, bo to stan wyjściowy.
4. **Stan końcowy: tytuł wjeżdża do środka kolumny 560, na Swapie i Feedbacku.**
   To jest powrót do decyzji **szkicu 105 A1**, którą shipowany kod wcześniej cofnął - `040-swap-page-header/README.md`
   nazywa to wprost regresją.

**Świadomy koszt:** Swap i Feedback nie mają już tytułu na tym samym X co Transactions/Markets/News.
Aplikacja ma teraz dwie rodziny stron: treściowe (tytuł w rynience, treść na 1536) i formularzowe
(wszystko wyśrodkowane na 560). **Bridge nie został sprawdzony** - jeśli nadal ma tytuł po lewej,
to trzecia strona formularzowa wypada z rodziny.

---

## 2. Co zweryfikowano, a czego NIE

**Uruchomione i zielone:**
- `flutter analyze` na `gw_page_header.dart`, `submit_logs_screen.dart`, `swap_screen.dart` → *No issues found*
- `test/components/gw_page_header_centered_test.dart` → 2/2
- `test/logs/submit_logs_feedback_test.dart` → 5/5
- `test/dashboard/transactions_page_frame_test.dart` → 9/9 (regresja nagłówka na stronach treściowych)

**NIE uruchomione:**
- pełny `flutter test` (baseline 285/1 wg STATE.md) - drzewo dzielone z drugą sesją, wynik byłby nieczytelny
- **walk w aplikacji** - żadna z tych zmian nie była oglądana na żywo, tylko w testach
- light mode - nietknięty (zgodnie z zasadą „dark first")

---

## 3. Szkice (nowe, untracked)

### `060-swap-companion-rail` — 5 wariantów, pending pick
Pytanie: czym wypełnić stronę Swap, żeby lewy tytuł miał czym rządzić.
0 · Dziś · **A · Szyna ★** (formularz 560 + szyna 440: Route / Recent swaps / Balances) ·
B · Portfolio-first · C · Wstęga · D · Warsztat (6 kafli) · **E · Checkout - odrzucony**
(wyprowadza CTA z formularza wbrew D-09/D-11).
Wszystko interaktywne, przełącznik **Pusty/Wypełnij** - warianty ocenia się w stanie PUSTYM.

### `061-coin-page-in-app-language` — 5 wariantów, pending pick
Pytanie: chrome strony coina (152 rozstrzygnęło treść, nie chrome).
0 · Dziś · **A · W ramie aplikacji ★** · B · Pasek stat · C · Band · D · Moja pozycja ·
E · Detal bez navbara.

`.planning/sketches/MANIFEST.md` - **dopisane dwa wiersze na końcu** (tylko append, żeby nie
nadpisać wpisów drugiej sesji).

### ⚠ Kolizja numeracji - trzecia w tym repo
Mój szkic startował jako `042` i został przenumerowany na **060**, bo druga sesja miała już
`042-navbar-no-cta`. W drzewie leżą też `041-navbar-cluster-heights` **i** `041-swap-page-buildout`.
Zakresy z `CLAUDE.md` nie wystarczyły - obie sesje jadą po tej samej puli 038+.
**Kolejne szkice tej linii proszę numerować od 062.**

---

## 4. Znaleziska z audytu kodu (fakty, nie opinie)

| Ustalenie | Dowód |
|---|---|
| **Historia swapów JEST realna** | `swap_screen.dart:247` zapisuje `Transaction(type: TransactionType.swap)`; `transactions_slim_view.dart:92` już filtruje po tym typie |
| Salda tokenów to mock | `squid_token_service.dart:36` → `return mockSquidBalances` |
| Trasa też jest mockiem | `squid_token_service.dart:59` → `return mockSquidRoute`; **cały ekran Swap stoi dziś na mockach** |
| `/token-info` stoi **poza `ShellRoute`** | `router.dart:242` - jedyna strona w apce **bez navbara**; ślepy zaułek nawigacyjny |
| Ramka coin page ≠ ramka zakładek | 1200 wycentrowane + padding 20, zamiast xxl 1536 + rynna 12 + `space32` |
| Coin page pokazuje 4 z ~15 pól | `CoinGeckoMarketData` ma dodatkowo `marketCapRank`, `high24h`/`low24h`, `fullyDilutedValuation`, `ath`+`athChangePercentage`, `maxSupply` - wszystko w Hive, nikt tego nie renderuje |

**Korekta wcześniejszego twierdzenia (moja pomyłka, do protokołu):** w trakcie sesji powiedziałem
Jakubowi, że historia swapów wymaga danych, których ekran nie ma, powołując się na szkice 105 i 040.
To nieprawda - `041-swap-page-buildout` złapał to pierwszy, a ja potwierdziłem w kodzie. Szkice
**105-A2 i 040-C zostały odrzucone na fałszywej przesłance** i można je otworzyć na nowo.

**Pułapka dla implementującego:** `_buildSectionTitle` w `token_info_screen.dart:42` (13px uppercase,
ze szkicu 152) **nie jest** `GWSectionTitle` (18px, rezerwuje ~44px min-height dla paneli Dashboardu).
Podmiana „dla spójności" po cichu rozjedzie geometrię kart.

---

## 5. Otwarta decyzja - blokuje wariant 061-A

Jeśli `/token-info` wraca do `ShellRoute`, trzeba rozstrzygnąć **którą zakładkę podświetla navbar**.
`_currentIndex` (`responsive_overlay.dart:88-95`) dopasowuje przez `startsWith` i **w razie braku
trafienia zwraca 0 → zapali się Dashboard**. Ten indeks leci do `BottomNavigationBar.currentIndex`
(linia 200), które **asertuje poprawny zakres - więc `-1` wywali apkę na mobile.**

- Opcja 1 (rekomendacja): mapuj `/token-info` → **Markets**. Cena: wejście z listy coinów na
  Dashboardzie (`coins_screen.dart:294`) też podświetli Markets.
- Opcja 2: pamiętaj zakładkę źródłową. Poprawniejsze, ale wymaga stanu.

Reszta wariantu A jest policzona i nie ma w niej niewiadomych: router (3 linie), slot `leading`
w `GWPageHeader` (~6 linii, addytywny), jawna wysokość dla `CryptoLiveChart` (ma wewnętrzny
`Expanded`), `TokenDetailHero` zostaje tylko dla <768 (układ D z 152), zamiana ramki 1200→xxl
(przelicz `SizedBox(height: 480)` karty głównej - było dobrane pod wąską ramkę), Info 4→8 wierszy
(czyste formatowanie). Zero zmian w danych, drawerach, Convert i w wyłączonych Send/Swap (D-01/D-02).
Dla tego ekranu **nie ma dziś testu widgetowego** (`token_info_loader_test.dart` testuje loader).

---

## 6. Zrobione świadomie NIE - nie „naprawiaj" tego

- **Zero commitów** (`CLAUDE.md`: do not create commits; commity i PR-y są bramkowane autoryzacją).
- **Nie uruchomiono `/gsd-pause-work`** - pisze do `HANDOFF.json` / `STATE.md`, czyli plików z jednym
  slotem, a w drzewie żyje druga sesja. Zamiast tego ten plik.
- **Nie ubito działającej aplikacji**, choć instancja żyje (patrz niżej) - `flutter run` może należeć
  do drugiej sesji, a zabicie cudzego procesu jest gorsze niż zostawienie locka.
- Light mode nietknięty.
- Bridge nie sprawdzony pod kątem nowej rodziny nagłówków.

---

## 7. Stan drzewa i strażnicy (zmierzone na koniec sesji)

**Aplikacja NADAL DZIAŁA** - jeśli następna sesja zobaczy czarne okno, to jest to, a nie bug:
```
PID 43362  .../Debug/Genius Wallet.app/Contents/MacOS/Genius Wallet
PID 42347  flutter_tools.snapshot run -d macos --dart-define=GW_DEV_TOOLS=true
```
Ubić dopiero po potwierdzeniu, że druga sesja tego nie używa: `kill 42347 43362`.

**`skip-worktree` - komplet 6 plików nienaruszony:**
`ios/Podfile.lock`, `ios/Runner.xcodeproj/project.pbxproj`, `ios/Runner/AppDelegate.swift`,
`ios/Runner/Info.plist`, `macos/Podfile.lock`, `macos/Runner.xcodeproj/project.pbxproj`.

**Fałszywy alarm w checkliście:** `git diff --name-only origin/HEAD..HEAD | grep -E "pbxproj|Info.plist|..."`
**nie jest pusty**, ale `origin/HEAD` = `origin/main`, a trafienia to stara historia upstreamu
(`d718996e "Try ad-hoc signing at build time on osx"`, `dc1e752f`, `20abc382`) odziedziczona przez
bazę brancha - **nic z tej sesji ani z prac UI**. Sensowne porównanie to baza `ui-redesign-port`,
która nie ma tu zdalnego odpowiednika.

**`cmake/CommonBuildParameters.cmake` i `cmake/DownloadDependencies.cmake`** - nadal
nieskomitowane, celowo (realne fixy upstreamu trzymane z boku).

**Nie moje w drzewie (druga sesja, nie ruszałem):** `lib/components/cards/gw_card.dart`,
`lib/components/overlay/responsive_overlay.dart`, `lib/reown/reown_connect_button.dart`,
`lib/theme/nav_chip_style.dart`, `lib/theme/genius_wallet_gradient.dart`, `lib/web/*`,
`lib/chart/crypto_simple_chart.dart`, `lib/dashboard/*`, `test/theme/nav_chip_style_test.dart`,
`test/components/gw_card_hover_test.dart`, szkice 038-044, katalogi `.planning/quick/*`,
`.planning/STATE.md`, `.planning/codebase/CONVENTIONS.md`.

---

## 8. Następne kroki

1. **Walk** trzech zmienionych ekranów (Swap, Feedback, dowolna zakładka treściowa jako kontrola) -
   nic z tej sesji nie było oglądane na żywo.
2. **Sprawdzić bridge** - czy dołącza do rodziny „tytuł w kolumnie", czy zostaje sam.
3. **Pick na 060 i 061** (oba pending), plus stary pick na `040` i `041`.
4. Rozstrzygnąć podświetlenie navbara z sekcji 5, potem 061-A to jeden mały plan.
5. Rozważyć otwarcie **105-A2 / 040-C** - odrzucone na fałszywej przesłance (sekcja 4).
