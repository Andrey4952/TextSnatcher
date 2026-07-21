# Change Proposal: Fix Tesseract OCR Execution Parameters for Screenshots

## Why
When Tesseract runs on desktop screenshots without explicit DPI and page segmentation parameters, Tesseract 5.5 logs `Warning: Invalid resolution 0 dpi` and defaults to `--psm 3` (full page layout mode). For cropped screenshots, UI snippets, and selected region captures, `--psm 3` frequently reports `Empty page!!`, generating empty 0-byte text files and causing "Error Reading Image" failures (especially noticeable on Russian text).

## What
Update `read_image()` in `TesseractTrigger.vala` to pass explicit `--dpi 300` and `--psm 6` (assume a single uniform block of text) flags when invoking Tesseract.

## Impact
- Resolves "Empty page!!" and 0-byte OCR output for cropped screenshots and selected regions.
- Ensures accurate character recognition for Russian, English, and multilingual text snippets.
