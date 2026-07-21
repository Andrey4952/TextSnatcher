# Change Proposal: Fix Tray Menu Actions Responsiveness and Visual Feedback

## Why
When clicking tray menu items ("Take Screenshot", "Choose File", "Get from Clipboard"), the application passes an unparented dummy `new Gtk.Label("")` to `TesseractTrigger`. Consequently, status updates ("Reading Image", "Checkout Clipboard :)", "No Image found in Clipboard") are invisible, the main window remains hidden/backgrounded, and file choosers open without a parent window handle, giving the user the impression that the tray menu is broken.

## What
1. Update `CosmicTray.vala` and `TrayIcon.vala` to present/focus the main application window (`w.present()`) whenever a tray action is clicked.
2. Wire tray actions to use the active `HomeScreen.title_label` so all OCR status updates are displayed directly in the main window UI.
3. Pass the main `Gtk.Window` as parent to `Gtk.FileChooserNative` in `TesseractTrigger.vala` so file dialogs open centered on top of the application.

## Impact
- Immediate visual UI feedback and window presentation when triggering actions from the tray menu.
