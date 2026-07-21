# Capability: System Tray Integration

## Added Requirements

### Requirement: Native System Tray Indicator
The application SHALL register a System Tray indicator (`CosmicTray` on Wayland/COSMIC and `TrayIcon` on X11).

#### Scenario: Taking Screenshot from Tray
- **GIVEN** the application is running in the background or minimized
- **WHEN** the user clicks "Take Screenshot" in the system tray menu
- **THEN** a screenshot grab SHALL initiate silently without raising or unhiding the main application window.

### Requirement: Hide to Tray on Window Close
- **GIVEN** the main application window is open
- **WHEN** the user clicks the window close button (`X`)
- **THEN** the window SHALL minimize/hide to the system tray instead of terminating the application process.
