public class TesseractTrigger : Object {
    string out_path = GLib.Environment.get_home_dir () + "/.textsnatcher" ;
    string scrot_path = GLib.Environment.get_tmp_dir () + "/textshot.png" ;
    Gtk.Clipboard clipboard ;
    string res ;
    string err ;
    int stat ;
    Gdk.Display display = Gdk.Display.get_default () ;
    Gtk.Label label ;
    Xdp.Portal portal ;

    construct {
        Logger.info("Initializing TesseractTrigger");
        portal = new Xdp.Portal () ;
        clipboard = Gtk.Clipboard.get_default (display) ;
        // A standalone label so OCR triggered from the tray (where no UI
        // widget is passed in) doesn't NULL-deref when updating status.
        label = new Gtk.Label ("") ;
        Logger.debug("TesseractTrigger initialized with portal and clipboard");
    }

    public void accept_files_fromchooser () {
        Logger.info("Opening file chooser dialog for image selection");
        portal.open_file.begin (
            null,
            "Select an Image to perform OCR !",
            null,
            null,
            null,
            Xdp.OpenFileFlags.NONE,
            null,
            filechooser_callback
        ) ;
    }

    public async void save_shot_cosmic_screenshot () {
        Logger.info("Attempting to take screenshot using cosmic-screenshot");
        try {
            // Check if cosmic-screenshot is available
            int exit_status;
            string stdout, stderr;
            Process.spawn_command_line_sync ("which cosmic-screenshot", out stdout, out stderr, out exit_status);

            if (exit_status == 0) {
                Logger.debug("cosmic-screenshot found, using it for screenshot");
                // cosmic-screenshot is available, use it
                string[] argv = { "cosmic-screenshot", "--interactive=true" };
                var subprocess = new GLib.Subprocess.newv (argv, GLib.SubprocessFlags.STDOUT_PIPE | GLib.SubprocessFlags.STDERR_PIPE);
                yield subprocess.communicate_utf8_async (null, null, out stdout, out stderr);
                bool success = subprocess.get_successful ();

                // cosmic-screenshot returns the path to the saved screenshot
                if (success && stdout.strip().length > 0) {
                    string screenshot_path = stdout.strip();
                    Logger.info(@"cosmic-screenshot returned path: $(screenshot_path)");
                    yield read_image (screenshot_path) ;
                } else {
                    Logger.warn("cosmic-screenshot failed, falling back to scrot");
                    // If cosmic-screenshot fails, fall back to scrot
                    yield save_shot_scrot_fallback();
                }
            } else {
                Logger.info("cosmic-screenshot not found, falling back to scrot");
                // cosmic-screenshot not available, fall back to scrot
                yield save_shot_scrot_fallback();
            }
        } catch (Error e) {
            Logger.error(@"Error in cosmic-screenshot process: $(e.message)");
            // On error, fall back to scrot
            try {
                yield save_shot_scrot_fallback();
            } catch (Error fallback_error) {
                Logger.error(@"Fallback to scrot also failed: $(fallback_error.message)");
            }
        }
    }

    async void save_shot_scrot_fallback () {
        try {
            Logger.info(@"Using scrot for screenshot: $(scrot_path)");
            Process.spawn_command_line_sync ("scrot -s -o " + scrot_path) ;
            yield read_image (scrot_path) ;
        } catch (Error e) {
            Logger.error(@"Error in scrot fallback: $(e.message)");
            print (e.message) ;
        }
    }

    void filechooser_callback (GLib.Object ? obj, GLib.AsyncResult res) {
        GLib.Variant info ;
        try {
            Logger.debug("Processing file chooser callback");
            info = portal.open_file.end (res) ;
            Variant uris = info.lookup_value ("uris", VariantType.STRING_ARRAY) ;
            string[] files = uris as string[] ;
            if (files.length > 0) {
                string uri = files[0];
                // Decode URI and extract file path
                string file_path = GLib.Filename.from_uri(uri, null);
                Logger.info(@"Selected file for OCR: $(file_path)");
                read_image.begin (file_path, (obj, res) => {
                    Logger.debug("Finished reading file from chooser") ;
                }) ;
            } else {
                Logger.warn("No files selected in file chooser");
            }
        } catch (Error e) {
            Logger.error(@"Error in file chooser callback: $(e.message)") ;
            critical (e.message) ;
        }
    }

