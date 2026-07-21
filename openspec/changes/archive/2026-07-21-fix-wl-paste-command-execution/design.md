# Design Document: Fix wl-paste Command Execution for Wayland Clipboard OCR

## 1. Context & Goal
Fix shell redirection error in `try_wl_paste_fallback()`.

---

## 2. Technical Design (`TesseractTrigger.vala`)

Update `try_wl_paste_fallback()` to capture byte output directly:
```vala
bool try_wl_paste_fallback () {
    try {
        uint8[] out_bytes ;
        int exit_status ;
        string cmd = "wl-paste -t image/png" ;
        Process.spawn_command_line_sync (cmd, out out_bytes, null, out exit_status) ;
        if (exit_status == 0 && out_bytes.length > 0) {
            FileUtils.set_data (scrot_path, out_bytes) ;
            return true ;
        }
    } catch (Error e) {
        print ("wl-paste fallback error: %s\n", e.message) ;
    }
    return false ;
}
```

---

## 3. Risks & Verification
- GLib `Process.spawn_command_line_sync` output parameter captures raw PNG bytes without memory truncation.
- `FileUtils.set_data` creates the destination file atomically and flushes contents to disk.
