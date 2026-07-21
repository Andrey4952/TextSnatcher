public class LanguageButton : Gtk.MenuButton {
    public static string preferred_language = "eng" ;
    private Gtk.Label lang_label ;

    public LanguageButton () {
        var box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 4) ;
        var icon = new Gtk.Image.from_icon_name ("preferences-desktop-locale", Gtk.IconSize.SMALL_TOOLBAR) ;
        lang_label = new Gtk.Label ("EN") ;
        box.add (icon) ;
        box.add (lang_label) ;
        box.show_all () ;
        this.add (box) ;

        var menu_list = new Gtk.Box (Gtk.Orientation.VERTICAL, 2) ;
        var scroll_view = new Gtk.ScrolledWindow (null, null) ;
        scroll_view.height_request = 190 ;
        scroll_view.width_request = 150 ;

        var popover = new Gtk.Popover (null) ;

        menu_list.add (create_lang_button ("English", "eng", popover)) ;
        menu_list.add (create_lang_button ("Russian", "rus+eng", popover)) ;
        menu_list.add (create_lang_button ("Chinese (Simplified)", "chi_sim", popover)) ;
        menu_list.add (create_lang_button ("Japanese", "jpn", popover)) ;
        menu_list.add (create_lang_button ("German", "deu", popover)) ;
        menu_list.add (create_lang_button ("French", "fra", popover)) ;
        menu_list.add (create_lang_button ("Spanish", "spa", popover)) ;
        menu_list.add (create_lang_button ("Dutch", "nld", popover)) ;
        menu_list.add (create_lang_button ("Turkish", "tur", popover)) ;
        menu_list.add (create_lang_button ("Arabic", "ara", popover)) ;
        menu_list.add (create_lang_button ("Indonesian", "ind", popover)) ;

        scroll_view.add (menu_list) ;
        scroll_view.show_all () ;
        popover.add (scroll_view) ;
        this.popover = popover ;

        preferred_language = load_config () ;
        update_ui_label (preferred_language) ;
    }

    private Gtk.Button create_lang_button (string label_text, string lang_code, Gtk.Popover popover) {
        var btn = new Gtk.Button.with_label (label_text) ;
        btn.relief = Gtk.ReliefStyle.NONE ;
        btn.xalign = 0 ;
        btn.get_style_context ().add_class ("flat") ;
        btn.clicked.connect (() => {
            set_active_language (lang_code, popover) ;
        }) ;
        return btn ;
    }

    private void set_active_language (string lang_code, Gtk.Popover? popover = null) {
        preferred_language = lang_code ;
        update_ui_label (lang_code) ;
        save_config (lang_code) ;
        if (popover != null) {
            popover.popdown () ;
        }
    }

    private void update_ui_label (string lang_code) {
        if (lang_code.contains ("rus")) {
            lang_label.label = "RU" ;
        } else if (lang_code == "deu") {
            lang_label.label = "DE" ;
        } else if (lang_code == "fra") {
            lang_label.label = "FR" ;
        } else if (lang_code == "spa") {
            lang_label.label = "ES" ;
        } else if (lang_code == "chi_sim") {
            lang_label.label = "ZH" ;
        } else if (lang_code == "jpn") {
            lang_label.label = "JA" ;
        } else if (lang_code == "ara") {
            lang_label.label = "AR" ;
        } else if (lang_code == "nld") {
            lang_label.label = "NL" ;
        } else if (lang_code == "tur") {
            lang_label.label = "TR" ;
        } else if (lang_code == "ind") {
            lang_label.label = "ID" ;
        } else {
            lang_label.label = "EN" ;
        }
    }

    private static string get_config_path () {
        return Environment.get_user_config_dir () + "/textsnatcher/config.ini" ;
    }

    private static void save_config (string lang) {
        try {
            string dir = Environment.get_user_config_dir () + "/textsnatcher" ;
            DirUtils.create_with_parents (dir, 0755) ;
            var keyfile = new KeyFile () ;
            keyfile.set_string ("Settings", "language", lang) ;
            string data = keyfile.to_data () ;
            FileUtils.set_data (get_config_path (), data.data) ;
        } catch (Error e) {
            print ("Failed to save config: %s\n", e.message) ;
        }
    }

    private static string load_config () {
        try {
            var keyfile = new KeyFile () ;
            if (keyfile.load_from_file (get_config_path (), KeyFileFlags.NONE)) {
                string l = keyfile.get_string ("Settings", "language") ;
                if (l != null && l.length > 0) return l ;
            }
        } catch (Error e) {}

        string? lang_env = Environment.get_variable ("LANG") ;
        string? language_env = Environment.get_variable ("LANGUAGE") ;
        string sys_lang = ((lang_env != null) ? lang_env : "") + ((language_env != null) ? language_env : "") ;

        if (sys_lang.contains ("ru") || sys_lang.contains ("RU")) return "rus+eng" ;
        if (sys_lang.contains ("de") || sys_lang.contains ("DE")) return "deu" ;
        if (sys_lang.contains ("fr") || sys_lang.contains ("FR")) return "fra" ;
        if (sys_lang.contains ("es") || sys_lang.contains ("ES")) return "spa" ;
        if (sys_lang.contains ("zh") || sys_lang.contains ("ZH")) return "chi_sim" ;
        if (sys_lang.contains ("ja") || sys_lang.contains ("JA")) return "jpn" ;

        return "eng" ;
    }
}
