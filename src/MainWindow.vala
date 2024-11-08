/*
* Copyright © 2018–2021 Cassidy James Blaede (https://cassidyjames.com)
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
* Authored by: Cassidy James Blaede <c@ssidyjam.es>
*/
public class MainWindow : Gtk.Window {
    private Gtk.Entry entry;
    private bool is_terminal = Posix.isatty(Posix.STDIN_FILENO);

    public MainWindow(Gtk.Application application) {
        Object(
            application: application,
            height_request: 580,
            icon_name: "com.github.cassidyjames.ideogram",
            resizable: false,
            skip_taskbar_hint: true,
            title: _("Ideogram"),
            width_request: 580,
            window_position: Gtk.WindowPosition.CENTER_ALWAYS
        );
    }

    construct {
        get_style_context().add_class("ideogram");

        stick();
        set_keep_above(true);

        entry = new Gtk.Entry();
        entry.halign = Gtk.Align.CENTER;
        entry.width_request = entry.height_request = 0;
        entry.get_style_context().add_class("hidden");

        var title = new Gtk.Label(_("Select Emoji to Insert"));
        title.get_style_context().add_class(Granite.STYLE_CLASS_H1_LABEL);

        var copy = new Gtk.Label(_("Selecting will copy the emoji to the clipboard. Press Ctrl+V to paste."));
        copy.max_width_chars = 50;
        copy.wrap = true;

        var fake_window = new Gtk.Grid();
        fake_window.halign = Gtk.Align.CENTER;
        fake_window.row_spacing = 12;
        fake_window.valign = Gtk.Align.END;
        fake_window.get_style_context().add_class("fake-window");

        fake_window.attach(title, 0, 0);
        fake_window.attach(copy, 0, 1);

        var grid = new Gtk.Grid();
        grid.halign = Gtk.Align.CENTER;
        grid.valign = Gtk.Align.END;

        grid.attach(entry, 0, 0);
        grid.attach(fake_window, 0, 1);

        add(grid);
        entry.grab_focus();

        entry.changed.connect(() => {
            insert_emoji(entry.text);
        });

        if (is_terminal == false) {
            entry.focus_in_event.connect(() => {
                queue_close();
                return false;
            });

            focus_out_event.connect((event) => {
                queue_close();
                return Gdk.EVENT_STOP;
            });
        }
    }

    public override void map() {
        base.map();
        entry.insert_emoji();
    }

    private void insert_emoji(string emoji) {
        var clipboard = Gtk.Clipboard.get_for_display(
            get_display(),
            Gdk.SELECTION_CLIPBOARD
        );
        clipboard.set_text(emoji, -1);
        queue_close();
    }

    private void queue_close() {
        hide();
        Timeout.add(500, () => {
            close();
            return false;
        });
    }
}
