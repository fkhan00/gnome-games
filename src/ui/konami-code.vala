// This file is part of GNOME Games. License: GPLv3

private class Games.KonamiCode : Object {
#if VALA_0_42
	private const uint[] CODE_LOWER_KEYS = {
#else
	private const int[] CODE_LOWER_KEYS = {
#endif
		Gdk.Key.Up,
		Gdk.Key.Up,
		Gdk.Key.Down,
		Gdk.Key.Down,
		Gdk.Key.Left,
		Gdk.Key.Right,
		Gdk.Key.Left,
		Gdk.Key.Right,
		Gdk.Key.b,
		Gdk.Key.a,
	};

#if VALA_0_42
	private const uint[] CODE_UPPER_KEYS = {
#else
	private const int[] CODE_UPPER_KEYS = {
#endif
		Gdk.Key.Up,
		Gdk.Key.Up,
		Gdk.Key.Down,
		Gdk.Key.Down,
		Gdk.Key.Left,
		Gdk.Key.Right,
		Gdk.Key.Left,
		Gdk.Key.Right,
		Gdk.Key.B,
		Gdk.Key.A
	};

	private const int LAST_INDEX = 9;

	public signal void code_performed ();

	private uint current_index;
	private Gtk.EventControllerKey controller;

	public KonamiCode (Gtk.Widget widget) {
		controller = new Gtk.EventControllerKey ();
		controller.key_pressed.connect (on_key_pressed);
		widget.add_controller (controller);
	}

	public void reset () {
		current_index = 0;
	}

	private bool on_key_pressed (Gtk.EventControllerKey self, uint keyval, uint keycode, Gdk.ModifierType state) {
		if (keyval != CODE_LOWER_KEYS[current_index] &&
		    keyval != CODE_UPPER_KEYS[current_index]) {
			current_index = 0;

			return false;
		}

		if (current_index == LAST_INDEX) {
			current_index = 0;
			debug ("↑ ↑ ↓ ↓ ← → ← → B A performed.");
			code_performed ();

			return false;
		}

		current_index++;

		return false;
	}
}
