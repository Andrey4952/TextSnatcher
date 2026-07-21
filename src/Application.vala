/*
 * Copyright (c) 2021 - Today Solai Raj (github.com/RajSolai)
 *
 * This program is free software; you can redistribute it and/or
 * modify it under the terms of the GNU General Public
 * License as published by the Free Software Foundation; either
 * version 2 of the License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * General Public License for more details.
 *
 * You should have received a copy of the GNU General Public
 * License along with this program; if not, write to the
 * Free Software Foundation, Inc., 51 Franklin Street, Fifth Floor,
 * Boston, MA 02110-1301 USA
 *
 * Authored by: Solai Raj <msraj085@gmail.com>
 */

public class Application : Gtk.Application {
    MainWindow main_window ;

    public Application () {
        Object (
            application_id: "com.github.rajsolai.textsnatcher",
            flags : ApplicationFlags.FLAGS_NONE
        ) ;
    }

    protected override void activate () {
        weak Gtk.IconTheme default_theme = Gtk.IconTheme.get_default () ;
        default_theme.add_resource_path ("/com/github/rajsolai/TextSnatcher") ;

        // stylesheet
        var provider = new Gtk.CssProvider () ;
        provider.load_from_resource ("/com/github/rajsolai/TextSnatcher/stylesheet.css") ;
        Gtk.StyleContext.add_provider_for_screen (
            Gdk.Screen.get_default (),
            provider,
            Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION
        ) ;

        var granite_settings = Granite.Settings.get_default () ;
        var gtk_settings = Gtk.Settings.get_default () ;

        if (granite_settings != null) {
            gtk_settings.gtk_application_prefer_dark_theme =
                granite_settings.prefers_color_scheme == Granite.Settings.ColorScheme.DARK ;

            granite_settings.notify["prefers-color-scheme"].connect (() => {
                gtk_settings.gtk_application_prefer_dark_theme =
                    granite_settings.prefers_color_scheme == Granite.Settings.ColorScheme.DARK ;
            }) ;
        }

        main_window = new MainWindow (this) ;
        add_window (main_window) ;

        var tesseract_trigger = main_window.get_tesseract_trigger () ;
        if (tesseract_trigger != null) {
            var session_type = Environment.get_variable ("XDG_SESSION_TYPE") ;
            var wayland_display = Environment.get_variable ("WAYLAND_DISPLAY") ;
            var gdk_backend = Environment.get_variable ("GDK_BACKEND") ;
            var desktop_environment = Environment.get_variable ("XDG_CURRENT_DESKTOP") ;

            bool is_cosmic = desktop_environment != null && desktop_environment.down ().contains ("cosmic") ;
            bool is_wayland = ((session_type != null && session_type.down ().contains ("wayland")) ||
                              (wayland_display != null && wayland_display.has_prefix ("wayland"))) &&
                             (gdk_backend == null || !gdk_backend.down ().contains ("x11")) ;

            if (is_cosmic || is_wayland) {
                var cosmic_tray = new CosmicTray (tesseract_trigger, this) ;
                cosmic_tray.register () ;
                this.shutdown.connect (() => {
                    cosmic_tray.unregister () ;
                }) ;
            } else {
                var tray_icon = new TrayIcon (tesseract_trigger) ;
                if (tray_icon.is_available ()) {
                    tray_icon.quit_requested.connect (() => {
                        this.quit () ;
                    }) ;
                    tray_icon.open_requested.connect (() => {
                        if (main_window != null) {
                            main_window.present () ;
                        }
                    }) ;
                }
            }
        }
    }

    public static int main (string[] args) {
        var app = new Application () ;
        return app.run (args) ;
    }
}
