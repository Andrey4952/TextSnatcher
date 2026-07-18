public class MainWindow : Hdy.ApplicationWindow {
    private MainScreen? main_screen_instance = null;
    private CustomHeaderBar? header_bar_instance = null;

    public MainWindow (Gtk.Application app) {
        Logger.info("Creating MainWindow");
        var window_handle = new Hdy.WindowHandle () ;
        var window_box = new Gtk.Box (Gtk.Orientation.VERTICAL, 0) ;
        header_bar_instance = new CustomHeaderBar () ;
        main_screen_instance = new MainScreen (header_bar_instance) ;
        var main_screen = main_screen_instance;
        default_height = 150 ;
        default_width = 300 ;
        get_style_context ().add_class ("rounded") ;
        get_style_context ().add_class ("main-window") ;
        window_box.add (header_bar_instance) ;
        window_box.add (main_screen) ;
        window_handle.add (window_box) ;
        add (window_handle) ;
        show_all () ;
        Logger.info("MainWindow created and displayed");
    }

    construct {
        Logger.debug("Initializing Handy library");
        Hdy.init () ;

        // Keep the app resident: hide the window instead of destroying it on close.
        // The COSMIC panel indicator stays alive and can re-open the window.
        this.delete_event.connect (() => {
            // Allow the window to be destroyed so Gtk.Application can quit
            // and the tray (CosmicTray) gets a chance to unregister its
            // StatusNotifierItem on shutdown. Returning false lets the
            // default handler destroy the window.
            return false ;
        });
    }

    public TesseractTrigger? get_tesseract_trigger() {
        if (main_screen_instance != null) {
            return main_screen_instance.get_tesseract_trigger();
        }
        return null;
    }
    
    public CustomHeaderBar? get_header_bar() {
        return header_bar_instance;
    }
}
