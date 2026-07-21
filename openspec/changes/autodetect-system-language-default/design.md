# Design Document: Auto-detect System Language Default for OCR

## 1. Context & Goal
Default OCR language to match the user's OS locale when no saved preference exists.

---

## 2. Technical Design (`LanguageButton.vala`)

Update `load_config ()`:
```vala
private static string load_config () {
    try {
        var keyfile = new KeyFile () ;
        if (keyfile.load_from_file (get_config_path (), KeyFileFlags.NONE)) {
            string l = keyfile.get_string ("Settings", "language") ;
            if (l != null && l.length > 0) return l ;
        }
    } catch (Error e) {}

    foreach (string name in Environment.get_language_names ()) {
        if (name.has_prefix ("ru")) return "rus" ;
        if (name.has_prefix ("de")) return "deu" ;
        if (name.has_prefix ("fr")) return "fra" ;
        if (name.has_prefix ("es")) return "spa" ;
        if (name.has_prefix ("zh")) return "chi_sim" ;
        if (name.has_prefix ("ja")) return "jpn" ;
    }
    return "eng" ;
}
```

---

## 3. Risks & Verification
- `Environment.get_language_names()` is a standard GLib API that works across Linux distributions.
