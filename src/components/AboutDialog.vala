class TsAboutDialog : Gtk.AboutDialog {
    construct {
        set_destroy_with_parent (true) ;
        set_modal (true) ;

        artists = null ;
        authors = { "Solai Raj (RajSolai)", "Andrey4952 (github.com/Andrey4952)" } ;
        documenters = null ;
        translator_credits = null ;
        logo_icon_name = "com.github.rajsolai.textsnatcher" ;

        program_name = "TextSnatcher" ;
        comments = "Snatch Text from Images with Ease\nWayland (grim+slurp), COSMIC Tray & Dual Russian+English OCR" ;
        copyright = "Copyright 2021-Today Solai Raj, Andrey4952" ;
        version = "2.1.0" ;

        license_type = Gtk.License.GPL_3_0 ;
        wrap_license = true ;

        website = "https://github.com/Andrey4952/TextSnatcher" ;
        website_label = "Star TextSnatcher on GitHub!" ;

        response.connect ((response_id) => {
            if (response_id == Gtk.ResponseType.CANCEL || response_id == Gtk.ResponseType.DELETE_EVENT) {
                hide () ;
            }
        }) ;

        present () ;
    }
}
