---
slug: splash-bottom-safe-area
created: 2026-08-06
type: quick
area: ui
files:
  - lib/screens/splash.dart
---

# Splash: dolny pasek STATUS wchodzi pod home indicator

## Zgłoszenie

Jakub, 2026-08-06, ze zrzutu z iPhone'a Sidney: *"na Iphonie ten status bar jest troche odciety
wiec podnies go do gory troche prosze daj tam jakis padding od spodu"*.

## Przyczyna

`lib/screens/splash.dart` nie zawiera **żadnego** `SafeArea` ani odczytu `MediaQuery.viewPadding`.
Dolna zawartość to `Align(alignment: Alignment.bottomCenter)` z `Column`, którego ostatnim dzieckiem
jest 2-pikselowy pasek postępu (`SizedBox(height: 2)`, `:249`). `Align` przykleja go do fizycznej
krawędzi ekranu.

Na iPhonie z home indicatorem dolne ~34 px są zajęte przez systemowy uchwyt, a rogi są zaokrąglone -
więc pasek postępu jest częściowo zasłonięty i przycięty, a wiersz `STATUS` ma nad nim tylko
`space6` (12 px) własnego odstępu.

To nie jest problem kosmetyczny jednego ekranu: to brak obsługi bezpiecznego obszaru na ekranie,
który jako pierwszy pokazuje się użytkownikowi.

## Rozwiązanie

Zawinąć dolną `Column` w `SafeArea(top: false)` z podłogą `minimum`:

```dart
child: SafeArea(
  top: false,
  minimum: const EdgeInsets.only(bottom: GeniusWalletConsts.space6),
  child: Column(...),
),
```

**Dlaczego `SafeArea`, a nie ręczne dodanie liczby:** to rung 4 z `AGENTS.md` - natywna funkcja
platformy pokrywa problem. Ręczne `EdgeInsets.only(bottom: 34)` byłoby literałem zgadniętym pod
jeden model telefonu i rozjechałoby się na każdym innym.

**Dlaczego dodatkowo `minimum`, a nie sam `SafeArea`:** na urządzeniach bez gestowego uchwytu
(starsze iPhone'y, część Androidów) `viewPadding.bottom` wynosi 0 i sam `SafeArea` zostawiłby pasek
znów przyklejony do krawędzi. `minimum` działa jak podłoga - wynikowy odstęp to większa z dwóch
wartości, więc iPhone dostaje swoje ~34 px, a urządzenie bez uchwytu dostaje 12 px z siatki 4-pt.

`top: false`, bo górna krawędź ma zostać jak jest - logo jest wyśrodkowane w `Stack` i nic go nie tnie.

## Weryfikacja

1. `dart format` + `flutter analyze` - baseline z pamięci projektu: 409 issues, 0 errors.
2. Hot reload na Sidney i zrzut ekranu splasha - pasek postępu i wiersz STATUS mają odstąpić od
   dolnej krawędzi i nie mogą być zasłonięte przez home indicator.

## Poza zakresem

- Wygląd samego paska postępu i copy statusów (walk 13-03 to już ustalił).
- Bezpieczny obszar na pozostałych ekranach - jeśli problem jest szerszy, to osobne zadanie.
