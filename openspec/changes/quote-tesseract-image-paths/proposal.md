# Change Proposal: Quote Image Paths for Tesseract Execution

## Why
In Russian Linux environments, system portals save screenshots to paths containing spaces, such as `/home/kunui/Картинки/Снимки экрана/Снимок экрана от 2026-07-21.png`. When executing Tesseract via `Process.spawn_command_line_sync`, unquoted spaces cause `GLib.shell_parse_argv` to split the filename into multiple invalid arguments. Tesseract then fails with "No such file or directory", resulting in an "Error Reading Image" failure.

## What
Safely quote `file_path` and `out_path` parameters with single quotes `'...'` in `TesseractTrigger.vala` prior to constructing the `tesseract` execution command string.

## Impact
- Ensures screenshots from directories containing spaces and Cyrillic names (e.g. `Снимки экрана`) are successfully read by Tesseract.
