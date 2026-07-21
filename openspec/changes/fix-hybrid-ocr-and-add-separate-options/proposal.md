# Change Proposal: Implement Proper Hybrid and Separate OCR Language Options

## Why
Previously, we mapped "Russian" to `rus+eng` hybrid mode. However, Tesseract's `rus+eng` mode prioritizes Russian character sets for ambiguous lookalike letters (homoglyphs), causing English words (like `open`) to be recognized using Cyrillic characters (like `ореп`). Furthermore, users who wanted to perform pure English OCR without Cyrillic characters or pure Russian OCR had no way to separate them.

## What
Refactor the language selection system to offer:
1. **English** (`eng` -> `EN` label): pure English OCR.
2. **Russian** (`rus` -> `RU` label): pure Russian OCR.
3. **Russian + English** (`eng+rus` -> `RU+` label): hybrid OCR prioritizing Latin characters for homoglyphs.

Update both the Main Window popover and the System Tray menu to expose these three options.

## Impact
- Clean, Cyrillic-free English OCR when "English" is chosen.
- Clean Russian OCR when "Russian" is chosen.
- Seamless dual-language OCR prioritizing correct English spelling when "Russian + English" is chosen.
