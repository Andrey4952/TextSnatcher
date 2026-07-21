# Implementation Tasks: Restore Universal OCR Stability for English and Russian

- [x] 1. Revert `tess_command` in `TesseractTrigger.vala` to `tesseract <file_path> <out_path> -l $lang` <!-- id: 1 -->
- [x] 2. Ensure Russian maps to `rus` in `LanguageButton.vala` <!-- id: 2 -->
- [x] 3. Build, install, and verify application compilation <!-- id: 3 -->
