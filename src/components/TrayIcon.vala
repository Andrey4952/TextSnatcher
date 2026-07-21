public class TrayIcon : Object {
    private Gtk.StatusIcon? status_icon = null;
    private Gtk.Menu? tray_menu = null;
    private TesseractTrigger tesseract_trigger;
    private bool is_wayland = false;

    public signal void quit_requested();
    public signal void open_requested();

    private weak Gtk.Application? app;

    public TrayIcon(TesseractTrigger trigger, Gtk.Application? app = null) {
        tesseract_trigger = trigger;
        this.app = app;

        // Check if we're running on Wayland
        var session_type = Environment.get_variable("XDG_SESSION_TYPE");
        var gdk_backend = Environment.get_variable("GDK_BACKEND");

        // Consider as non-Wayland if GDK_BACKEND is set to x11
        is_wayland = (session_type != null && session_type.down().contains("wayland")) &&
                     (gdk_backend == null || !gdk_backend.down().contains("x11"));

        print (@"Detected session type: $(session_type ?? "unknown")\n") ;
        print (@"Detected GDK backend: $(gdk_backend ?? "unknown")\n") ;
        print (@"Wayland detection result: $(is_wayland)\n") ;

        if (is_wayland) {
            print ("Running on Wayland with default backend, tray icon is not supported - skipping initialization\n") ;
        } else {
            print ("Running on X11 or tray icon supported environment (or GDK_BACKEND=x11 forced), initializing tray icon\n") ;
            setup_tray_icon () ;
        }
    }

    private Gtk.Label present_and_get_label (out MainWindow? main_win) {
        main_win = null;
        Gtk.Label label = new Gtk.Label ("");
        if (app != null) {
            foreach (var w in app.get_windows ()) {
                w.present ();
                if (w is MainWindow) {
                    main_win = (MainWindow) w;
                    label = main_win.get_title_label ();
                }
            }
        }
        return label;
    }

    // Returns the status label without raising the window.
    // Use this for screenshot / clipboard / file actions so the window
    // stays hidden when the user triggered the action from the tray.
    private Gtk.Label get_label_only (out MainWindow? main_win) {
        main_win = null;
        Gtk.Label label = new Gtk.Label ("");
        if (app != null) {
            foreach (var w in app.get_windows ()) {
                if (w is MainWindow) {
                    main_win = (MainWindow) w;
                    label = main_win.get_title_label ();
                }
            }
        }
        return label;
    }

    private void setup_tray_icon() {
        print("Setting up tray icon\n");

        try {
            status_icon = new Gtk.StatusIcon();
            status_icon.set_from_icon_name("com.github.rajsolai.textsnatcher");
            status_icon.set_tooltip_text("TextSnatcher - Extract text from images");
            print("Tray icon tooltip set\n");

            // Check if status icon is actually supported (some Wayland compositors may not support it)
            if (status_icon.is_embedded()) {
                status_icon.set_visible(true);
                print("Tray icon embedded and visible\n");
            } else {
                print("Tray icon not embedded, might not be supported in this environment\n");
            }

            // Create context menu
            build_menu();

            status_icon.activate.connect(on_activate);
            status_icon.popup_menu.connect((icon, button, time) => {
                on_popup_menu(icon, button, time);
            });

            print("Tray icon setup completed\n");
        } catch (Error e) {
            critical(@"Failed to create tray icon: $(e.message)");
            status_icon = null;
        }
    }

    private void on_activate() {
        print("Tray icon activated, opening main window\n");
        open_requested();
    }

    private void on_popup_menu(Gtk.StatusIcon? status_icon, uint button, uint32 activate_time) {
        print("Tray icon popup menu requested\n");

        if (status_icon == null) {
            warning("Status icon is null, cannot show popup menu");
            return;
        }

        if (tray_menu == null) {
            build_menu();
        }

        tray_menu?.popup_at_pointer(null);
    }
    
    private void build_menu() {
        tray_menu = new Gtk.Menu();
        
        // Take Screenshot submenu
        var screenshot_menu_item = new Gtk.MenuItem.with_label("Take Screenshot");
        var screenshot_submenu = new Gtk.Menu();
        
        var fullscreen_item = new Gtk.MenuItem.with_label("Fullscreen");
        fullscreen_item.activate.connect(() => {
            print("Fullscreen screenshot selected from tray menu\n");
            // Use a dummy label — do NOT present the window before the screenshot.
            // This avoids the window popping up and covering the selection area.
            MainWindow? main_win = null;
            var label = get_label_only (out main_win);
            if (main_win != null && !main_win.visible) {
                label = new Gtk.Label ("");
            }
            tesseract_trigger.start_tess_process.begin(label, "shot");
        });
        screenshot_submenu.append(fullscreen_item);

        var selection_item = new Gtk.MenuItem.with_label("Selection");
        selection_item.activate.connect(() => {
            print("Selection screenshot selected from tray menu\n");
            MainWindow? main_win = null;
            var label = get_label_only (out main_win);
            if (main_win != null && !main_win.visible) {
                label = new Gtk.Label ("");
            }
            tesseract_trigger.start_tess_process.begin(label, "shot");
        });
        screenshot_submenu.append(selection_item);
        
        screenshot_menu_item.set_submenu(screenshot_submenu);
        tray_menu.append(screenshot_menu_item);
        
        // Choose File menu item
        var choose_file_item = new Gtk.MenuItem.with_label("Choose File");
        choose_file_item.activate.connect(() => {
            print("Choose File selected from tray menu\n");
            MainWindow? main_win = null;
            get_label_only (out main_win);
            tesseract_trigger.accept_files_fromchooser (main_win);
        });
        tray_menu.append(choose_file_item);

        // Get from Clipboard menu item
        var clipboard_item = new Gtk.MenuItem.with_label("Get from Clipboard");
        clipboard_item.activate.connect(() => {
            print("Get from Clipboard selected from tray menu\n");
            MainWindow? main_win = null;
            var label = get_label_only (out main_win);
            if (main_win != null && !main_win.visible) {
                label = new Gtk.Label ("");
            }
            tesseract_trigger.start_tess_process.begin(label, "clip");
        });
        tray_menu.append(clipboard_item);
        
        // Separator
        var separator2 = new Gtk.SeparatorMenuItem();
        tray_menu.append(separator2);
        
        // Save options submenu
        var save_menu_item = new Gtk.MenuItem.with_label("Save Options");
        var save_submenu = new Gtk.Menu();
        
        var save_docs_item = new Gtk.MenuItem.with_label("Save to Documents");
        save_docs_item.activate.connect(() => {
            print("Save to Documents selected from tray menu\n");
            tesseract_trigger.save_to_documents();
        });
        save_submenu.append(save_docs_item);
        
        var save_images_item = new Gtk.MenuItem.with_label("Save to Images");
        save_images_item.activate.connect(() => {
            print("Save to Images selected from tray menu\n");
            tesseract_trigger.save_to_images();
        });
        save_submenu.append(save_images_item);
        
        var copy_clipboard_item = new Gtk.MenuItem.with_label("Copy to Clipboard");
        copy_clipboard_item.activate.connect(() => {
            print("Copy to Clipboard selected from tray menu\n");
            tesseract_trigger.copy_to_clipboard();
        });
        save_submenu.append(copy_clipboard_item);
        
        save_menu_item.set_submenu(save_submenu);
        tray_menu.append(save_menu_item);
        
        // Separator
        var separator3 = new Gtk.SeparatorMenuItem();
        tray_menu.append(separator3);
        
        // Language submenu
        var lang_menu_item = new Gtk.MenuItem.with_label("Language");
        var lang_submenu = new Gtk.Menu();
        
        var eng_item = new Gtk.MenuItem.with_label("English");
        eng_item.activate.connect(() => {
            print("English language selected from tray menu\n");
            LanguageButton.preferred_language = "eng";
        });
        lang_submenu.append(eng_item);
        
        var rus_item = new Gtk.MenuItem.with_label("Russian");
        rus_item.activate.connect(() => {
            print("Russian language selected from tray menu\n");
            LanguageButton.preferred_language = "rus";
        });
        lang_submenu.append(rus_item);

        var rus_eng_item = new Gtk.MenuItem.with_label("Russian + English");
        rus_eng_item.activate.connect(() => {
            print("Russian + English language selected from tray menu\n");
            LanguageButton.preferred_language = "eng+rus";
        });
        lang_submenu.append(rus_eng_item);
        
        lang_menu_item.set_submenu(lang_submenu);
        tray_menu.append(lang_menu_item);
        
        // Separator
        var separator4 = new Gtk.SeparatorMenuItem();
        tray_menu.append(separator4);
        
        // Quit menu item
        var quit_item = new Gtk.MenuItem.with_label("Quit");
        quit_item.activate.connect(() => {
            print("Quit selected from tray menu\n");
            quit_requested();
        });
        tray_menu.append(quit_item);
        
        tray_menu.show_all();
    }
    
    public void set_visible(bool visible) {
        if (status_icon != null) {
            // Only set visible on X11 or if the icon is embedded on Wayland
            if (!is_wayland || status_icon.is_embedded()) {
                status_icon.set_visible(visible);
            }
        }
    }

    public bool get_visible() {
        if (status_icon != null) {
            return status_icon.get_visible();
        }
        return false;
    }

    public bool is_available() {
        // Return whether tray icon functionality is available
        // On Wayland systems with default backend, tray icons are typically not supported
        // But if GDK_BACKEND is set to x11, we should try to use tray icon anyway
        var session_type = Environment.get_variable("XDG_SESSION_TYPE");
        var gdk_backend = Environment.get_variable("GDK_BACKEND");
        
        // Consider as Wayland only if we're actually running on Wayland AND GDK_BACKEND is not set to x11
        bool truly_wayland = (session_type != null && session_type.down().contains("wayland")) &&
                             (gdk_backend == null || !gdk_backend.down().contains("x11"));
        
        if (truly_wayland) {
            return false;
        }
        
        // If status_icon exists, consider it available even if not embedded
        // Some systems may support tray icons even if is_embedded() returns false
        return status_icon != null;
    }
}