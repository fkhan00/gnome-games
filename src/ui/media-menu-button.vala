// This file is part of GNOME Games. License: GPL-3.0+.

[GtkTemplate (ui = "/org/gnome/Games/ui/media-menu-button.ui")]
private class Games.MediaMenuButton : Gtk.MenuButton {
	public MediaSet media_set { set; get; }

	[GtkCallback]
	private void on_media_set_changed () {
		if (media_set == null || media_set.get_size () < 2) {
			hide ();

			return;
		}

		icon_name = media_set.icon.to_string ();

		show ();
	}
}
