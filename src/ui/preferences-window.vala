// This file is part of GNOME Games. License: GPL-3.0+.

[GtkTemplate (ui = "/org/gnome/Games/ui/preferences-window.ui")]
private class Games.PreferencesWindow : Gtk.Window {
	[GtkChild]
	private Hdy.Leaflet titlebar_box;
	[GtkChild]
	private Gtk.HeaderBar left_header_bar;
	[GtkChild]
	private Gtk.Separator header_separator;
	[GtkChild]
	private Hdy.Leaflet main_box;
	[GtkChild]
	private Gtk.Box sidebar_vbox;
	[GtkChild]
	private Gtk.Separator separator;
	[GtkChild]
	private Gtk.Stack stack;
	[GtkChild]
	private Gtk.SizeGroup content_size_group;

	private PreferencesBackButton back_button;

	private Gtk.HeaderBar _right_header_bar;
	public Gtk.HeaderBar right_header_bar {
		set {
			if (_right_header_bar != null) {
				_right_header_bar.remove (back_button);
				titlebar_box.remove (_right_header_bar);
				content_size_group.remove_widget (_right_header_bar);
			}
			if (value != null) {
				titlebar_box.add (value);
				content_size_group.add_widget (value);
				value.expand = true;
				value.show_close_button = !immersive_mode;

				back_button = new PreferencesBackButton ();
				back_button.clicked.connect (() => {
					main_box.visible_child = sidebar_vbox;
					titlebar_box.visible_child = left_header_bar;
				});
				var folded = main_box.get_fold () == Hdy.Fold.FOLDED;
				back_button.visible = folded;
				value.pack_start (back_button);
			}
			_right_header_bar = value;
		}
		get { return _right_header_bar; }
	}

	private bool _immersive_mode;
	public bool immersive_mode {
		set {
			header_separator.visible = !value;
			left_header_bar.visible = !value;
			separator.visible = !value;
			sidebar_vbox.visible = !value;
			if (right_header_bar != null)
				right_header_bar.show_close_button = !value;

			_immersive_mode = value;
		}
		get { return _immersive_mode; }
	}

	private Binding right_header_bar_binding;
	private Binding immersive_mode_binding;

	public PreferencesWindow () {
		stack.foreach ((child) => {
			var page = (PreferencesPage) child;
			stack.notify["visible-child-name"].connect (page.visible_page_changed);
		});
		stack.notify["visible-child-name"].connect (visible_child_changed);
		visible_child_changed ();
	}

	private void visible_child_changed () {
		var page = (PreferencesPage) stack.get_visible_child ();
		if (page == null) {
			right_header_bar = null;

			return;
		}
		right_header_bar_binding = page.bind_property ("header-bar", this, "right_header_bar",
		                                               BindingFlags.SYNC_CREATE);
		immersive_mode_binding = page.bind_property ("immersive-mode", this, "immersive-mode",
		                                             BindingFlags.SYNC_CREATE);

		var folded = main_box.get_fold () == Hdy.Fold.FOLDED;
		if (folded) {
			main_box.visible_child = stack;
			titlebar_box.visible_child = right_header_bar;
		}
	}

	[GtkCallback]
	private void main_box_notify_fold (GLib.Object    object,
	                                   GLib.ParamSpec paramSpec) {
		var folded = main_box.get_fold () == Hdy.Fold.FOLDED;

		left_header_bar.show_close_button = folded;
		back_button.visible = folded;
	}
}
