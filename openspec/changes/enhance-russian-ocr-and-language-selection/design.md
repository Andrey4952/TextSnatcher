# Design Document: Enhance Russian OCR and Language Selection UI

## 1. Context & Goal
Improve Russian text OCR accuracy via dual `rus+eng` Tesseract language models, add active language label on the headerbar button, and persist language selection.

---

## 2. Technical Design (`LanguageButton.vala`)

### A. Dual Language Mapping & UI Label
In `LanguageButton.vala`:
- Maintain a map of language codes to Tesseract model parameters and display labels:
  - English: `eng` -> `EN`
  - Russian: `rus+eng` -> `RU`
  - German: `deu` -> `DE`
  - French: `fra` -> `FR`
  - Spanish: `spa` -> `ES`
  - etc.
- Add a `Gtk.Label` or `Gtk.Box` inside the `LanguageButton` to show the active code alongside the locale icon: `[ 🌐 RU ]`.

### B. Config Persistence
Save language preference to `~/.config/textsnatcher/config.ini`:
```vala
void save_config (string lang) {
    try {
        string dir = Environment.get_user_config_dir () + "/textsnatcher" ;
        DirUtils.create_with_parents (dir, 0755) ;
        var keyfile = new KeyFile () ;
        keyfile.set_string ("Settings", "language", lang) ;
        keyfile.to_file (dir + "/config.ini") ;
    } catch (Error e) {}
}

string load_config () {
    try {
        string path = Environment.get_user_config_dir () + "/textsnatcher/config.ini" ;
        var keyfile = new KeyFile () ;
        if (keyfile.load_from_file (path, KeyFileFlags.NONE)) {
            return keyfile.get_string ("Settings", "language") ;
        }
    } catch (Error e) {}
    return "eng" ;
}
```

---

## 3. Risks & Verification
- `rus+eng` requires both `rus` and `eng` tessdata files, which are already present in `/usr/share/tessdata/`.
- Config file loading handles missing directories gracefully and falls back to `eng`.
