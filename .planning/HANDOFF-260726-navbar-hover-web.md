# HANDOFF — 2026-07-26 · navbar, hover, dashboard, web

**Sesja:** Jakub + Claude, noc/rano 2026-07-26. Gałąź `redesign/jakub-260725b`
(= `origin/ui-redesign-port` @ `414fa94b` + zmiany poniżej).
**Stan:** **NIC NIE JEST ZACOMMITOWANE** — zgodnie z `CLAUDE.md`. Wszystko leży w drzewie roboczym.
**Baseline utrzymany przez całą sesję:** `flutter analyze lib` = **59**. Testy dotkniętych plików przechodzą.

> ⚠ **Czytaj sekcję „Nakładanie się z równoległą sesją" ZANIM cokolwiek zacommitujesz.**
> W `lib/` leżą zmiany z co najmniej dwóch źródeł. `git add -A` sklei je w jeden commit.

---

## 1. Co weszło (uncommitted)

### Web tab — bug naprawiony u źródła
`lib/web/web_view_mobile.dart` · `test/web/url_bar_focus_remount_test.dart` (nowy, 2/2)

Pasek URL przyjmował focus, ale **nie dało się w nim nic napisać** — każdy klawisz wracał
nieobsłużony i macOS piszczał. Trzy wcześniejsze podejścia szukały winy w tekście/selekcji.
**Prawdziwa przyczyna: kształt drzewa.** `Container` wstawia `DecoratedBox` tylko gdy
`decoration != null`, więc `decoration: editing ? ... : null` zmieniało kształt drzewa na focusie,
Flutter kasował poddrzewo i niszczył świeżo zafokusowany `EditableText` klatkę po tym, jak
`_handleFocusChanged` zużył jedyny keyboard token węzła. Zostawało zafokusowane pole **bez
połączenia text-input** — a na macOS przez to połączenie idzie CAŁA edycja, ze strzałkami włącznie.

**Diagnostyka, która to rozstrzygnęła:** sonda `HardwareKeyboard` pokazała, że klawisze docierają
do Fluttera, `primaryFocus` jest prawidłowy, `onChanged` nie odpala się nigdy, a **strzałki nie
ruszają kursorem**. Strzałki nie mają nic wspólnego z podmianą selekcji — to zabiło poprzednią teorię.
**Reguła:** jeśli strzałki nie ruszają kursorem, połączenie jest martwe. Nie szukaj w IME.

Todo przeniesione do `todos/completed/` z poprawioną diagnozą. Pamięć projektu zaktualizowana.

### Web tab — strona startowa
`lib/web/web_chrome_helpers.dart` · `web_view_screen.dart` · `web_view_mobile.dart`

`https://www.duckduckgo.com` → **`https://gnus.ai/`**. Literał był wpisany w **czterech miejscach
w dwóch plikach**; zastąpiony jedną stałą `kWebHomeUrl`. Dwa nieaktualne komentarze poprawione.
Już otwarte karty nie zmienią adresu — trzymają własne kontrolery.

### Dashboard — szerokości i sparkline
`lib/dashboard/home/view/dashboard_screen.dart` · `lib/chart/crypto_simple_chart.dart` · sketch **038**

- `flex: 3 → 2` (linia ~165) i `maxWidth: 600 → 760`: przy 1920 px Transactions **476 → 634 px**
  (+158), cztery panele po lewej oddają po 63-95 px. Odblokowuje kolumny Status+Fee ze sketcha 029.
- Sparkline w sekcji Markets **56×20 → 72×32**, `barWidth` 2 → 1.6 — wartości z zakładki Markets.

**Dwie rzeczy ZAMKNIĘTE, nie proponować ich ponownie:**
1. `OverviewDashboardView` (wallet + processing) **zostaje top-left przy każdej szerokości**.
   Ta sesja raz go przestawiła, źle odczytawszy potwierdzenie stanu jako prośbę o zmianę. Cofnięte.
2. **Wariant A2** (zamiana dolnego rzędu na `Markets | Chart`, wyrównanie szwów na 40%) został
   zbudowany, obejrzany na żywo i **ODRZUCONY** — „nie jest lepszy". Zygzak 40/60 / 60/40 jest
   świadomym, obejrzanym kompromisem.

### Standard toru kontrolek
`.planning/codebase/CONVENTIONS.md` → sekcja **Control track**

`surfaceSunken` + hairline `borderSubtle` + `radiusPill` + `padding: all(3)` + 2 px między chipami.
Trzy zastosowania: segment timeframe, pasek filtrów transakcji, klaster navbara.
Segment i pasek filtrów są **celowo identyczne geometrycznie** i zmieniają się razem.

