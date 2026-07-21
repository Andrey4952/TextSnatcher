# Design Document: Support Multi-Format and URI Clipboard OCR on Wayland

## 1. Context & Goal
Provide adaptive, multi-format image detection in `try_wl_paste_fallback()`.

---

## 2. Technical Design (`TesseractTrigger.vala`)

Update `try_wl_paste_fallback()`:
```vala
bool try_wl_paste_fallback () {
    try {
        string types ;
        int exit_status ;
        Process.spawn_command_line_sync ("wl-paste --list-types", out types, null, out exit_status) ;
        if (exit_status != 0 || types == null || types.length == 0) {
            return false ;
        }

        string target_type = "" ;
        foreach (string line in types.split ("\n")) {
            string t = line.strip () ;
            if (t.has_prefix ("image/")) {
                target_type = t ;
                break ;
            }
        }

        if (target_type.length > 0) {
            string out_bytes ;
            string cmd = "wl-paste -t " + target_type ;
            Process.spawn_command_line_sync (cmd, out out_bytes, null, out exit_status) ;
            if (exit_status == 0 && out_bytes != null && out_bytes.length > 0) {
                FileUtils.set_data (scrot_path, out_bytes.data) ;
                return true ;
            }
        } else if (types.contains ("text/uri-list")) {
            string uris ;
            Process.spawn_command_line_sync ("wl-paste -t text/uri-list", out uris, null, out exit_status) ;
            if (exit_status == 0 && uris != null && uris.length > 0) {
                string first_uri = uris.split ("\n")[0].strip () ;
                if (first_uri.has_prefix ("file://")) {
                    string path = GLib.Filename.from_uri (first_uri, null) ;
                    File f = File.new_for_path (path) ;
                    if (f.query_exists (null)) {
                        f.copy (File.new_for_path (scrot_path), FileCopyFlags.OVERWRITE, null, null) ;
                        return true ;
                    }
                }
            }
        }
    } catch (Error e) {
        print ("wl-paste fallback error: %s\n", e.message) ;
    }
    return false ;
}
```

---

## 3. Risks & Verification
- `wl-paste --list-types` lists all supported MIME types offered by clipboard provider.
- `GLib.Filename.from_uri` handles URI decoding for file links.
