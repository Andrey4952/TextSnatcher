# Change Proposal: Fix File Chooser and Clipboard OCR

## Why
1. Clicking "Choose File" in the main UI or tray menu opens the file picker dialog intermittently ("через раз") due to D-Bus request state collisions in `Xdp.Portal.open_file`.
2. Selecting "Get from Clipboard" fails with "Error Reading Image" because `pixbuf.save_to_stream_async` leaves the destination `/tmp/textshot.png` file empty/un-flushed when `read_image` executes. Furthermore, missing null checks on `pixbuf` can cause crashes if clipboard contains non-image data.

## What
1. Refactor `accept_files_fromchooser ()` in `TesseractTrigger.vala` to use `Gtk.FileChooserNative` with an `image/*` file filter for 100% reliable dialog opening.
2. Fix `clipboard_callback ()` in `TesseractTrigger.vala` to use `pixbuf.save (scrot_path, "png")` for atomic synchronous disk writing and add `pixbuf == null` safety checks.

## Impact
- File chooser opens reliably every single time on all desktop environments.
- "Get from Clipboard" OCR works seamlessly from both the main UI and the tray menu.
