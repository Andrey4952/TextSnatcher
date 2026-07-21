# Design Document: Fix Tray Menu Actions Responsiveness and Visual Feedback

## 1. Context & Goal
Connect tray menu item actions to the main window lifecycle and active UI status label.

---

## 2. Technical Design

### A. Update `TesseractTrigger.vala`
Modify `accept_files_fromchooser(Gtk.Window? parent_window = null)` to set `parent_window` as the parent of `Gtk.FileChooserNative`:
```vala
public void accept_files_fromchooser (Gtk.Window? parent_window = null) {
    var chooser = new Gtk.FileChooserNative (
        "Select an Image to perform OCR !",
        parent_window,
        Gtk.FileChooserAction.OPEN,
        "_Open",
        "_Cancel"
    ) ;
    ...
```

### B. Expose Active Title Label & Window in `MainScreen.vala` / `MainWindow.vala`
Expose `public Gtk.Label get_title_label()` in `MainScreen.vala` so that tray menu implementations can retrieve the real UI status label.

### C. Refactor `CosmicTray.vala` & `TrayIcon.vala`
In `invoke_action (string action)`:
1. Present main window (`w.present()`).
2. Retrieve the active `title_label` from `MainWindow`.
3. Pass `title_label` into `trigger.start_tess_process.begin(title_label, type)`.
4. Pass `main_window` into `trigger.accept_files_fromchooser(main_window)`.

---

## 3. Risks & Verification
- `w.present()` brings the GTK window to front on X11 and Wayland.
- `FileChooserNative` with parent window guarantees modal focus overlay.
