# Implementation Tasks: Prevent Duplicate MainWindow Creation and Window Popups on Application Activation

- [x] 1. Add `is_initialized` guard to `activate()` in `Application.vala` <!-- id: 1 -->
- [x] 2. Add `delete_event` handler with `hide_on_delete()` in `MainWindow.vala` <!-- id: 2 -->
- [x] 3. Build, install, and verify window remains hidden during tray screenshot <!-- id: 3 -->