### Navbar — prawy klaster
`lib/components/overlay/responsive_overlay.dart` · `lib/theme/nav_chip_style.dart` ·
`lib/reown/reown_connect_button.dart` · sketche **039**, **045-navbar-cluster-heights**, **042**, **043**

- **Buy GNUS zdjęty z paska.** Trasa `/buy` żyje — zniknął skrót, nie funkcja.
- **Jeden tor, cztery pola** rozdzielone hairline'ami: sieć │ SDK │ portfel │ stan.
- **Wysokości wyrównane:** chip 36 → tor 44 = malowana powierzchnia hovera taba (`:343`).
  Zweryfikowane: wszystkie cztery kontrolki idą przez `navContextChipStyle`, żadna nie używa
  bazowego `navChipShell` (40 px).
- **Connect (sketch 043 wariant 4A):** bez tła i bez ramki, jak sąsiednie chipy. Stan niesie kropka
  i kolor etykiety. **Stan „Rozłączony" — i tylko on — maluje się gradientem marki**, bo jako jedyny
  jest zaproszeniem, a nie statusem. Spinner został wyłącznie przy „Connecting".
- **Dług zamknięty:** `accounts.isEmpty` wyciągnięte do `_buildActionRowWidgets`, więc chip SDK
  **i jego przegroda znikają razem**.

### Hover — jedna receptura w całej aplikacji
`lib/theme/genius_wallet_decorations.dart` (`hoverFill` / `hoverEdge` / `hover()`) ·
`nav_chip_style.dart` · `responsive_overlay.dart` · `gw_card.dart` · sketch **044**

Były **trzy** różne hovery: tab unosił 1 px + cień, `GWCard` 2 px + `borderStrong` + cień `dialog`,
chipy nie robiły nic poza kolorem. Teraz jedna receptura: **tint marki 12 % + hairline marki 24 %,
zero geometrii**.

**Dlaczego bez geometrii** (to jest uzasadnienie, nie preferencja): `ButtonStyle` nie umie
transformacji, więc każda kontrolka oparta na przycisku wymagałaby wrappera; a chip unoszący się
z wnętrza wklęsłego toru zaprzecza sam sobie.

Oba tokeny są **fixed-brand**, nie appearance-aware — `genius_wallet_colors.dart:42` mówi wprost
„Brand + status colours are fixed". (W sketchu 044 napisano odwrotnie i wyceniono zbędną robotę
przy `GWColors` — poprawione tutaj.)

### Shader gradientowego tekstu wyniesiony
`lib/theme/genius_wallet_gradient.dart` → `brandCtaText(Color appearanceProxy)`

Wyniesiony z prywatnego `_activeLabelShader` w `transactions_slim_view.dart`, gdy pojawił się
**trzeci** konsument. Ciemny: stopnie `brandCta` = 9,4:1 i 6,8:1. Jasny: te same stopnie 1,65:1
i 2,28:1 → degradacja do `#0A6885` (5,61:1). `_activeLabelShader` został jako jednolinijkowy alias.

### Feedback i Swap — tytuły stron
`lib/logs/submit_logs_screen.dart` · `lib/squid_router/swap_screen.dart` — quick `260726-0z4`

Nagłówki wyprowadzone z wyśrodkowanej kolumny na lewą krawędź strony, jak Transactions/Markets/News.
Kolumna kart Swapa (560 px, sketch 105 A1 / D-07) zachowana przez konstrukcję.
**⚠ To jest miejsce nakładania się — patrz sekcja 3.**

---

## 2. Czeka na decyzję Jakuba

| # | Rzecz | Rekomendacja |
|---|---|---|
| 1 | Przejście po ekranach po ostatnim reloadzie (navbar, hover, Connect 4A) | — |
| 2 | Tint na kartach idzie przez `foregroundDecoration`, więc **kładzie się też na tekście**. Przy 12 % ledwo widoczne. | zerknąć na kartę Markets pod kursorem; jeśli tekst „brudzi", przenieść tint pod treść kosztem jednego widgetu |
| 3 | Wiersz w STATE dla quicka `260726-1j8` | dopisać po akceptacji navbara |
| 4 | `GWPageHeader.centered` — parametr bez konsumenta w `lib/` | **rekomendacja WYCOFANA** — ma własny test i pochodzi z równoległej sesji, patrz niżej |

---

## 3. ⚠ Nakładanie się z równoległą sesją

W drzewie pojawiały się katalogi i pliki, **których ta sesja nie tworzyła**, przeplecione czasowo
z moimi:

```
06:57  040-swap-page-header            ← nie ta sesja
06:58  gw_page_header_centered_test    ← nie ta sesja
07:08  045-navbar-cluster-heights      ← TA sesja
07:25  060-swap-companion-rail         ← nie ta sesja
07:30  043-connect-field-treatments    ← TA sesja
07:38  041-swap-page-buildout          ← nie ta sesja  ⚠ KOLIZJA NUMERU 041
08:00  061-coin-page-in-app-language   ← nie ta sesja
08:05  044-hover-unification           ← TA sesja
```

