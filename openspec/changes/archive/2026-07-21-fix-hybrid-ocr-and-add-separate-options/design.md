# Design Document: Implement Proper Hybrid and Separate OCR Language Options

## 1. Goal
Support clean separation of Russian and English OCR modes, while offering a hybrid "Russian + English" mode prioritizing Latin letters to avoid homoglyph spelling errors.

---

## 2. Technical Design

### A. Language Button UI (`LanguageButton.vala`)
1. Expose three options in the menu list:
   - English (`eng`)
   - Russian (`rus`)
   - Russian + English (`eng+rus`)

2. Map `eng+rus` UI label to `RU+`.
3. Default `load_config ()` fallback on Russian systems to `"eng+rus"`.

### B. System Tray Menu (`TrayIcon.vala`)
1. Add a menu item for "Russian + English" mapping to `eng+rus`.
2. Keep "Russian" mapping to `rus`.
3. Keep "English" mapping to `eng`.

---

## 3. Verification
- Test compilation and launch.
- Test that Russian text is parsed as Cyrillic and English text is parsed as Latin without homoglyph corruption.
