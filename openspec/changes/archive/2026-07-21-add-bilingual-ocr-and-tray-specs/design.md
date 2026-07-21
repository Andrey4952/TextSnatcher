# Design: OpenSpec Specifications for Bilingual OCR, System Tray, and Wayland Screenshot Engine

## Architecture Overview

```
┌────────────────────────────────────────────────────────────────────────┐
│                        TEXTSNATCHER SPECIFICATIONS                      │
├────────────────────────────────────────────────────────────────────────┤
│                                                                        │
│  ┌───────────────────────┐  ┌─────────────────────┐  ┌──────────────┐  │
│  │   OCR Delta Spec      │  │   Tray Delta Spec   │  │ Screenshot   │  │
│  │   (specs/ocr/spec.md) │  │(specs/tray/spec.md) │  │  Delta Spec  │  │
│  └───────────┬───────────┘  └──────────┬──────────┘  └──────┬───────┘  │
│              │                         │                    │          │
│              ▼                         ▼                    ▼          │
│        Hybrid rus+eng             CosmicTray &          grim+slurp,    │
│        (RU+) Language             Hide-on-Close         wl-copy &      │
│        Selection                  System Tray           Portal Fallback│
│                                                                        │
└────────────────────────────────────────────────────────────────────────┘
```

## Specifications

1. **OCR Spec (`specs/ocr/spec.md`)**: Formalizes `RU+` (`rus+eng`) option in `LanguageButton.vala` and Tesseract language string generation.
2. **Tray Spec (`specs/tray/spec.md`)**: Formalizes `CosmicTray.vala` / `TrayIcon.vala` indicator lifecycle and `delete_event` `hide_on_delete()` in `MainWindow.vala`.
3. **Screenshot Spec (`specs/screenshot/spec.md`)**: Formalizes `grim` + `slurp` execution with 200ms delay in `TesseractTrigger.vala`, `wl-copy` clipboard integration, and `Xdp.Portal` fallback.