To obserwacja ze znaczników czasu, nie hipoteza o autorze. `CLAUDE.md` opisuje kolizję numerów
sketchy jako awarię powtarzalną — **numer 041 jest teraz użyty dwa razy**.

### Podział terytoriów (z treści sketchy)

| Sesja | Zakres |
|---|---|
| **Ta** | navbar (klaster, wysokości, Connect), system hovera, dashboard (szerokości, sparkline), Web tab, standard toru kontrolek |
| **Druga** | **strona Swap** (040 nagłówek, 041-swap-buildout „3 · Ledger", 060 companion rail), **strona coina** (061) |

Rozłączne — **z jednym wyjątkiem**.

### Jedyna realna kolizja: nagłówek strony Swap

Ta sesja w quicku `260726-0z4` **zmieniła `swap_screen.dart`**: wyprowadziła `GWPageHeader` z
wyśrodkowanej kolumny na lewą krawędź. Druga sesja zadaje **dokładnie to samo pytanie** w sketchu
**040** (bez wybranego zwycięzcy) i **buduje na nim dalej** w 041-swap-buildout (zwycięzca „3 ·
Ledger") oraz 060. Do tego dodała `GWPageHeader.centered` wraz z testem — parametr, którego żadne
wywołanie w `lib/` jeszcze nie używa, więc najpewniej jest przygotowaniem pod ich wariant.

**Wniosek: `swap_screen.dart` i `gw_page_header.dart` należą do drugiej sesji.** Ta sesja weszła
tam przypadkiem, realizując prośbę o wyrównanie tytułów w Feedbacku i Swapie.

**Do rozstrzygnięcia dziś wieczorem, zanim cokolwiek pójdzie do commita:**
1. Czy zmianę w `swap_screen.dart` z `0z4` zostawiamy, czy oddajemy pole sketchowi 040?
   Obie odpowiedzi są w porządku — nie w porządku jest zacommitowanie jej bez decyzji.
2. Przenumerować jeden z dwóch `041`. `CLAUDE.md` rezerwuje zakresy: egzekucja 000-099,
   lane A 100-149, lane B 150-199 — a obie sesje pisały w 000-099.
3. **NIE usuwać** `GWPageHeader.centered`, dopóki druga sesja nie powie, że go nie potrzebuje.

---

## 4. Jak wznowić

1. Apka chodzi pod `flutter run -d macos --dart-define=GW_DEV_TOOLS=true` (FIFO na stdin daje hot
   reload między turami). **`R` jest zabroniony** — zabija natywny node na locku RocksDB.
   Przy zmianie pola w klasie `const` (np. `GWPageHeader`) hot reload zostanie odrzucony i trzeba
   pełnego relaunchu.
2. Przed każdym uruchomieniem: zero instancji
   (`ps -axo pid,command | grep "Genius Wallet.app/Contents/MacOS/Genius Wallet"`).
3. Bramka: `flutter analyze lib` = **59**. Wyżej = regresja.
4. Testy-strażniki, które w tej sesji **celowo** zmieniły kontrakt (nie psuj ich z powrotem):
   `nav_chip_style_test.dart` (32 → 36 px, hover → tint marki),
   `gw_card_hover_test.dart` (uniesienie 2 px → brak, `borderStrong` → `hoverEdge`).

## 5. Fakty, których nie wyprowadzaj ponownie

- Powierzchnia hovera taba nawigacji: **44 px** (`responsive_overlay.dart:343`); slot 60 px
  (44 + 2×`space4`); pasek `appBarHeight` = **68**.
- `_buildActionRowWidgets` jest wołane **dwa razy** — desktop i AppBar mobilny. Jedna edycja,
  dwie powierzchnie.
- **Nigdy nie naprawiaj wysokości w `theme.dart`** — `textButtonTheme` (`:261-270`) rządzi każdym
  gołym `TextButton` w aplikacji.
- `surfaceMenu` `#171A21` na `surfaceElevated` `#0C0E14` to kontrast **1,11:1**. Kontrolkę widać
  dzięki **obramowaniu, nie wypełnieniu**.
- `GlobalSwapFabHost` zmienia kształt drzewa po pierwszej klatce, ale **jest bezpieczny**:
  go_router zawsze nadaje korzeniowemu Navigatorowi `GlobalKey` (`router.dart:263`), a element
  z `GlobalKey` jest przepinany, nie budowany od nowa. Sprawdzone testem
  `test/components/global_swap_fab_host_remount_test.dart`.
