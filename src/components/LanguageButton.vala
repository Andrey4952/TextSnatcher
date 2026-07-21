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

        var menu_list = new Gtk.Box (Gtk.Orientation.VERTICAL, 5) ;
        var scroll_view = new Gtk.ScrolledWindow (null, null) ;
        scroll_view.height_request = 190 ;
        scroll_view.width_request = 150 ;

        var spa = new Gtk.ModelButton () ;
        var eng = new Gtk.ModelButton () ;
        var chi_sim = new Gtk.ModelButton () ;
        var jpn = new Gtk.ModelButton () ;
        var rus = new Gtk.ModelButton () ;
        var fra = new Gtk.ModelButton () ;
        var ara = new Gtk.ModelButton () ;
        var nld = new Gtk.ModelButton () ; // Dutch Language is represented as nld
        var tur = new Gtk.ModelButton () ;
        var deu = new Gtk.ModelButton () ;
        var ind = new Gtk.ModelButton () ;

        deu.text = "German" ;
        nld.text = "Dutch" ;
        tur.text = "Turkish" ;
        eng.text = "English" ;
        spa.text = "Spanish" ;
        chi_sim.text = "Chinese (Simplified)" ;
        jpn.text = "Japanese" ;
        rus.text = "Russian" ;
        fra.text = "French" ;
        ara.text = "Arabic" ;
        ind.text = "Indonesian" ;

        var popover = new Gtk.Popover (null) ;

        deu.clicked.connect (() => { set_active_language ("deu", popover) ; }) ;
        eng.clicked.connect (() => { set_active_language ("eng", popover) ; }) ;
        chi_sim.clicked.connect (() => { set_active_language ("chi_sim", popover) ; }) ;
        jpn.clicked.connect (() => { set_active_language ("jpn", popover) ; }) ;
        fra.clicked.connect (() => { set_active_language ("fra", popover) ; }) ;
        rus.clicked.connect (() => { set_active_language ("rus+eng", popover) ; }) ;
        ara.clicked.connect (() => { set_active_language ("ara", popover) ; }) ;
        spa.clicked.connect (() => { set_active_language ("spa", popover) ; }) ;
        nld.clicked.connect (() => { set_active_language ("nld", popover) ; }) ;
        tur.clicked.connect (() => { set_active_language ("tur", popover) ; }) ;
        ind.clicked.connect (() => { set_active_language ("ind", popover) ; }) ;

        menu_list.add (eng) ;
        menu_list.add (rus) ;
        menu_list.add (chi_sim) ;
        menu_list.add (jpn) ;
        menu_list.add (deu) ;
        menu_list.add (fra) ;
        menu_list.add (spa) ;
        menu_list.add (nld) ;
        menu_list.add (tur) ;
        menu_list.add (ara) ;
        menu_list.add (ind) ;

        scroll_view.add (menu_list) ;
        scroll_view.show_all () ;
        popover.add (scroll_view) ;
        this.popover = popover ;

        preferred_language = load_config () ;
        update_ui_label (preferred_language) ;
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
        return "eng" ;
    }
}
