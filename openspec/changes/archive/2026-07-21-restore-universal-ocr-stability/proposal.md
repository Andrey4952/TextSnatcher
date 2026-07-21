# Change Proposal: Restore Universal OCR Stability for English and Russian

## Why
Hardcoding `--psm 6` caused Tesseract layout analysis to fail on arbitrary multi-line screenshots, UI windows, and images with non-uniform text sizes. This resulted in empty 0-byte output files and "Error Reading Image" failures for both English and Russian.

## What
1. Revert `tess_command` in `TesseractTrigger.vala` to standard `tesseract <file_path> <out_path> -l $lang`, leveraging Tesseract's default automatic page layout engine.
2. Ensure Russian language selection in `LanguageButton.vala` maps to `rus`.

## Impact
- Restores reliable OCR recognition for English and Russian text on all screenshots and images.
