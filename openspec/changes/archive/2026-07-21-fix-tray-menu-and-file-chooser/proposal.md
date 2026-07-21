# Change Proposal: Fix Tray Menu and File Chooser

## Why
1. The "Snatch Now!" item in the system tray menu is redundant and unneeded.
2. Selecting an image via "Choose File" fails with "Error Reading Image" if the file or directory path contains non-ASCII characters (e.g. Cyrillic directory names like `Документы` or spaces/symbols). This is caused by manual string slicing `files[0].substring(7).replace("%20", " ")` in `TesseractTrigger.vala`, which fails to decode URI percent-encoding properly.

## What
1. Remove "Snatch Now!" menu entry and its separator from both `CosmicTray.vala` and `TrayIcon.vala`.
2. Update `filechooser_callback` in `TesseractTrigger.vala` to decode file URIs using `GLib.Filename.from_uri()`.

## Impact
- Cleaner tray context menu.
- Reliable OCR functionality when selecting files from any location on disk.
