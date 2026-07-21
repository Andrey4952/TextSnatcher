# Design Document: Enable Hybrid Russian-English OCR

## 1. Context & Goal
Enable dual-dictionary `rus+eng` recognition for Russian language selection to support mixed Russian/English text.

---

## 2. Technical Design (`LanguageButton.vala`)

1. Map Russian menu item to `rus+eng`:
   ```vala
   menu_list.add (create_lang_button ("Russian", "rus+eng", popover)) ;
   ```

2. Update `load_config ()` fallback:
   ```vala
   if (sys_lang.contains ("ru") || sys_lang.contains ("RU")) return "rus+eng" ;
   ```

---

## 3. Verification
- `tesseract <image> stdout -l rus+eng` accurately parses English text, Russian text, and mixed text.
