# Design Document: Implement Asynchronous Wayland Screenshot Spawning

## 1. Goal
Asynchronously launch `grim` + `slurp` screenshot utility on Wayland without blocking the main GTK GUI thread.

---

## 2. Technical Design (`TesseractTrigger.vala`)

Update the Wayland path in `get_screenshot` to run asynchronously:
```vala
            } else {
                try {
                    string[] argv = { "sh", "-c", "grim -g \"$(slurp)\" " + scrot_path } ;
                    Pid child_pid ;
                    Process.spawn_async (
                        null,
                        argv,
                        null,
                        SpawnFlags.SEARCH_PATH | SpawnFlags.DO_NOT_REAP_CHILD,
                        null,
                        out child_pid
                    ) ;

                    ChildWatch.add (child_pid, (pid, status) => {
                        Process.close_pid (pid) ;
                        if (status == 0) {
                            read_image.begin (scrot_path, (obj, res) => {}) ;
                        } else {
                            if (label != null) {
                                label.label = "Screenshot Cancelled" ;
                            }
                        }
                    }) ;
                } catch (Error e) {
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
- Verify compilation.
- Ensure clicking "Take Screenshot" immediately launches the crosshair selection without freezing the main application window.
