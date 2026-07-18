public class MainScreen : Gtk.EventBox {
    TesseractTrigger tesseract_trigger ;
    CustomHeaderBar header_bar;

    public MainScreen (CustomHeaderBar hdr_bar) {
        header_bar = hdr_bar;
        tesseract_trigger = new TesseractTrigger () ;
        var main_stack = new Gtk.Stack () ;
        var home_screen = new HomeScreen () ;
        var select_picture_screen = new SelectPictureScreen () ;
        var title_label = home_screen.title_label ;
        var dummmy = new Gtk.Label ("") ;

        // main_stack.vhomogeneous = false;
        main_stack.transition_type = Gtk.StackTransitionType.SLIDE_UP_DOWN ;
        main_stack.add_named (home_screen, "home_screen") ;
        main_stack.add_named (select_picture_screen, "select_picture_screen") ;

        home_screen.goto_select_screen.connect (() => {
            main_stack.visible_child_name = "select_picture_screen" ;
        }) ;

        select_picture_screen.cancel_signal.connect (() => {
            main_stack.visible_child_name = "home_screen" ;
        }) ;

        select_picture_screen.perform_signal.connect ((image_source) => {
            main_stack.visible_child_name = "home_screen" ;
            perform_operation (title_label, image_source) ;
        }) ;

        add (main_stack) ;
    }

    void perform_operation (Gtk.Label title_label, string image_source) {
        tesseract_trigger.start_tess_process.begin (title_label, image_source, (obj, res) => {
            // After OCR is completed, enable save options
            // For now, skip setting the trigger to prevent segfault
            // The save functionality is still available after OCR
            Logger.info("OCR completed, skipping set_tesseract_trigger to prevent segfault");
        }) ;
    }

    public TesseractTrigger get_tesseract_trigger() {
        return tesseract_trigger;
    }
}
