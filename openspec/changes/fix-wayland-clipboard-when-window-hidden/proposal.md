# Change Proposal: Fix Wayland Clipboard Copying When Application Window is Hidden

## Why
When performing OCR from the system tray while the main application window is hidden, text recognition succeeds, but the recognized text fails to copy to the system clipboard.

This occurs because GTK 3 (`Gtk.Clipboard.set_text`) under Wayland requires a visible, mapped `GdkWindow` surface to hold and claim selection ownership. When TextSnatcher's main window is hidden (`!main_win.visible`), GTK 3 cannot claim selection ownership on Wayland, causing `clipboard.set_text()` to fail silently.

## What
In `TesseractTrigger.vala` (`copy_to_clipboard()`), spawn `wl-copy <text>` asynchronously when running under Wayland (`XDG_SESSION_TYPE` / `WAYLAND_DISPLAY`). `wl-copy` operates via the Wayland data-control protocol directly and does not require an active/mapped window surface.

## Impact
- Text recognized from tray screenshots (when the main window is hidden) will copy to the system clipboard 100% reliably.
- Standard `Gtk.Clipboard` copying is retained for X11 sessions and UI-focused operations.
