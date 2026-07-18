public class CustomHeaderBar : Hdy.HeaderBar {
    private SaveOptionsButton? save_options_button = null;
    private Gtk.Widget? menu_button_widget = null;

    public void set_tesseract_trigger(TesseractTrigger trigger) {
        if (save_options_button != null) {
            // Remove the old save options button if it exists
            try {
                var children = this.get_children();
                foreach (var child in children) {
                    if (child is SaveOptionsButton) {
                        this.remove(child);
                    }
                }
            } catch (Error e) {
                // Silently handle removal errors
            }
        }

        try {
            save_options_button = new SaveOptionsButton(trigger);
            // Pack the save options button before the about button
            pack_end(save_options_button);
        } catch (Error e) {
            // Silently handle creation errors
        }
    }

    public CustomHeaderBar () {
        var language_button = new LanguageButton () ;
        var about_button = new AboutButton () ;
        get_style_context ().add_class ("default-decoration") ;
        get_style_context ().add_class ("flat") ;
        get_style_context ().add_class ("header") ;
        pack_start (language_button) ;
        pack_end (about_button) ;
        decoration_layout = "close:" ;
        title = "TextSnatcher" ;
        set_show_close_button (true) ;
    }
    
    public void add_menu_button(Gtk.Widget widget) {
        // Add a menu button to the header bar
        pack_end(widget);
        menu_button_widget = widget;
    }
    
    public void remove_menu_button() {
        if (menu_button_widget != null) {
            this.remove(menu_button_widget);
            menu_button_widget = null;
        }
    }
}
