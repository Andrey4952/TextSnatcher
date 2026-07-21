# Implementation Tasks: Fix Wayland Grab Conflict and Hidden Window Popups on Screenshot

- [x] 1. Check window visibility in `CosmicTray.vala` and use a dummy label if the window is hidden <!-- id: 1 -->
- [x] 2. Check window visibility in `TrayIcon.vala` and use a dummy label if the window is hidden <!-- id: 2 -->
- [x] 3. Add a 200ms delay before spawning `grim/slurp` in `TesseractTrigger.vala` <!-- id: 3 -->
- [x] 4. Build, install, and verify both issues are resolved <!-- id: 4 -->
