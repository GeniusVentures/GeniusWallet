# The Receive drawer breaks when the selected network has no name or no icon

**Found:** 2026-07-27, while auditing `crypto_address_qr.dart` for sketch 159.
**Type:** two small defects on the same edge case. Both user-visible when they fire.
**Independent of:** the sketch 159 layout pick. Fixable on their own.

## Defect 1 - broken sentence on a blank network name

The caller (`lib/components/coins/view/coins_screen.dart:175-177`) passes:

```dart
network: state.selectedNetwork?.name ?? state.selectedNetwork?.symbol ?? '',
```

and the widget builds the warning as (`crypto_address_qr.dart:182`):

```dart
"Only send ${widget.network}-network assets to this address."
```

With an empty network the user reads:

> Only send **-network** assets to this address.

The same empty string also renders as an invisible chip label at `:88`, so the row above the QR becomes a
lone avatar with nothing beside it.

**Fix:** the warning is the one line on this panel standing between a user and a permanent loss of funds, so
it should not degrade to nonsense. Either suppress the network-specific wording when the name is empty
(`"Only send assets on the selected network to this address."`) or refuse to open the drawer without a
network - the caller already guards on a null address two lines earlier and can guard on this too.

## Defect 2 - `AssetImage("")` for the QR's centre image

`crypto_address_qr.dart:109`:

```dart
embeddedImage: AssetImage(widget.iconPath ?? ""),
embeddedImageStyle: const QrEmbeddedImageStyle(size: Size(36, 36)),
```

An `AssetImage` is constructed with an **empty asset path** whenever the network has no icon, and
`embeddedImageEmitsError` is not set. The guard at `:78` (`if (widget.iconPath != null)`) protects the chip's
avatar but not this.

**Fix:** pass `embeddedImage` only when `iconPath != null`:

```dart
embeddedImage: widget.iconPath != null ? AssetImage(widget.iconPath!) : null,
embeddedImageStyle: widget.iconPath != null
    ? const QrEmbeddedImageStyle(size: Size(36, 36))
    : null,
```

## Worth knowing while in this file

Two things here are **correct and deliberate** - do not "tidy" them:

- The QR keeps `backgroundColor: Colors.white` in **both** appearances so a phone camera can read the
  default-black modules over the dark drawer (`:106-108`).
- The amber uses a darkened light-mode value `#92400E` (7.1:1 on white) rather than
  `GeniusWalletColors.statusWarning`, which is a fill-only token measuring ~1.6:1 as text on white
  (`:67-69`).

## Related

- `.planning/sketches/159-receive-drawer/README.md` - findings 3 and 4, plus the two drifts from 034-A2
  (the chunked address and the missing body padding), which are design picks rather than defects
