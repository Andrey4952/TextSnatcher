# Design Document: Fix Language Selection Menu Click Events

## 1. Context & Goal
Ensure clicking language menu items in `LanguageButton.vala` reliably updates `preferred_language`.

---

## 2. Technical Design (`LanguageButton.vala`)

Replace `Gtk.ModelButton` with a helper method returning `Gtk.Button`:
```vala
private Gtk.Button create_lang_button (string text, string code, Gtk.Popover popover) {
    var btn = new Gtk.Button.with_label (text) ;
    btn.relief = Gtk.ReliefStyle.NONE ;
    btn.xalign = 0 ;
    btn.get_style_context ().add_class ("flat") ;
    btn.clicked.connect (() => {
        set_active_language (code, popover) ;
    }) ;
    return btn ;
}
```

---

## 3. Risks & Verification
- `Gtk.Button` with `ReliefStyle.NONE` matches GTK3 flat popover menu styling.
- `.clicked` handler fires reliably on mouse click.
