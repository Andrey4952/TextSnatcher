public class MainWindow : Hdy.ApplicationWindow {
    private MainScreen main_screen ;

    public MainWindow (Gtk.Application app) {
        var window_handle = new Hdy.WindowHandle () ;
        var window_box = new Gtk.Box (Gtk.Orientation.VERTICAL, 0) ;
        main_screen = new MainScreen () ;
        var header_bar = new CustomHeaderBar () ;
        default_height = 150 ;
        default_width = 300 ;
        get_style_context ().add_class ("rounded") ;
        get_style_context ().add_class ("main-window") ;
        window_box.add (header_bar) ;
        window_box.add (main_screen) ;
        window_handle.add (window_box) ;
        add (window_handle) ;
        delete_event.connect (() => {
            return hide_on_delete () ;
        }) ;
        show_all () ;
    }

    construct {
        Hdy.init () ;
    }

    public TesseractTrigger get_tesseract_trigger () {
        return main_screen.get_tesseract_trigger () ;
    }

    public Gtk.Label get_title_label () {
        return main_screen.get_title_label () ;
    }
}
