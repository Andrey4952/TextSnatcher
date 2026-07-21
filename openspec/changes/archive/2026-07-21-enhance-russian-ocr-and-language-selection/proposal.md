# Change Proposal: Enhance Russian OCR and Language Selection UI

## Why
1. Screenshots containing Russian text frequently contain mixed English UI elements, code, or technical terms. Passing `-l rus` alone causes Tesseract to mangle English characters into invalid Cyrillic symbols.
2. `LanguageButton` currently gives no visual feedback on the headerbar about which language is currently active, and the selected language is lost when the app closes.

## What
1. Update `LanguageButton.vala` so that selecting Russian sets `preferred_language` to `rus+eng`, enabling dual-dictionary recognition for mixed Russian/English text.
2. Update `LanguageButton` headerbar button UI to display the active language indicator (e.g. `EN`, `RU`, `DE`, `FR`).
3. Add config persistence to save and restore the user's preferred language across application restarts.

## Impact
- Superior OCR accuracy for Russian and mixed Russian/English text.
- Clear visual language indicator in the application header bar.
- Automatic persistence of language preferences across sessions.
