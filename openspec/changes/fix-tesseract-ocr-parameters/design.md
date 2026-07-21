# Design Document: Fix Tesseract OCR Execution Parameters for Screenshots

## 1. Context & Goal
Provide explicit `--dpi 300` and `--psm 6` flags when executing Tesseract for OCR.

---

## 2. Technical Design (`TesseractTrigger.vala`)

Update `read_image (string file_path)`:
```vala
string tess_command = "tesseract " + file_path + " " + out_path + @" -l $lang --dpi 300 --psm 6" ;
```

---

## 3. Risks & Verification
- `--dpi 300` prevents DPI scaling warnings and neural network character distortion.
- `--psm 6` forces Tesseract to treat screenshot images as a block of text rather than a full printed A4 page.
