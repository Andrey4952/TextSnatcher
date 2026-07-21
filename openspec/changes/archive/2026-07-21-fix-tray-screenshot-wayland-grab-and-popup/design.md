# Design: Fix Wayland Grab Conflict and Hidden Window Popups on Screenshot

## 1. Avoid Label Updates on Hidden Window

When a tray action is invoked, `get_label_only` finds the window and returns its title label. If the window is hidden, updating this label triggers layout passes that make the window pop up.

We will check `main_win.visible` before passing the label:

### CosmicTray.vala
```vala
        if (action == "screenshot_sel") {
            MainWindow? main_win = null;
            var label = get_label_only (out main_win);
            if (main_win != null && !main_win.visible) {
                label = new Gtk.Label ("");
            }
            trigger.start_tess_process.begin (label, "shot", (obj, res) => {});
        }
```

We will apply the same checks for `action == "file"` and `action == "clipboard"` in both `CosmicTray.vala` and `TrayIcon.vala`.

---

## 2. Delay grim/slurp Spawning on Wayland

To prevent grab conflicts with the closing tray menu, we will add a 200ms delay in `TesseractTrigger.vala` inside `get_screenshot`:

### TesseractTrigger.vala
```vala
            if (session == "x11") {
                yield save_shot_scrot () ;
            } else {
                // Yield control to the main loop for 200ms to allow the tray menu
                // to close completely and release any active input grabs.
                GLib.Timeout.add (200, get_screenshot.callback);
                yield;

                try {
                    string[] argv = { "sh", "-c", "grim -g \"$(slurp)\" " + scrot_path } ;
                    // ...
```

This yield keeps the operation asynchronous and doesn't freeze the GTK UI.
