# Design: Fix Wayland Clipboard Copying When Application Window is Hidden

## `copy_to_clipboard()` Update in `TesseractTrigger.vala`

Update `copy_to_clipboard()` in `TesseractTrigger.vala` to invoke `wl-copy` asynchronously on Wayland sessions:

```vala
    public void copy_to_clipboard () {
        try {
            string text_output ;
            FileUtils.get_contents (out_path + ".txt", out text_output) ;
            if (text_output.length > 0) {
                string session = GLib.Environment.get_variable ("XDG_SESSION_TYPE") ;
                string wayland_display = GLib.Environment.get_variable ("WAYLAND_DISPLAY") ;
                bool is_wayland = (session != null && session.down ().contains ("wayland")) ||
                                 (wayland_display != null && wayland_display.has_prefix ("wayland")) ;
                if (is_wayland) {
                    try {
                        string[] argv = { "wl-copy", text_output } ;
                        Process.spawn_async (null, argv, null, SpawnFlags.SEARCH_PATH, null, null) ;
                    } catch (Error e) { }
                }

                clipboard.set_text (text_output, text_output.length) ;
                if (label != null) {
                    label.label = "Checkout Clipboard :)" ;
                }
            } else {
                if (label != null) {
                    label.label = "Error Reading Image" ;
                }
            }
        } catch (Error e) {
            print (e.message) ;
        }
    }
```
