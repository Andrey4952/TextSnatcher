# Design Document: Fix File Chooser and Clipboard OCR

## 1. Context & Goal
Fix file chooser intermittent opening and repair clipboard image extraction for OCR.

---

## 2. Technical Design

### A. Refactoring `accept_files_fromchooser()` (`TesseractTrigger.vala`)
Replace `Xdp.Portal.open_file` with `Gtk.FileChooserNative`:
```vala
public void accept_files_fromchooser () {
    var chooser = new Gtk.FileChooserNative (
        "Select an Image to perform OCR !",
        null,
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
        string lead_file = "\'" + filename + "\'" ;
        read_image.begin (lead_file, (obj, res) => {}) ;
    }
    chooser.destroy () ;
}
```

### B. Repairing `clipboard_callback()` (`TesseractTrigger.vala`)
Update `clipboard_callback` to save pixbuf synchronously and check for null:
```vala
void clipboard_callback (Gtk.Clipboard _, Gdk.Pixbuf? pixbuf) {
    if (pixbuf == null) {
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
            print ("Reading Image from Clipboard\n") ;
        }) ;
    } catch (Error err) {
        critical (err.message) ;
        if (label != null) {
            label.label = "Error Reading Image" ;
        }
    }
}
```

---

## 3. Risks & Verification
- `Gtk.FileChooserNative` automatically routes to Desktop Portals on Flatpak/Wayland and native GTK dialog under X11.
- `pixbuf.save()` guarantees completed disk writing before `read_image.begin()` executes Tesseract.