    async void read_image (string file_path) {
        var lang_service = new LanguageService () ;
        string lang = lang_service.get_pref_language () ;
        label.label = "Reading Image" ;
        Idle.add (read_image.callback) ;
        yield ;
        try {
            Logger.info(@"Starting OCR process for file: $(file_path) with language: $(lang)");
            // Ensure both English and Russian are available for better recognition
            string final_lang = lang;
            if (lang == "rus") {
                // Use both Russian and English for better accuracy
                final_lang = "rus+eng";
            } else if (lang == "eng") {
                // Use both English and Russian for better accuracy
                final_lang = "eng+rus";
            }
            string tess_command = "tesseract \"" + file_path + "\" " + out_path + @" -l $(final_lang)" ;
            Process.spawn_command_line_sync (tess_command, out res, out err, out stat) ;
            if (stat == 0) {
                Logger.info("OCR process completed successfully");
                copy_to_clipboard () ;
            } else {
                Logger.error(@"OCR process failed with error: $(err), status: $(stat.to_string())") ;
                label.label = "Error Reading Image" ;
            }
        } catch (Error e) {
            Logger.error(@"Exception during OCR process: $(e.message)") ;
            critical (e.message) ;
            if (e.code == 8) {
                label.label = "Dependencies Not Found" ;
            }
        }
    }

    public void copy_to_clipboard () {
        Logger.info("Copying extracted text to clipboard");
        try {
            string text_output ;
            FileUtils.get_contents (out_path + ".txt", out text_output) ;
            if (text_output.length > 0) {
                string[] argv = { "wl-copy" };
                var proc = new GLib.Subprocess.newv (argv, GLib.SubprocessFlags.STDIN_PIPE);
                try {
                    proc.get_stdin_pipe ().write_all (text_output.data, null);
                    proc.get_stdin_pipe ().close (null);
                } catch (Error we) {
                    Logger.error (@"wl-copy stdin error: $(we.message)");
                }

                label.label = "Checkout Clipboard :)" ;
                Logger.info(@"Text successfully copied to clipboard ($(text_output.length) characters)");
            } else {
                label.label = "Error Reading Image" ;
                Logger.warn("No text extracted to copy to clipboard");
            }
        } catch (Error e) {
            Logger.error(@"Error copying text to clipboard: $(e.message)");
        }
    }

    public void save_to_documents () {
        Logger.info("Saving extracted text to Documents folder");
        try {
            string text_output ;
            FileUtils.get_contents (out_path + ".txt", out text_output) ;
            if (text_output.length > 0) {
                string documents_dir = Environment.get_user_special_dir (UserDirectory.DOCUMENTS);
                if (documents_dir == null) {
                    Logger.warn("Documents directory not found, using home directory as fallback");
                    // Fallback to home directory if documents directory not found
                    documents_dir = Environment.get_home_dir ();
                }

                string timestamp = new DateTime.now ().format ("%Y-%m-%d_%H-%M-%S");
                string filename = @"textsnatcher_$timestamp.txt";
                string filepath = Path.build_filename (documents_dir, filename);

                FileUtils.set_contents (filepath, text_output) ;
                label.label = "Saved to Documents :)";
                Logger.info(@"Text saved to Documents: $(filepath)");
            } else {
                label.label = "Error Reading Image" ;
                Logger.warn("No text extracted to save to Documents");
            }
        } catch (Error e) {
            Logger.error(@"Error saving text to Documents: $(e.message)");
            label.label = "Error Saving to Documents" ;
        }
    }

