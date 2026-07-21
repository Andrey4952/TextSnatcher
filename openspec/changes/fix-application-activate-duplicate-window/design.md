# Design: Prevent Duplicate MainWindow Creation and Window Popups on Application Activation

## 1. Guard `activate()` in `Application.vala`

Introduce a boolean member variable `is_initialized` in `Application.vala`:

```vala
public class Application : Gtk.Application {
    MainWindow main_window ;
    private bool is_initialized = false ;

    protected override void activate () {
        if (is_initialized) {
            if (main_window != null && main_window.visible) {
                main_window.present () ;
            }
            return ;
        }
        is_initialized = true ;

        // ... existing setup ...
```

This prevents duplicate `MainWindow` creation and duplicate tray icon registration when DBus activation signals arrive.

---

## 2. Hide to Tray on Window Close in `MainWindow.vala`

In `MainWindow.vala`:

```vala
    public MainWindow (Gtk.Application app) {
        // ... existing setup ...

        delete_event.connect (() => {
            return hide_on_delete () ;
        }) ;
    }
```

This makes the window close button ("X") gracefully minimize the application to the system tray.
