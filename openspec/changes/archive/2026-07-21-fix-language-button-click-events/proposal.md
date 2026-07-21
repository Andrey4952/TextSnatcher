# Change Proposal: Fix Language Selection Menu Click Events

## Why
Items in the language menu were created using `Gtk.ModelButton`. In GTK3 `Gtk.Popover` menus, `Gtk.ModelButton` does not emit the `.clicked` signal when clicked. Consequently, selecting "Russian" from the menu failed to update `preferred_language`, leaving it stuck on `"eng"`. Tesseract then attempted to parse Russian text using the English language model, producing Latin gibberish output (e.g. `Привет` -> `Tlpubem`).

## What
Refactor `LanguageButton.vala` to use standard flat `Gtk.Button` widgets for language list items with explicit `.clicked` signal connections.

## Impact
- Selecting Russian (or any other language) from the headerbar menu immediately updates the active OCR language.
