using GLib;
using Gtk;
using AppIndicator;

/**
 * CosmicTray — panel indicator for COSMIC / Wayland.
 *
 * Delegates the StatusNotifierItem + dbusmenu export to
 * libayatana-appindicator (the GTK equivalent of AyuGram's
 * QDBusMenuExporter). It takes a plain Gtk.Menu and exports it
 * over D-Bus via libdbusmenu-glib.
 *
 * libayatana-appindicator registers the SNI ITSELF (in both the kde
 * StatusNotifierWatcher and COSMIC's own watcher). We must NOT register
 * manually with a generated service id — that creates a dangling entry
 * whose SNI object lives on a different connection, which makes the
 * right-click menu stop appearing. We also must NOT unregister with a
 * guessed id (APP_ID or a fresh unique name); instead we read the
 * watcher's list, find the entry belonging to OUR process (by matching
 * the resolved PID), and unregister exactly that entry.
 */

public class CosmicTray : Object {
    public const string APP_ID = "com.github.rajsolai.textsnatcher";

    private AppIndicator.Indicator indicator;
    private TesseractTrigger trigger;
    private weak Gtk.Application app;

    public CosmicTray (TesseractTrigger trigger, Gtk.Application app) {
        this.trigger = trigger;
        this.app = app;
    }

    public void register () {
        indicator = new AppIndicator.Indicator (
            "textsnatcher",
            "edit-paste",
            AppIndicator.IndicatorCategory.APPLICATION_STATUS);
        indicator.set_status (AppIndicator.IndicatorStatus.ACTIVE);
        indicator.set_title ("TextSnatcher");
        indicator.set_menu (build_menu ());
        // libayatana-appindicator registers the SNI itself in both watchers.
    }

    public void unregister () {
        // Hide the icon immediately so even if the explicit unregister below
        // somehow misses, the icon is not visibly lingering.
        if (indicator != null) {
            indicator.set_status (AppIndicator.IndicatorStatus.PASSIVE);
        }
        try {
            var conn = Bus.get_sync (BusType.SESSION);
            string[] watchers = {
                "org.kde.StatusNotifierWatcher",
                "com.system76.CosmicStatusNotifierWatcher"
            };
            string our_uname = conn.get_unique_name ();
            foreach (string w in watchers) {
                Variant? items_v = null;
                try {
                    var r = conn.call_sync (w, "/StatusNotifierWatcher",
                        "org.freedesktop.DBus.Properties", "Get",
                        new Variant ("(ss)", "org.kde.StatusNotifierWatcher",
                                     "RegisteredStatusNotifierItems"),
                        new VariantType ("(v)"), DBusCallFlags.NONE, -1, null);
                    items_v = r.get_child_value (0);
                } catch (Error e) {
                    continue;
                }
                if (items_v == null) continue;
                Variant items = items_v.get_variant ();   // "as"
                for (uint i = 0; i < items.n_children (); i++) {
                    string item = items.get_child_value (i).get_string ();
                    if (!item.contains ("textsnatcher")) continue;
                    // item format: "<unique_name>/org/ayatana/NotificationItem/textsnatcher"
                    string uname = item.split ("/")[0];
                    if (uname == our_uname) {
                        conn.call_sync (w, "/StatusNotifierWatcher",
                            "org.kde.StatusNotifierWatcher",
                            "UnregisterStatusNotifierItem",
                            new Variant ("(s)", item),
                            null, DBusCallFlags.NONE, -1, null);
                    }
                }
            }
        } catch (Error e) { }
        indicator = null;
    }

    private Gtk.Menu build_menu () {
        var menu = new Gtk.Menu ();

        menu.append (item_with_action ("Take Screenshot", "camera-photo", "screenshot_sel"));

        menu.append (item_with_action ("Choose File", "document-open", "file"));
        menu.append (item_with_action ("Get from Clipboard", "edit-paste", "clipboard"));
        menu.append (new Gtk.SeparatorMenuItem ());

        menu.append (item_with_action ("Show Window", "window-maximize", "show"));
        menu.append (item_with_action ("Hide Window", "window-minimize", "hide"));
        menu.append (item_with_action ("Quit", "application-exit", "quit"));

        menu.show_all ();
        return menu;
    }

    private Gtk.MenuItem item_with_action (string label, string? icon_name, string action) {
        Gtk.MenuItem item;
        if (icon_name != null) {
            var image = new Gtk.Image.from_icon_name (icon_name, Gtk.IconSize.MENU);
            item = new Gtk.ImageMenuItem.with_label (label);
            (item as Gtk.ImageMenuItem).set_image (image);
            (item as Gtk.ImageMenuItem).set_always_show_image (true);
        } else {
            item = new Gtk.MenuItem.with_label (label);
        }
        item.activate.connect (() => invoke_action (action));
        return item;
    }

    private Gtk.Label present_and_get_label (out MainWindow? main_win) {
        main_win = null;
        Gtk.Label label = new Gtk.Label ("");
        if (app != null) {
            foreach (var w in app.get_windows ()) {
                w.present ();
                if (w is MainWindow) {
                    main_win = (MainWindow) w;
                    label = main_win.get_title_label ();
                }
            }
        }
        return label;
    }

    // Returns the status label without raising the window.
    // Use this for screenshot / clipboard / file actions so the window
    // stays hidden when the user triggered the action from the tray.
    private Gtk.Label get_label_only (out MainWindow? main_win) {
        main_win = null;
        Gtk.Label label = new Gtk.Label ("");
        if (app != null) {
            foreach (var w in app.get_windows ()) {
                if (w is MainWindow) {
                    main_win = (MainWindow) w;
                    label = main_win.get_title_label ();
                }
            }
        }
        return label;
    }

    private void invoke_action (string action) {
        MainWindow? main_win = null;
        if (action == "screenshot_sel") {
            // Use get_label_only() — do NOT present the window before the screenshot.
            // present_and_get_label() would raise the window and cover the area
            // the user is trying to select (especially on a second monitor).
            var label = get_label_only (out main_win);
            trigger.start_tess_process.begin (label, "shot", (obj, res) => {});
        } else if (action == "file") {
            get_label_only (out main_win);
            trigger.accept_files_fromchooser (main_win);
        } else if (action == "clipboard") {
            var label = get_label_only (out main_win);
            trigger.start_tess_process.begin (label, "clip", (obj, res) => {});
        } else if (action == "show") {
            // Explicit "Show Window" — present() is intentional here.
            if (app != null) foreach (var w in app.get_windows ()) { w.present (); }
        } else if (action == "hide") {
            if (app != null) foreach (var w in app.get_windows ()) { w.hide (); }
        } else if (action == "quit") {
            Idle.add (() => {
                this.unregister ();
                Process.exit (0);
                return false;
            });
        }
    }
}
