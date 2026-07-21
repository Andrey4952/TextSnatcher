# Change Proposal: Enable Hybrid Russian-English OCR

## Why
Passing a single language parameter (such as `-l rus` alone or `-l eng` alone) forces Tesseract to evaluate all image text through a single language model. When an English image is scanned with `-l rus`, English words are mangled into Cyrillic gibberish. Conversely, when a Russian image is scanned with `-l eng`, Russian words are mangled into Latin gibberish.

## What
Update `LanguageButton.vala` so that Russian language selection (and Russian system locale default) maps to `rus+eng`, enabling Tesseract to load both dictionaries and recognize Russian, English, and mixed text seamlessly.

## Impact
- Accurate OCR for pure English, pure Russian, and mixed Russian/English text on any screenshot.
