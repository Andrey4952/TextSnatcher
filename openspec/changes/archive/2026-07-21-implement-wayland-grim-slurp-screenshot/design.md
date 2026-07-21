# Design Document: Implement Wayland Grim and Slurp Screenshot Fallback

## 1. Goal
Provide native cropped area screenshots under Wayland (specifically COSMIC) by invoking `grim` and `slurp`.

---

## 2. Technical Design (`TesseractTrigger.vala`)

Update the Wayland screenshot path in `get_screenshot`:
```vala
            } else {
                // Try grim + slurp first on Wayland
                try {
                    int exit_status ;
                    string[] argv = { "sh", "-c", "grim -g \"$(slurp)\" " + scrot_path } ;
                    Process.spawn_sync (null, argv, null, SpawnFlags.SEARCH_PATH, null, null, null, out exit_status) ;
                    if (exit_status == 0) {
                        read_image.begin (scrot_path, (obj, res) => {}) ;
                    } else {
                        if (label != null) {
                            label.label = "Screenshot Cancelled" ;
                        }
                    }
                } catch (Error e) {
                    // Fallback to portal if grim/slurp fail
                    portal.take_screenshot.begin (
                        null,
                        Xdp.ScreenshotFlags.INTERACTIVE,
                        null,
                        save_shot
                    ) ;
                }
            }
```

---

## 3. Verification
- Test compilation and run.
- Click "Take Screenshot" on COSMIC Wayland; mouse cursor should change to select area, capture, and successfully perform OCR.
