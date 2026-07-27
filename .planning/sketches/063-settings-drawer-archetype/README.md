---
sketch: 063
name: settings-drawer-archetype
question: "Jak czyta się szuflada, która jest FORMULARZEM — brakujący szósty archetyp obok shella, paragonu, listy, potwierdzenia i odbioru?"
winner: null
tags: [drawers, settings, form, slippage, archetype, follows-030, follows-041]
depends_on: [030, 041]
---

# Sketch 063: Szuflada-formularz — brakujący archetyp

## Czego ten szkic NIE robi

**Nie projektuje shella od nowa.** `030-drawer-shell` rozstrzygnął go 2026-07-23 wariantem
**B1 „Quiet band"**, a `drawers-final/` skonsolidował pięć decyzji. Wszystkie warianty tutaj
siedzą w tym samym, zatwierdzonym shellu: panel 420px, tytuł 18px do lewej, krzyżyk prawy górny,
delikatny **gradientowy** hairline, 20px paddingu ciała, stopka z górną krawędzią, CTA jako
wypełniony gradient.

Zmienia się wyłącznie **treść ciała**.

## Design Question

Pięć archetypów pokryło swoje szuflady:

| Archetyp | Decyzja | Kogo obsługuje |
|---|---|---|
| Shell | 030 B1 | wszystkie ~19 |
| Paragon | 031 B1 | `swap_success`, `swap_fail`, `buy_success`, `buy_cancelled`, `swap_result` |
| Lista | 032 A1 | `token_selector`, `network_dropdown`, `account_dropdown`, picker mostu |
| Potwierdzenie | 033 B1 | `approve_transaction`, `approve_dapp_connection` |
| Odbiór QR | 034 A2 | receive |
| **Formularz** | **BRAK** | **`swap_settings` (1 pole) · `sdk_account_manager` (7) · `token_info` (2)** |

Dlatego `SwapSettingsDrawer` wygląda jak wygląda — nie miał czego przyjąć. To nie jest wada tej
jednej szuflady, tylko luka w systemie.

## How to View

```
open .planning/sketches/063-settings-drawer-archetype/index.html
```

Przełącznik **Skala** w pasku: `1 ustawienie · Swap` ↔ `7 ustawień · SDK Account`.
To jest główne narzędzie oceny — archetyp musi unieść oba, a każdy wariant łamie się przy innym.

## Warianty

- **A · Presety + własna wartość ★** — trzy presety jako główna droga, pole jako wyjście awaryjne, walidacja pod polem.
- **B · Hero ze stepperem** — wartość jako duża liczba z −/+, rodzinne podobieństwo do pola kwoty na karcie swapa.
- **C · Wiersze** — każde ustawienie to wiersz z aktualną wartością; edytor rozwija się w miejscu.
- **D · Sekcje** — grupy z nagłówkami, kontrolki od razu widoczne.
- **E · Bez Apply** — treść jak w A, ale stopka znika: zapis natychmiastowy.
- **0 · Dziś** — stan referencyjny prosto z aplikacji.

## Co zobaczyć

1. **Przełącz na `7 ustawień`, zanim wybierzesz.** Przy jednym polu wszystkie wyglądają znośnie.
   B rozpada się najwyraźniej: jedno ustawienie dostaje 200px i koronę, sześć pozostałych ściska się pod spodem.
2. **W C kliknij „Slippage tolerance"** — edytor rozwija się w miejscu, wiersz nie znika.
3. **Wpisz `0`, potem `900`** w polu własnej wartości. Dziś realny drawer przyjmuje oba.
4. Porównaj z zakładką **0 · Dziś** — ta sama szuflada, ten sam shell, inna treść.

## Rekomendacja

**★ A · Presety + własna wartość.** Zamienia pytanie „jaką liczbę mam wpisać?" w wybór, a pustkę
wypełnia treścią, która coś znaczy: nazwą, wyjaśnieniem, presetami, walidacją. Skaluje się bez
zmiany kształtu — przy siedmiu ustawieniach pierwsze zostaje rozwinięte, bo jest bohaterem tej
szuflady, a reszta schodzi do wierszy wariantu C. To czyni A i C **jednym systemem, nie rywalami**.

**Wicelider: C · Wiersze.** Jedyny wariant wyglądający identycznie przy 1 i przy 7, i jedyny,
w którym widać wszystkie aktualne wartości bez wchodzenia w cokolwiek. Przy jednym ustawieniu
wymaga domyślnego rozwinięcia, inaczej pojedynczy wiersz w pustej szufladzie wygląda na pomyłkę.

**Odrzucony: B · Hero.** Najładniejszy przy jednym polu i to jest cała jego teza. Nadaje jednemu
ustawieniu hierarchię, której nikt nie zamawiał, i nie ma odpowiedzi na `sdk_account_manager`.

**E · Bez Apply** nie jest odrzucony — jest **pytaniem do Ciebie**. Slippage to preferencja, nie
transakcja; nic tu nie trzeba zatwierdzać. Ale stopka jest częścią zatwierdzonego shella (030 B1),
więc jej usunięcie to decyzja systemowa, nie kosmetyka jednej szuflady. Pokazany, żeby wybór był
świadomy, a nie odziedziczony.

## Logika, która pójdzie do Darta

`slipState()` — przeniesiona ze szkicu 041, czysta, z uruchamialnym checkiem
(11 przypadków, 4 poziomy, leci w konsoli przy każdym załadowaniu).

Granice: `0 < x ≤ 50`, ostrzeżenie powyżej `5%` (front-running) i poniżej `0.05%` (swap się nie wypełni),
przecinek traktowany jak kropka.

Realny `swap_settings_drawer.dart:32-53` ma dziś **tylko** `double.tryParse` bez jakiegokolwiek zakresu:
przyjmuje `0` (przy którym każdy swap padnie) i `900` (przy którym użytkownik akceptuje dowolną cenę).
Todo: `.planning/todos/pending/2026-07-26-swap-slippage-has-no-range-validation.md`.

## Port

Wybrany wariant należy dołożyć do `drawers-final/` jako szósty archetyp, a jego kontrolki
(preset chip, pole z walidacją, wiersz ustawienia, przełącznik) do tego samego zestawu prymitywów
treści, który `drawers-final/README.md` wskazuje jako cel portu — żeby `sdk_account_manager`
i `token_info` dostały to samo bez drugiego projektowania.

## Zweryfikowane

- Wyrenderowane w Chrome for Testing, wszystkie 6 zakładek, obie skale.
- `slipState()` — 11 przypadków przechodzi.
- Znaczniki zbilansowane, JS parsuje się.
- Shell odwzorowany z `030-drawer-shell/README.md` (B1) i `drawers-final/README.md`, nie z pamięci.
- **Nie sprawdzone:** light mode, widok mobilny (shell schodzi wtedy do bottom sheetu — ten szkic pokazuje tylko panel desktopowy).
