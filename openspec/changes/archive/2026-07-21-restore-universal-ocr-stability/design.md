# Design Document: Restore Universal OCR Stability for English and Russian

## 1. Context & Goal
Restore reliable OCR execution for all image layouts and language models.

---

## 2. Technical Design

### A. Tesseract Command (`TesseractTrigger.vala`)
```vala
string tess_command = "tesseract " + file_path + " " + out_path + @" -l $lang" ;
```

### B. Russian Language Mapping (`LanguageButton.vala`)
```vala
menu_list.add (create_lang_button ("Russian", "rus", popover)) ;
```

---

## 3. Verification
- Standard Tesseract automatic layout analysis (`PSM 3`) handles both single-line and multi-line screenshots smoothly.
