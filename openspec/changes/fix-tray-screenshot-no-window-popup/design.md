# Design: Fix Tray Screenshot — No Window Popup

## Problem Anatomy

### Current call graph (screenshot from tray)

```
CosmicTray.invoke_action("screenshot_sel")
  └─ present_and_get_label(out main_win)
        ├─ w.present()        ← raises window unconditionally
        └─ main_win.get_title_label()
  └─ trigger.start_tess_process.begin(label, "shot")
        └─ get_screenshot() → grim/slurp
```

`present_and_get_label()` is shared for ALL actions (screenshot, clipboard, file, show window). The `present()` call is only correct for "Show Window".

### Same problem in TrayIcon

```
TrayIcon.present_and_get_label(out main_win)
  └─ w.present()   ← same unconditional raise
```

---

## Solution: Separate "get label" from "present window"

### New method `get_label_only()`

A private helper that walks `app.get_windows()`, finds the `MainWindow`, and returns its label — **without calling `present()`**.

```vala
private Gtk.Label get_label_only (out MainWindow? main_win) {
    main_win = null;
    Gtk.Label label = new Gtk.Label ("");
    if (app != null) {
        foreach (var w in app.get_windows ()) {
            if (w is MainWindow) {
                main_win = (MainWindow) w;
                label = main_win.get_title_label ();
            }
        }
    }
    return label;
}
```

### Updated call sites in CosmicTray

| Action            | Before                      | After                 |
|-------------------|-----------------------------|-----------------------|
| `screenshot_sel`  | `present_and_get_label()`   | `get_label_only()`    |
| `file`            | `present_and_get_label()`   | `get_label_only()`    |
| `clipboard`       | `present_and_get_label()`   | `get_label_only()`    |
| `show`            | `present_and_get_label()`   | unchanged (keep present) |

### Updated call sites in TrayIcon

Same pattern: screenshot / file / clipboard actions switch to `get_label_only()`.

---

## What does NOT change

- `TesseractTrigger.vala` — no changes
- Build system / meson — no changes  
- `accept_files_fromchooser(parent_window)` still receives `main_win` — but `main_win` may be hidden; that's fine, the file chooser dialog is a transient child and will appear regardless
- The "Show Window" menu item keeps `present()` — intentional

---

## Affected files

| File | Lines changed |
|------|---------------|
| `src/components/CosmicTray.vala` | ~+8, ~-3 |
| `src/components/TrayIcon.vala`   | ~+8, ~-3 |
