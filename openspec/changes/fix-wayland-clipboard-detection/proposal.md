# Change Proposal: Fix Wayland Clipboard Image Detection

## Why
Under Wayland (COSMIC, GNOME, KDE, etc.), selecting "Get from Clipboard" fails with "No Image found in Clipboard" even when an image exists in the clipboard. This happens because `clipboard.wait_is_image_available()` is a blocking synchronous GTK3 call that times out during Wayland compositor event loop iterations, and GTK3's built-in MIME target matcher misses images copied by certain Wayland screenshot tools (e.g. `grim`, Flameshot, Spectacle, COSMIC screenshot).

## What
1. Remove the blocking `clipboard.wait_is_image_available()` pre-check in `TesseractTrigger.vala` and invoke `clipboard.request_image(clipboard_callback)` asynchronously directly.
2. Implement a `wl-paste` fallback mechanism in `TesseractTrigger.vala`: if `clipboard.request_image` receives `null` pixbuf under Wayland, attempt `wl-paste -t image/png > /tmp/textshot.png` to extract the image directly from the Wayland data offer.

## Impact
- 100% reliable image OCR from clipboard on Wayland and X11 desktops.
