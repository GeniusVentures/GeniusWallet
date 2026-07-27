# HANDOFF — Swap form polish, drawer form-archetype, sketches 062/063

**Sesja:** 2026-07-26 22:20 → 2026-07-27 00:2x · **Gałąź:** `redesign/jakub-260726b`
**Rola:** executor — edytowała `lib/` i `test/`. **Zero commitów** (`CLAUDE.md`).
**Bramka na koniec:** `flutter analyze lib` = **59** (baseline ≤61) · `flutter test` = **319 pass / 1 fail**.
Ta jedna padająca to `test/local_wallet_storage_test.dart` — plik bez `main()`, ta sama z baseline'u `285/1`. Nietknięta.

---

## 1. ⛔ PRZECZYTAJ NAJPIERW — kolizja z fazą 21

Między 00:00 a 00:20 równoległa sesja utworzyła **fazę 21 „Drawer language rollout"** z sześcioma
planami. Jej zakres pokrywa się **co do pliku** z ostatnią godziną pracy tej sesji:

| Plan fazy 21 | Plik | Stan po tej sesji |
|---|---|---|
| **21-01** | `lib/components/bottom_drawer/responsive_drawer.dart` | **JUŻ ZMIENIONY** (tytuł 18px, `titleSpacing` 20, toolbar 56) |
| **21-01** | `lib/squid_router/token_selector_drawer.dart` | **PRZEPISANY** na 032-A1 |
| **21-06** | `lib/squid_router/swap_settings_drawer.dart` | **PRZEPISANY** na 063-A |

**To nie jest sprzeczność co do kierunku** — obie strony realizują te same zatwierdzone decyzje
(030-B1, 032-A1). Ale kto wejdzie w 21-01/21-06, zastanie drzewo, w którym część roboty jest już
zrobiona, inaczej rozłożona i **nieskomitowana**. Przed egzekucją tych dwóch planów trzeba
zdecydować: przyjąć to, co jest, czy cofnąć i pojechać planem.

Faza 21 wprowadza też `lib/components/bottom_drawer/drawer_content.dart` — wspólne prymitywy treści.
Ta sesja **ich nie utworzyła**; kontrolki (preset chip, wiersz listy, tint zaznaczenia) siedzą lokalnie
w swoich dwóch plikach. Jeśli 21-01 je wprowadzi, oba pliki należy na nie przepiąć.

---

## 2. Zmiany w kodzie (NIESKOMITOWANE)

### Formularz Swap — polish bez ruszania layoutu i kolorów
Jakub: *„zostajemy z tym, jak wygląda obecnie Swap"* — układ, pozycje, tło i kolory nietknięte.

- **`lib/utils/formatters.dart`** — `DecimalTextInputFormatter` **przeniesiony** z `bridge_screen.dart:1039`.
  Bridge miał walidację od 08-04, Swap **nie miał żadnej**, a to bliźniaki (D-11). Dwie nowe rzeczy:
  przecinek → kropka (europejska klawiatura; `double.tryParse('1,5')` zwraca `null`, więc pole wyglądało
  na wypełnione, a wycena widziała brak kwoty) oraz `decimalRange`, który realnie ogranicza precyzję —
  stary docstring twierdził „limited decimals", a wzorzec pozwalał na dowolną liczbę cyfr.
  Wywołanie w Bridge **bez zmian** (`decimalRange: null` = stare zachowanie).
- **`swap_field.dart`** — formatter z `decimalRange: selectedToken.decimals`; pole **„You Receive"
  `readOnly`** (jego `onChanged` robił tylko `setState`, a następna wycena i tak nadpisywała wpisane);
  hover na pigułce tokena i MAX-ie (app-wide przepis 044); placeholder logo na czas ładowania;
  `contentPadding` przypięty jawnie do zmierzonych 8px.
- **Niebieska ramka na focusie — usunięta.** Przyczyna: `theme.dart:242` ustawia app-wide
  `focusedBorder`, a `border: InputBorder.none` to **tylko fallback** — stan zawsze bije fallback.
  Naprawione przez jawne wyciszenie stanów. **Ta sama przyczyna dotyczy każdego pola w apce, które
  deklaruje się jako bezramkowe** — warto przejrzeć resztę.
