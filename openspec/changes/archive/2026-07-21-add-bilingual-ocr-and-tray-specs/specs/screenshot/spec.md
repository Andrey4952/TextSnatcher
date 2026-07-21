# Capability: Wayland Screenshot and Clipboard Engine

## Added Requirements

### Requirement: Wayland Native Screenshot Selection
On Wayland display servers, the application SHALL use `grim` and `slurp` for cropped area selection with a non-blocking delay (200ms) to allow panel menus to release Wayland input grabs.

### Requirement: Wayland Clipboard Synchronisation
When text is recognized while the main window is hidden, the application SHALL invoke `wl-copy` to ensure recognized text is copied to the Wayland system clipboard.
