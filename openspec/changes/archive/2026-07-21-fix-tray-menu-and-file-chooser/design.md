# Design Document: Fix Tray Menu and File Chooser

## 1. Context & Goal
Remove "Snatch Now!" from tray menus and fix URI decoding in `TesseractTrigger.vala` when selecting image files via Xdp.Portal file chooser.

---

## 2. Technical Design

### A. Tray Menu Cleanup (`CosmicTray.vala` & `TrayIcon.vala`)
- **`CosmicTray.vala`**:
  - Remove `menu.append (item_with_action ("Snatch Now!", "camera-photo", "snatch_now"));`
  - Remove `menu.append (new Gtk.SeparatorMenuItem ());`
  - Remove handling for `"snatch_now"` in `invoke_action()`.
- **`TrayIcon.vala`**:
  - Remove `snatch_now_item` creation and `separator1` from `build_menu()`.

### B. File Chooser URI Decoding (`TesseractTrigger.vala`)
- In `filechooser_callback(GLib.Object? obj, GLib.AsyncResult res)`:
  Replace:
  ```vala
  string lead_file = "\'" + files[0].substring (7).replace ("%20", " ") + "\'" ;
  ```
  With:
  ```vala
  string path = GLib.Filename.from_uri (files[0], null) ;
  string lead_file = "\'" + path + "\'" ;
  ```

---

## 3. Risks & Alternatives
- `GLib.Filename.from_uri` is standard in GLib and handles all URL percent-encoding (Cyrillic, spaces, special symbols).
