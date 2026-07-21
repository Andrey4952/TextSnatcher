# Change Proposal: Fix wl-paste Command Execution for Wayland Clipboard OCR

## Why
In `try_wl_paste_fallback()`, the command string `"wl-paste -t image/png > /tmp/textshot.png"` is passed to `Process.spawn_command_line_sync`. Because GLib executes the binary directly without passing through a shell (`/bin/sh`), the `>` character is passed as an argument to `wl-paste`, causing it to fail with `Unexpected argument: >`.

## What
Refactor `try_wl_paste_fallback()` in `TesseractTrigger.vala` to execute `"wl-paste -t image/png"` without shell redirection, capturing standard output directly into a `uint8[]` byte array and writing it to disk using `FileUtils.set_data()`.

## Impact
- Eliminates shell syntax errors in `wl-paste` execution.
- 100% reliable Wayland clipboard fallback for image OCR.