- **`route_details_card.dart` + `swap_screen.dart`** — zdjęte **poziome** insety 16px z karty Pricing,
  komunikatu błędu trasy i **obu gałęzi** CTA. Karty kwot nie mają zewnętrznego marginesu (kolumna
  nakłada rynnę raz), więc te trzy siedziały na innej krawędzi. Pionowe odstępy nietknięte.
  Obie gałęzie CTA miały inset osobno — przycisk **przeskakiwałby w bok** przy zmianie szczebla drabinki.

### Szuflady
- **`slippage_state.dart`** (NOWY) — czysta reguła obok `swap_cta_state.dart`. `0 < x ≤ 50`,
  ostrzeżenie >5% i <0.05%. Trzy rozstrzygnięcia: ostrzeżenie **przepuszcza** wartość, puste pole
  **nie jest błędem**, każdy preset musi przechodzić własną walidację (jest na to test).
- **`swap_settings_drawer.dart`** — przepisany na **063-A**: presety `0.1/0.5/1%` jako główna droga,
  pole jako wyjście awaryjne, komunikat pod polem, opis co ta liczba znaczy.
  `Apply` **w stopce shella**, nie w ciele. Przeszkoda była realna: stopka jest rodzeństwem ciała,
  więc nie widzi jego stanu — i dlatego stary `Apply` był zawsze aktywny mimo błędnej wartości.
  Rozwiązane jednym `ValueNotifier` czytanym przez obie połowy.
- **`token_selector_drawer.dart`** — przepisany na **032-A1**. Cztery usterki: brak paddingu;
  wiersze malowały `surfaceMenu` na panelu o tle `surfaceMenu` (**karta, której nie da się zobaczyć**);
  zero stanu zaznaczenia; oraz `ListView → Column → ListView.builder(shrinkWrap, physics: never)` —
  trzy warstwy przewijania na jedną listę. Doszedł pusty stan wyszukiwania.
- **`responsive_drawer.dart`** — ⚠ **zasięg: wszystkie ~19 szuflad.** `titleSpacing` 16 → 20
  (domyślna wartość Materiala kontra `space10` każdego ciała — tytuł stał 4px do środka względem
  własnej treści), tytuł 16px/w500 → **18px/w600** (tyle specyfikował 030-B1; shell nigdy nie został
  przemierzony z powrotem do szkicu), toolbar 48 → 56.
- **`squid_balance.dart`** — nowy `displayBalance`. `formattedBalance` renderuje pełną precyzję tokenu,
  więc 0.01 DAI docierało do listy jako `0.010000000000000221`. **Getter celowo nietknięty** — MAX
  wstawia go prosto w pole kwoty, więc zaokrąglenie zostawiłoby pył albo poprosiło o za dużo.

### Testy (nowe)
- `test/utils/decimal_text_input_formatter_test.dart` — 16 przypadków. Złapał realny błąd: przy tokenie
  o zerowej precyzji pole przyjmowało `1.` — separator, po którym nic już nie wchodzi. Poprawione w źródle.
- `test/squid_router/slippage_state_test.dart` — 13 przypadków, w tym dwa pinujące dokładnie te wartości,
  które stary drawer przyjmował: `0` i `900`.

---

## 3. Szkice

- **`062-ledger-variants`** — 5 wariantów rozbudowy strony Swap, każda dana z metryką
  `HAVE / EASY / BUILD` + sekcja **„Backend — czego nie ma"** (7 pozycji z plikiem i linią,
  podświetlanych per wariant). **Status: bez picku — Jakub wybrał zostawienie obecnego Swapa.**
  Wartość szkicu leży dziś w audycie danych, nie w layoucie.
- **`063-settings-drawer-archetype`** — **wybrany wariant A, wdrożony.** Szósty archetyp szuflady
  (formularz), którego brakowało obok shella/paragonu/listy/potwierdzenia/QR.

Oba mają uruchamialne checki lecące w konsoli przy załadowaniu.

