# Change Proposal: Support Multi-Format and URI Clipboard OCR on Wayland

## Why
Hardcoding `wl-paste -t image/png` in `try_wl_paste_fallback()` fails whenever the clipboard contains JPEG/BMP/WebP images or copied image files from file managers (`text/uri-list`). `wl-paste` exits with `Clipboard content is not available as requested type "image/png"`.

## What
Refactor `try_wl_paste_fallback()` in `TesseractTrigger.vala` to:
1. Dynamically inspect offered clipboard types using `wl-paste --list-types`.
2. Extract image bytes for any `image/*` MIME type (`image/jpeg`, `image/png`, `image/bmp`, `image/webp`, `image/tiff`).
3. Handle `text/uri-list` clipboard entries by extracting `file://` paths via `GLib.Filename.from_uri` and reading the image file directly.

## Impact
- Enables clipboard OCR for JPEG, BMP, WebP, and copied image files from file managers under Wayland.
