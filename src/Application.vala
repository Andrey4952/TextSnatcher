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
    TrayIcon? tray_icon = null;
    CosmicTray? cosmic_tray = null;

    public Application () {
        Object (
            application_id: "com.github.rajsolai.textsnatcher",
            flags : ApplicationFlags.FLAGS_NONE
        ) ;
    }

    protected override void activate () {
        Logger.info(@"Application activation started");

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
            Logger.debug("Granite settings detected, applying theme preferences");
            gtk_settings.gtk_application_prefer_dark_theme =
                granite_settings.prefers_color_scheme == Granite.Settings.ColorScheme.DARK ;

            granite_settings.notify["prefers-color-scheme"].connect (() => {
                Logger.debug("System theme preference changed");
                gtk_settings.gtk_application_prefer_dark_theme =
                    granite_settings.prefers_color_scheme == Granite.Settings.ColorScheme.DARK ;
            }) ;
        } else {
            Logger.warn("Granite settings not available, proceeding without theme detection");
        }

        main_window = new MainWindow (this) ;
        add_window (main_window) ;

        // Initialize tray icon or COSMIC alternative
        var tesseract_trigger = main_window.get_tesseract_trigger(); // Assuming MainWindow provides access to tesseract_trigger
        if (tesseract_trigger != null) {
            // Check if we're running on Wayland before creating tray icon
            var session_type = Environment.get_variable("XDG_SESSION_TYPE");
            var wayland_display = Environment.get_variable("WAYLAND_DISPLAY");
            var display_server = Environment.get_variable("DISPLAY");
            var gdk_backend = Environment.get_variable("GDK_BACKEND");
            var desktop_environment = Environment.get_variable("XDG_CURRENT_DESKTOP");

            // Check if running under COSMIC
            bool is_cosmic = desktop_environment != null && desktop_environment.down().contains("cosmic");

            // Consider as Wayland only if we're actually running on Wayland AND GDK_BACKEND is not set to x11
            bool is_wayland = ((session_type != null && session_type.down().contains("wayland")) ||
                              (wayland_display != null && wayland_display.has_prefix("wayland"))) &&
                             (gdk_backend == null || !gdk_backend.down().contains("x11"));

            Logger.info(@"Detected session type: $(session_type ?? "NULL")");
            Logger.info(@"Detected WAYLAND_DISPLAY: $(wayland_display ?? "NULL")");
            Logger.info(@"Detected DISPLAY: $(display_server ?? "NULL")");
            Logger.info(@"Detected GDK_BACKEND: $(gdk_backend ?? "NULL")");
            Logger.info(@"Detected XDG_CURRENT_DESKTOP: $(desktop_environment ?? "NULL")");
            Logger.info(@"COSMIC detection result: $(is_cosmic)");
            Logger.info(@"Wayland detection result: $(is_wayland)");

            if (is_cosmic) {
                Logger.info("Running on COSMIC desktop environment, creating panel indicator (StatusNotifierItem)");
                // COSMIC renders StatusNotifierItem icons in its panel. CosmicTray exports a
                // real, resident StatusNotifierItem over D-Bus with a full context menu.
                cosmic_tray = new CosmicTray(tesseract_trigger, this);
                cosmic_tray.register () ; // export SNI + dbusmenu over D-Bus
                // On a clean Gtk.Application shutdown, drop the SNI so it does
                // not linger as a phantom icon in the COSMIC panel.
                this.shutdown.connect (() => {
                    if (cosmic_tray != null) cosmic_tray.unregister () ;
                });
            } else if (is_wayland) {
                Logger.info("Running on Wayland with default backend, skipping tray icon initialization");
            } else {
                Logger.info("Running on X11 or tray icon supported environment (or GDK_BACKEND=x11 forced), initializing tray icon");
                tray_icon = new TrayIcon(tesseract_trigger);

                // Check if tray icon is actually available (may not be on some Wayland compositors)
                if (tray_icon.is_available()) {
                    Logger.info("Tray icon is available and initialized");
                    tray_icon.quit_requested.connect(() => {
                        Logger.info("Quit requested from tray icon");
                        this.quit();
                    });
                    tray_icon.open_requested.connect(() => {
                        Logger.info("Open requested from tray icon");
                        if (main_window != null) {
                            main_window.present();
                        }
                    });
                } else {
                    Logger.warn("Tray icon is not available on this platform");
                }
            }
        } else {
            Logger.warn("Could not get tesseract trigger for tray icon initialization");
        }

        Logger.info("Application activation completed");
    }

    public static int main (string[] args) {
        Logger.info(@"TextSnatcher application starting with $(args.length) arguments");
        var app = new Application () ;
        int result = app.run (args) ;
        // Clean up the tray SNI so it doesn't linger as a phantom icon.
        if (app.cosmic_tray != null) {
            app.cosmic_tray.unregister () ;
        }
        Logger.info(@"TextSnatcher application exiting with code $(result)");
        return result;
    }
}
