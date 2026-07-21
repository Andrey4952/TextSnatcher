# Change Proposal: Prevent Duplicate MainWindow Creation and Window Popups on Application Activation

## Why
When the user takes a screenshot or interacts with the system tray indicator, system/panel DBus signals can trigger `Gtk.Application`'s `activate()` method on the running instance.

Previously, `Application.vala` unconditionally created a new `MainWindow` (`main_window = new MainWindow(this)`) every time `activate()` was called. Because `MainWindow`'s constructor calls `show_all()`, every activation created and displayed a new window on top of the screen even if the user had previously hidden the window via "Hide Window".

Additionally, closing `MainWindow` via its window titlebar close button ("X") destroyed the window and killed the application process instead of hiding it to the tray.

## What
1. **Guard `activate()` Initialization:** Add an `is_initialized` flag in `Application.vala`. On subsequent `activate()` calls, do not instantiate a new `MainWindow` or re-register `CosmicTray`/`TrayIcon`. Only call `present()` if `main_window` is already visible.
2. **Hide on Window Close:** In `MainWindow.vala`, intercept `delete_event` to call `hide_on_delete()`, allowing the close button to minimize the window to the tray without exiting the application.

## Impact
- Screenshots taken from the tray while the window is hidden will remain 100% silent and will not pop up any windows.
- Clicking the window close button ("X") will cleanly minimize TextSnatcher to the system tray.