**Renderowanie szkiców działa** — Chrome for Testing siedzi w
`~/Library/Caches/ms-playwright/chromium_headless_shell-1228/`. Poprzednia sesja zgłosiła brak Chrome,
bo szukała tylko `/Applications/Google Chrome.app`.

---

## 4. Znaleziska w kodzie (fakty, nie opinie)

| Ustalenie | Dowód |
|---|---|
| **Swap nigdy się nie wykonuje** | `swap_screen.dart:227` → `// TODO: invoke Squid API`. Transakcja jest zapisywana do Hive i cubita dla swapa, który się nie odbył |
| **Pole opłat trzyma kwotę swapa** — BŁĄD | `swap_screen.dart:243` → `fees: fromAmount`; `transaction_displays.dart:474` renderuje to jako **„Network Fee"**. Drawer szczegółów swapa **już dziś pokazuje błędną liczbę**. Todo założone |
| Status zawsze `completed` | `swap_screen.dart:246` — trzystanowe badge'y nie mają producenta |
| Historia swapów **jest realna** | `swap_screen.dart:277` + `:280`; `TransactionsCubit` już czytany w tym pliku (`:232`) |
| Gotowe do ponownego użycia | `TransactionRow`, `showTransactionDetails`, `TransactionBadge` — listy swapów nie trzeba pisać od zera |
| „View all" ma **istniejący** cel | `/transactions` + `Filters.swap` (`transactions_slim_view.dart:92`); brakuje tylko `initialFilter` — `selectedFilter` to prywatny stan na `Filters.all` (`:181`). ~20 linii, addytywnie |
| Salda i trasa to mocki | `squid_token_service.dart:36,59`; `mockSquidRoute.route` to **pusta tablica** |

---

## 5. Czego ta sesja NIE zrobiła

- **Zero commitów** i zero PR-ów (`CLAUDE.md` + autoryzacja).
- **Faza 20 nie wykonana.** Jakub wybrał „ja wykonuję, bez commitów", ale sesja skręciła na szuflady
  i do egzekucji nie doszła. Plan `20-01-PLAN.md` jest gotowy, faza ma status `planned`.
  Plan jest TDD: Task 1 pisze test, który ma **paść**, Task 2 robi layout, Task 3 domyka.
- **Żadna zmiana wizualna nie była oglądana przeze mnie** — tylko hot reload i testy.
  Jakub przechodził Swap na żywo; **szuflady po ostatnim reloadzie (23:52) nie były jeszcze przez
  nikogo obejrzane**, w szczególności zmiana shella na pozostałych ~17 szufladach.
