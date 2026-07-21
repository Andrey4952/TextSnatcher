# Change Proposal: Fix Tray Screenshot — No Window Popup

## Why

When the user triggers a screenshot from the system tray (via `CosmicTray` or `TrayIcon`) while the main window is hidden, the window immediately appears and covers the area the user is trying to select. This causes two issues:

1. **Window popup**: The main window becomes visible even though the user never asked to show it — it just wanted a screenshot.
2. **Multi-monitor OCR failure**: If the screenshot area is on a different monitor from the TextSnatcher window, the window popping up over the selection area makes it impossible to click the correct region, breaking OCR on that monitor.

## Root Cause

Both `CosmicTray.present_and_get_label()` and `TrayIcon.present_and_get_label()` unconditionally call `w.present()` on every window, even when the caller only needs a `Gtk.Label` reference for status updates. The `present()` brings the window to the foreground on every screenshot action.

## What

Decouple "get the status label" from "present the window":

- Add a new private method `get_label_only()` (no `present()` call) in both `CosmicTray` and `TrayIcon`.
- Use `get_label_only()` for screenshot, clipboard, and file actions.
- Keep `present_and_get_label()` (with `present()`) only for the explicit **Show Window** action.

## Scope

- `src/components/CosmicTray.vala` — 2 changes (new method + call-site fix)
- `src/components/TrayIcon.vala` — 2 changes (new method + call-site fix)
- No changes to `TesseractTrigger.vala`, build files, or UI layout
