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
        portal = new Xdp.Portal () ;
        clipboard = Gtk.Clipboard.get_default (display) ;
    }

    public void accept_files_fromchooser (Gtk.Window? parent_window = null) {
        var chooser = new Gtk.FileChooserNative (
            "Select an Image to perform OCR !",
            parent_window,
            Gtk.FileChooserAction.OPEN,
            "_Open",
            "_Cancel"
        ) ;
        var filter = new Gtk.FileFilter () ;
        filter.set_filter_name ("Images") ;
        filter.add_mime_type ("image/*") ;
        chooser.add_filter (filter) ;

        if (chooser.run () == Gtk.ResponseType.ACCEPT) {
            string filename = chooser.get_filename () ;
            if (filename != null && filename.length > 0) {
                string lead_file = "\'" + filename + "\'" ;
                read_image.begin (lead_file, (obj, res) => {
                    print ("Reading file from chooser: %s\n", filename) ;
                }) ;
            }
        }
        chooser.destroy () ;
    }

    async void save_shot_scrot () {
        try {
            Process.spawn_command_line_sync ("scrot -s -o " + scrot_path) ;
            yield read_image (scrot_path) ;
        } catch (Error e) {
            print (e.message) ;
        }
    }

    async void read_image (string file_path) {
        string lang = LanguageButton.preferred_language ;
        if (label != null) {
            label.label = "Reading Image" ;
        }
        Idle.add (read_image.callback) ;
        yield ;
        try {
            string tess_command = "tesseract " + file_path + " " + out_path + @" -l $lang --dpi 300 --psm 6" ;
            Process.spawn_command_line_sync (tess_command, out res, out err, out stat) ;
            if (stat == 0) {
                copy_to_clipboard () ;
            } else {
                print ("Error is " + err + " status is " + stat.to_string ()) ;
                if (label != null) {
                    label.label = "Error Reading Image" ;
                }
            }
        } catch (Error e) {
            critical (e.message) ;
            if (e.code == 8 && label != null) {
                label.label = "Dependencies Not Found" ;
            }
        }
    }

    public void save_to_documents () {
        copy_to_clipboard () ;
    }

    public void save_to_images () {
        copy_to_clipboard () ;
    }

    public void copy_to_clipboard () {
        try {
            string text_output ;
            FileUtils.get_contents (out_path + ".txt", out text_output) ;
            if (text_output.length > 0) {
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

    public async void get_screenshot (Gtk.Label label_widget, string type) {
        string session = GLib.Environment.get_variable ("XDG_SESSION_TYPE") ;
        if (type == "file") {
            accept_files_fromchooser () ;
        } else if (type == "clip") {
            if (label != null) {
                label.label = "Reading Image" ;
            }
            clipboard.request_image (clipboard_callback) ;
        } else {
            if (session == "x11") {
                yield save_shot_scrot () ;
            } else {
                portal.take_screenshot.begin (
                    null,
                    Xdp.ScreenshotFlags.INTERACTIVE,
                    null,
                    save_shot
                ) ;
            }
        }
    }

    bool try_wl_paste_fallback () {
        try {
            string types ;
            int exit_status ;
            Process.spawn_command_line_sync ("wl-paste --list-types", out types, null, out exit_status) ;
            if (exit_status != 0 || types == null || types.length == 0) {
                return false ;
            }

            string target_type = "" ;
            foreach (string line in types.split ("\n")) {
                string t = line.strip () ;
                if (t.has_prefix ("image/")) {
                    target_type = t ;
                    break ;
                }
            }

            if (target_type.length > 0) {
                string out_bytes ;
                string cmd = "wl-paste -t " + target_type ;
                Process.spawn_command_line_sync (cmd, out out_bytes, null, out exit_status) ;
                if (exit_status == 0 && out_bytes != null && out_bytes.length > 0) {
                    FileUtils.set_data (scrot_path, out_bytes.data) ;
                    return true ;
                }
            } else if (types.contains ("text/uri-list")) {
                string uris ;
                Process.spawn_command_line_sync ("wl-paste -t text/uri-list", out uris, null, out exit_status) ;
                if (exit_status == 0 && uris != null && uris.length > 0) {
                    string first_uri = uris.split ("\n")[0].strip () ;
                    if (first_uri.has_prefix ("file://")) {
                        string path = GLib.Filename.from_uri (first_uri, null) ;
                        File f = File.new_for_path (path) ;
                        if (f.query_exists (null)) {
                            f.copy (File.new_for_path (scrot_path), FileCopyFlags.OVERWRITE, null, null) ;
                            return true ;
                        }
                    }
                }
            }
        } catch (Error e) {
            print ("wl-paste fallback error: %s\n", e.message) ;
        }
        return false ;
    }

    void clipboard_callback (Gtk.Clipboard _, Gdk.Pixbuf? pixbuf) {
        if (pixbuf == null) {
            if (try_wl_paste_fallback ()) {
                read_image.begin (scrot_path, (obj, res) => {
                    print ("Reading image from wl-paste fallback\n") ;
                }) ;
                return ;
            }
            print ("No image found in clipboard\n") ;
            if (label != null) {
                label.label = "No Image found in Clipboard" ;
            }
            return ;
        }

        try {
            File file = File.new_for_path (scrot_path) ;
            if (file.query_exists (null)) {
                file.delete (null) ;
            }
            pixbuf.save (scrot_path, "png") ;
            read_image.begin (scrot_path, (obj, res) => {
                print ("Reading image from clipboard\n") ;
            }) ;
        } catch (Error err) {
            critical (err.message) ;
            if (label != null) {
                label.label = "Error Reading Image" ;
            }
        }
    }

    public void save_shot (GLib.Object ? obj, GLib.AsyncResult res) {
        string uri ;
        try {
            uri = portal.take_screenshot.end (res) ;
            string path = GLib.Filename.from_uri (uri, null) ;
            read_image.begin (path, (obj, res) => {
                print ("Taking Screenshot") ;
            }) ;
        } catch (Error e) {
            critical (e.message) ;
        }
    }

    public async bool start_tess_process (Gtk.Label label_widget, string type) {
        label = label_widget ;
        yield get_screenshot (label_widget, type) ;

        return true ;
    }
}
