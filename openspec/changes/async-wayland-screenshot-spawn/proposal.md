# Change Proposal: Implement Asynchronous Wayland Screenshot Spawning

## Why
Using `Process.spawn_sync` to call `grim -g "$(slurp)"` blocks the main GTK GUI thread while the user draws the screenshot selection area. This freezes the application UI, causing the compositor to detect it as unresponsive (frozen).

## What
Refactor the Wayland screenshot handling in `TesseractTrigger.vala` to use `Process.spawn_async` with a non-blocking `ChildWatch.add` handler. This keeps the GTK main loop responsive during the selection process.

## Impact
- Safe, non-blocking area selection screenshots on Wayland/COSMIC.
- No UI freezes or "Application not responding" warnings.
