public class SaveOptionsButton : Gtk.MenuButton {
    private TesseractTrigger tesseract_trigger;
    
    public SaveOptionsButton (TesseractTrigger trigger) {
        tesseract_trigger = trigger;
        
        Object (
            image: new Gtk.Image.from_icon_name ("document-save", Gtk.IconSize.SMALL_TOOLBAR),
            tooltip_text: "Save Options"
        );
        
        var menu_list = new Gtk.Box (Gtk.Orientation.VERTICAL, 5);
        var scroll_view = new Gtk.ScrolledWindow (null, null);
        scroll_view.height_request = 150;
        scroll_view.width_request = 180;
        
        var save_to_docs = new Gtk.ModelButton();
        var save_to_images = new Gtk.ModelButton();
        var save_to_clipboard = new Gtk.ModelButton();
        
        save_to_docs.text = "Save to Documents";
        save_to_images.text = "Save to Images";
        save_to_clipboard.text = "Copy to Clipboard";
        
        save_to_docs.clicked.connect(() => {
            tesseract_trigger.save_to_documents();
        });
        
        save_to_images.clicked.connect(() => {
            tesseract_trigger.save_to_images();
        });
        
        save_to_clipboard.clicked.connect(() => {
            tesseract_trigger.copy_to_clipboard();
        });
        
        menu_list.add(save_to_docs);
        menu_list.add(save_to_images);
        menu_list.add(save_to_clipboard);
        
        scroll_view.add(menu_list);
        scroll_view.show_all();
        var popover = new Gtk.Popover(null);
        popover.add(scroll_view);
        this.popover = popover;
    }
}