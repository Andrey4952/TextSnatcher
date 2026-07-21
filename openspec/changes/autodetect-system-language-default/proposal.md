# Change Proposal: Auto-detect System Language Default for OCR

## Why
When no config file exists, TextSnatcher defaults `preferred_language` to `"eng"`. On Russian OS installations, users taking screenshots immediately after launching the app run Tesseract with `-l eng`, transforming Russian text into Latin gibberish (e.g. `Привет` -> `Tlpubem`).

## What
Update `load_config()` in `LanguageButton.vala` to check `Environment.get_language_names()`. If the user's system locale is Russian (`ru`), default `preferred_language` to `rus` (`RU`) out-of-the-box.

## Impact
- Out-of-the-box Russian OCR support on first launch for Russian system locales.
- Eliminates accidental Latin gibberish output caused by default `eng` fallback.
