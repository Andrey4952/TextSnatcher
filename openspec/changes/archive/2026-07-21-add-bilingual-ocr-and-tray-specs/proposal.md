# Change Proposal: Add OpenSpec Specifications for Bilingual OCR, System Tray, and Wayland Screenshot Engine

## Why
TextSnatcher has been upgraded with critical capabilities including dual Russian + English OCR, a native System Tray indicator with close-to-tray mechanics, and a Wayland screenshot/clipboard engine. 

Adding formal OpenSpec delta specs ensures these capabilities are fully documented, testable, and synchronized into main specification modules.

## What
1. **OCR Delta Spec (`specs/ocr/spec.md`):** Define requirements for hybrid `rus+eng` (`RU+`) language recognition.
2. **Tray Delta Spec (`specs/tray/spec.md`):** Define requirements for system tray indicator registration, background screenshot execution, and hide-on-close mechanics.
3. **Screenshot Delta Spec (`specs/screenshot/spec.md`):** Define requirements for Wayland `grim`+`slurp` area selection, non-blocking Wayland seat grab resolution, and `wl-copy` clipboard integration when hidden.

## Impact
Maintains specification parity for all newly introduced TextSnatcher capabilities.