- Light mode nietknięty (zasada „dark first").
- `.planning/ROADMAP.md` zmieniony **nie przeze mnie** — wiersze o fazach 19/20/21 dopisała
  równoległa sesja.

---

## 6. Stan procesów

Aplikacja **DZIAŁA** od 07:23, przeładowywana przez `SIGUSR1` (potwierdzone w źródle SDK:
`resident_runner.dart:1748`, `sigusr1` = hot reload, `sigusr2` = restart).

```
PID 42347  flutter run -d macos --dart-define=GW_DEV_TOOLS=true
PID 43362  Genius Wallet.app
```

**Nie używać `R` ani `SIGUSR2`** — restart wywala apkę na blokadzie RocksDB natywnego node'a.
Hot reload: `kill -USR1 42347`. Dowód, że zadziałał: świeży `app.dill.incremental.dill` w
`/var/folders/.../flutter_tools.d6tXkT/flutter_tool.7CfYd0/`.

---

## 7. Następne kroki

1. **Rozstrzygnąć kolizję z fazą 21** (sekcja 1) — zanim ktokolwiek odpali 21-01 lub 21-06.
2. **Obejrzeć szuflady na żywo**, zwłaszcza pozostałe ~17 po zmianie shella (Select Network,
   Account, potwierdzenia dApp) — czy 18px tytułu i toolbar 56 nic nie rozjeżdżają.
3. **Faza 20** — gotowa do egzekucji, bez commitów.
4. **Błąd `fees: fromAmount`** — niezależny od wszystkiego, todo założone.
5. Rozważyć przejrzenie innych pól deklarujących się jako bezramkowe — `focusedBorder` z motywu
   bije lokalne `border: InputBorder.none` wszędzie, nie tylko na Swapie.

---

# UZUPEŁNIENIE — druga połowa sesji (2026-07-27, do 09:0x)

Powyższe kończy się na szufladach. Potem sesja zrobiła jeszcze trzy rzeczy.

## A. Gradientowy ring focusa — `lib/components/inputs/gw_focus_ring.dart` (NOWY)

Powód techniczny: **`BorderSide` przyjmuje jeden `Color`, więc żaden `InputBorder` nie może być
gradientem.** Ring to zewnętrzny box z gradientem + wewnętrzny z wypełnieniem, wykrywający focus
swoich **potomków** (`Focus(canRequestFocus: false, skipTraversal: true)`), więc miejsca wywołania
nie muszą trzymać `FocusNode`.

Geometria jest **stała w obu stanach** — 1.5px jest zarezerwowane także gdy ring nie świeci.
Podpięty w czterech miejscach: karta kwoty na Swapie (przezroczysty w spoczynku, zapala się
poświatą), pole slippage, wyszukiwarka tokenów, pole Message na Feedbacku.

## B. FAZA 20 WYKONANA (bez commitów)

Wszystkie trzy zadania planu `20-01`, testy zielone. Skrót:
ramka `xxl`→`large`, tytuł wraca na lewą krawędź (cofa nieskomitowane `centered: true` porannej
sesji), dwukolumnowy `LayoutBuilder`, nowa szyna `_buildRail`, pasek chipów skasowany,
stopka stanu Failed rozdzielona.

**`20-01-SUMMARY.md` NIE POWSTAŁ** — dlatego GSD nadal raportuje fazę jako `planned`.
To jest pierwsza rzecz do zrobienia.

## C. Szkic 064 + kontrolki Feedbacku

Jakub wybrał **wariant B — gradientowe podkreślenie** i powiedział, że *to powinno być standardem*.
Segment typu (Bug/Idea/Question) niesie teraz **dokładnie** język zakładek nawigacji: 3px pasek
`brandCta`, zaokrąglony u góry, poświata `brandPrimaryStrong` @50% blur 10, 200 ms, plus
`GWDecorations.hover` na nieaktywnych. Gradient nie wchodzi na tekst — to reguła navbara.

Cztery poprawki po walku Jakuba, każda z przyczyną wartą zapamiętania:

| Objaw | Przyczyna |
|---|---|
| Hover „dużo rusza" | `BoxDecoration` z borderem **wcina swoje dziecko**; animacja z „bez ramki" na „1px ramki" przesuwa etykietę o piksel |
| Etykiety niewycentrowane | `Stack` daje niepozycjonowanym dzieciom **luźne** ograniczenia → `Text` się kurczy → `textAlign: center` nie ma czego centrować |
| Za mały odstęp | Tor stracił pudełko, więc `space12` przestało wystarczać → `space16` |
| Placeholder jak wpisany tekst | Przy przepisywaniu pola **zgubiłem `hintStyle`** → dziedziczył jasność treści. Teraz `textPrimary38` + kursywa |

Dodatkowo: etykieta „Message" **nad** polem (standard `GWTextField`, 7 plików) i tytuł szyny
`What gets sent` → **`Attached automatically`**.

## D. Audyt zaznaczeń — jedno ustalenie warte uwagi

**`GWDecorations.hover()` jest dziś użyty w DWÓCH miejscach app-wide** (zakładki nawigacji + ten
segment). „Jeden przepis dla całej aplikacji" ze szkicu 044 **nigdy się nie rozjechał**.

Kandydaci tego samego typu: chipy filtrów transakcji, zakładki zakresu czasu w Markets, pasek
zakładek przeglądarki. ⚠️ **Nie obejmować list** — `032-A1` rozstrzygnął zaznaczenie wiersza inaczej
(gradientowy tint + check, bez paska), a `network_dropdown`/`account_dropdown` są zaklepane przez `21-02`.

## Bramka na koniec

```
flutter analyze lib   59   (baseline ≤61)
flutter test          323 pass / 1 fail   (zaślepka z baseline'u)
test/logs/            4/4
```
