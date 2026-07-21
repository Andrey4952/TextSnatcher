# Change Proposal: Fix Wayland Grab Conflict and Hidden Window Popups on Screenshot

## Why
When taking a screenshot from the system tray:
1. **Hidden Window Popup:** If the main TextSnatcher window is hidden, it pops up immediately. This is caused by updating the label widget (`label.label = ...`) belonging to the hidden `MainWindow` during the OCR process, which triggers a GTK map/resize event that the window manager (especially COSMIC) interprets as an activation request.
2. **Multi-Monitor/Wayland OCR Failure:** Taking a screenshot of the external monitor (HDMI-A-1 with 1.5x scale) fails to create `/tmp/textshot.png` because `slurp` fails to acquire the Wayland input grab. This happens because the panel applet's menu is still in its close animation and holding the seat grab when `slurp` is spawned instantly.

## What
1. **Decouple Hidden Window Label Updates:** In `CosmicTray.vala` and `TrayIcon.vala`, if the main window is hidden (`!main_win.visible`), pass a dummy `new Gtk.Label("")` to `TesseractTrigger` instead of the window's actual label. This prevents any widget updates in the hidden window, keeping it hidden.
2. **Add Spawning Delay:** In `TesseractTrigger.vala`, add a 200ms non-blocking delay using `GLib.Timeout.add` before spawning `grim -g "$(slurp)"` on Wayland. This gives the panel menu enough time to close and release its input grab, allowing `slurp` to succeed.

## Impact
- Screenshots taken from the tray will no longer cause the hidden main window to pop up.
- Wayland screenshots on all monitors (including those with fractional scaling and external screens) will work reliably without grab conflicts.
