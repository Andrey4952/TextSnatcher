# Design Document: Fix Wayland Clipboard Image Detection

## 1. Context & Goal
Ensure clipboard image OCR works seamlessly on Wayland and X11 by eliminating GTK3's blocking `wait_is_image_available()` call and adding a `wl-paste` fallback for Wayland compositors.

---

## 2. Technical Design (`TesseractTrigger.vala`)

### A. Remove Synchronous `wait_is_image_available()`
In `get_screenshot(Gtk.Label label_widget, string type)`:
```vala
} else if (type == "clip") {
    if (label != null) {
        label.label = "Reading Image" ;
    }
    clipboard.request_image (clipboard_callback) ;
}
```

### B. `wl-paste` Fallback & `clipboard_callback` Update
```vala
    bool try_wl_paste_fallback () {
        try {
            int exit_status ;
            string cmd = "wl-paste -t image/png > " + scrot_path ;
            Process.spawn_command_line_sync (cmd, null, null, out exit_status) ;
            if (exit_status == 0) {
                File file = File.new_for_path (scrot_path) ;
                if (file.query_exists (null)) {
                    FileInfo info = file.query_info ("standard::size", FileQueryInfoFlags.NONE, null) ;
                    if (info.get_size () > 0) {
                        return true ;
                    }
                }
            }
        } catch (Error e) {
            print ("wl-paste fallback error: %s\n", e.message) ;
        }
        return false ;
    }

    void clipboard_callback (Gtk.Clipboard _, Gdk.Pixbuf? pixbuf) {
        if (pixbuf == null) {
            if (try_wl_paste_fallback ()) {
                read_image.begin (scrot_path, (obj, res) => {
                    print ("Reading image from wl-paste fallback\n") ;
                }) ;
                return ;
            }
            print ("No image found in clipboard\n") ;
            if (label != null) {
                label.label = "No Image found in Clipboard" ;
            }
            return ;
        }

        try {
            File file = File.new_for_path (scrot_path) ;
            if (file.query_exists (null)) {
                file.delete (null) ;
            }
            pixbuf.save (scrot_path, "png") ;
            read_image.begin (scrot_path, (obj, res) => {
                print ("Reading image from clipboard\n") ;
            }) ;
        } catch (Error err) {
            critical (err.message) ;
            if (label != null) {
                label.label = "Error Reading Image" ;
            }
        }
    }
```

---

## 3. Risks & Verification
- `request_image` is native GTK3 async API.
- `wl-paste` fallback operates seamlessly when `request_image` receives `null` on Wayland sessions.
