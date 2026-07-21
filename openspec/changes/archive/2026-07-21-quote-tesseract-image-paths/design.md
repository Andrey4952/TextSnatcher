# Design Document: Quote Image Paths for Tesseract Execution

## 1. Context & Goal
Ensure file paths containing spaces and Cyrillic characters are passed as single contiguous arguments to Tesseract.

---

## 2. Technical Design (`TesseractTrigger.vala`)

Update `read_image (string file_path)`:
```vala
string quoted_file = file_path.has_prefix ("'") ? file_path : "'" + file_path + "'" ;
string quoted_out = out_path.has_prefix ("'") ? out_path : "'" + out_path + "'" ;
string tess_command = "tesseract " + quoted_file + " " + quoted_out + @" -l $lang" ;
```

---

## 3. Risks & Verification
- Checking `.has_prefix("'")` prevents double-quoting paths passed from `accept_files_fromchooser()`.
- Single quotes preserve all characters inside `GLib.shell_parse_argv()`.
