---
slug: splash-bottom-safe-area
status: complete
date: 2026-08-06
files_changed:
  - lib/screens/splash.dart
committed: false
---

# SUMMARY — splash-bottom-safe-area

## Co zrobiono

Zawinięto dolną `Column` ekranu startowego w `SafeArea(top: false)` z podłogą
`minimum: EdgeInsets.only(bottom: GeniusWalletConsts.space6)`.

Diff to jeden zawinięty widget - `dart format` przeliczył wcięcia poddrzewa, więc zmiana wygląda
w gicie na większą niż jest.

## Przyczyna, dla zapisu

`lib/screens/splash.dart` nie zawierał **żadnego** `SafeArea` ani odczytu `MediaQuery`. Ostatnim
dzieckiem dolnej `Column` jest 2-pikselowy pasek postępu, a `Align(bottomCenter)` przyklejał go
do fizycznej krawędzi ekranu - pod home indicator i w zaokrąglenie rogu.

## Dlaczego `minimum`, a nie samo `SafeArea`

`SafeArea` sam w sobie daje 0 na urządzeniu bez gestowego uchwytu, więc pasek znów siadałby na
krawędzi. `minimum` jest podłogą (wynik = większa z dwóch wartości), więc iPhone dostaje swoje
~34 px, a urządzenie bez uchwytu 12 px z siatki 4-pt. Bez tego naprawilibyśmy jeden model telefonu
i zostawili resztę.

## Weryfikacja

- `dart format lib/screens/splash.dart` — 1 file changed.
- `flutter analyze` — **No issues found! (ran in 27.0s)**, uruchomione po zmianie.
- Wizualna na Sidney: pełny relaunch (splash nie wraca przy hot reload) — **w toku**.

## Odchylenie od notatek projektu

Pamięć projektu podawała baseline `flutter analyze` jako "409 issues, 0 errors" (2026-07-20).
Faktyczny stan na 2026-08-06 to **0 issues**. Notatkę trzeba poprawić, żeby kolejna sesja nie
uznała czystego wyniku za anomalię.

## Nie commitowano

`AGENTS.md` mówi "Do not create commits", a zasada Jakuba gatuje commity tak samo jak PR-y.
Zmiana leży w drzewie roboczym.