    public void save_to_images () {
        Logger.info("Saving extracted text to Images folder");
        try {
            string text_output ;
            FileUtils.get_contents (out_path + ".txt", out text_output) ;
            if (text_output.length > 0) {
                string pictures_dir = Environment.get_user_special_dir (UserDirectory.PICTURES);
                if (pictures_dir == null) {
                    Logger.warn("Pictures directory not found, using home directory as fallback");
                    // Fallback to home directory if pictures directory not found
                    pictures_dir = Environment.get_home_dir ();
                }

                string timestamp = new DateTime.now ().format ("%Y-%m-%d_%H-%M-%S");
                string filename = @"textsnatcher_$timestamp.txt";
                string filepath = Path.build_filename (pictures_dir, filename);

                FileUtils.set_contents (filepath, text_output) ;
                label.label = "Saved to Images :)";
                Logger.info(@"Text saved to Images: $(filepath)");
            } else {
                label.label = "Error Reading Image" ;
                Logger.warn("No text extracted to save to Images");
            }
        } catch (Error e) {
            Logger.error(@"Error saving text to Images: $(e.message)");
            label.label = "Error Saving to Images" ;
        }
    }

    public string get_extracted_text () {
        try {
            string text_output ;
            FileUtils.get_contents (out_path + ".txt", out text_output) ;
            return text_output ;
        } catch (Error e) {
            print (e.message) ;
            return "";
        }
    }

    public async void get_screenshot (Gtk.Label label_widget, string type) {
        Logger.info(@"Getting screenshot with type: $(type)");
        string session = GLib.Environment.get_variable ("XDG_SESSION_TYPE") ;
        if (type == "file") {
            Logger.debug("Opening file chooser for image selection");
            accept_files_fromchooser () ;
        } else if (type == "clip") {
            Logger.debug("Getting image from clipboard");
            if (clipboard.wait_is_image_available ()) {
                clipboard.request_image (clipboard_callback) ;
            } else {
                Logger.warn("No image found in clipboard");
                label.label = "No Image found in Clipboard" ;
            }
        } else {
            Logger.debug("Taking screenshot using cosmic-screenshot fallback");
            // Try cosmic-screenshot first as it provides better UX
            yield save_shot_cosmic_screenshot ();
        }
    }

    void clipboard_callback (Gtk.Clipboard _, Gdk.Pixbuf pixbuf) {
        Logger.debug("Processing clipboard image callback");
        try {
            File file = File.new_for_path (Path.build_filename (scrot_path)) ;
            if (file.query_exists (null)) {
                file.delete (null) ;
            }
            DataOutputStream fos = new DataOutputStream (file.create (FileCreateFlags.REPLACE_DESTINATION)) ;
            pixbuf.save_to_stream_async.begin (fos, "png", null, () => {
                Logger.info(@"Reading image from clipboard, saving to: $(scrot_path)");
                read_image.begin (scrot_path, (obj, res) => {
                    Logger.debug("Finished reading image from clipboard") ;
                }) ;
            }) ;
        } catch (Error err) {
            Logger.error(@"Error in clipboard callback: $(err.message)") ;
            critical (err.message) ;
        }
    }

    public void save_shot (GLib.Object ? obj, GLib.AsyncResult res) {
        string uri ;
        try {
            Logger.debug("Processing screenshot from portal");
            uri = portal.take_screenshot.end (res) ;
            string path = GLib.Filename.from_uri (uri, null) ;
            Logger.info(@"Screenshot saved to: $(path)");
            read_image.begin (path, (obj, res) => {
                Logger.debug("Finished reading screenshot from portal") ;
            }) ;
        } catch (Error e) {
            Logger.error(@"Error in portal screenshot: $(e.message)");
            critical (e.message) ;
        }
    }

    // Take a screenshot via the XDG desktop portal (works on COSMIC/Wayland).
    // interactive=true lets COSMIC show the region/window picker (Selection);
    // interactive=false captures the full screen (Fullscreen).
    public void take_screenshot_tray (bool interactive) {
        Logger.info(@"Tray: taking screenshot via portal (interactive=$(interactive))");
        try {
            var flags = interactive ? Xdp.ScreenshotFlags.INTERACTIVE : Xdp.ScreenshotFlags.NONE;
            portal.take_screenshot.begin (
                null,
                flags,
                null,
                save_shot
            ) ;
        } catch (Error e) {
            Logger.error(@"Tray screenshot error: $(e.message)");
        }
    }

    public async bool start_tess_process (Gtk.Label label_widget, string type) {
        Logger.info(@"Starting OCR process with type: $(type)");
        label = label_widget ;
        yield get_screenshot (label_widget, type) ;
        Logger.info(@"OCR process completed for type: $(type)");

        return true ;
    }
}
