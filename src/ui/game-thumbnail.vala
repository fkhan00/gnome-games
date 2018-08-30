// This file is part of GNOME Games. License: GPL-3.0+.

private class Games.GameThumbnail: Gtk.Bin {
	private const Gtk.CornerType[] right_corners = { Gtk.CornerType.TOP_RIGHT, Gtk.CornerType.BOTTOM_RIGHT };
	private const Gtk.CornerType[] bottom_corners = { Gtk.CornerType.BOTTOM_LEFT, Gtk.CornerType.BOTTOM_RIGHT };

	private const double EMBLEM_SCALE = 0.125;
	private const double ICON_SCALE = 0.75;

	private Uid _uid;
	public Uid uid {
		get { return _uid; }
		set {
			if (_uid == value)
				return;

			_uid = value;

			queue_draw ();
		}
	}

	private Icon _icon;
	public Icon icon {
		get { return _icon; }
		set {
			if (_icon == value)
				return;

			_icon = value;

			queue_draw ();
		}
	}

	private ulong cover_changed_id;
	private Cover _cover;
	public Cover cover {
		get { return _cover; }
		set {
			if (_cover == value)
				return;

			if (_cover != null)
				_cover.disconnect (cover_changed_id);

			_cover = value;

			if (_cover != null)
				cover_changed_id = _cover.changed.connect (invalidate_cover);

			invalidate_cover ();
		}
	}

	private bool tried_loading_cover;
	private Gdk.Texture? cover_cache;
	private int previous_cover_width;
	private int previous_cover_height;

	public struct DrawingContext {
		Gtk.Snapshot snapshot;
		Gtk.StyleContext style;
		int width;
		int height;
	}

	static construct {
		set_css_name ("gamesgamethumbnail");
	}

	public override void snapshot (Gtk.Snapshot snapshot) {
		var style = get_style_context ();
		var width = get_width ();
		var height = get_height ();

		DrawingContext context = {
			snapshot, style, width, height
		};

		if (icon == null)
			return;

		if (cover == null)
			return;

		var drawn = false;

		drawn = draw_cover (context);

		if (!drawn)
			drawn = draw_icon (context);

		// Draw the default thumbnail if no thumbnail have been drawn
		if (!drawn)
			draw_default (context);
	}

	public bool draw_icon (DrawingContext context) {
		var g_icon = icon.get_icon ();
		if (g_icon == null)
			return false;

		var texture = get_scaled_icon (context, g_icon, ICON_SCALE);
		if (texture == null)
			return false;

		draw_texture (context, texture);

		return true;
	}

	public bool draw_cover (DrawingContext context) {
		var texture = get_scaled_cover (context);
		if (texture == null)
			return false;

		var mask = get_mask (context);
		context.snapshot.push_rounded_clip (mask);

		draw_background (context);
		draw_texture (context, texture);

		context.snapshot.pop ();

		return true;
	}

	public void draw_default (DrawingContext context) {
		var texture = get_emblem_icon (context, "applications-games-symbolic", EMBLEM_SCALE);
		if (texture == null)
			return;

		draw_texture (context, texture);
	}

	private Gdk.Texture? get_emblem_icon (DrawingContext context, string icon_name, double scale) {
		Gdk.Pixbuf? emblem = null;

		var color = context.style.get_color ();

		var theme = Gtk.IconTheme.get_default ();
		var size = int.min (context.width, context.height) * scale;
		try {
			var icon_info = theme.lookup_icon (icon_name, (int) size, Gtk.IconLookupFlags.FORCE_SIZE);
			emblem = icon_info.load_symbolic (color);
		} catch (GLib.Error error) {
			warning (@"Unable to get icon “$icon_name”: $(error.message)");
			return null;
		}

		if (emblem == null)
			return null;

		return Gdk.Texture.for_pixbuf (emblem);
	}

	private Gdk.Texture? get_scaled_icon (DrawingContext context, GLib.Icon? icon, double scale) {
		if (icon == null)
			return null;

		var theme = Gtk.IconTheme.get_default ();
		var lookup_flags = Gtk.IconLookupFlags.FORCE_SIZE | Gtk.IconLookupFlags.FORCE_REGULAR;
		var size = int.min (context.width, context.height) * scale;
		var icon_info = theme.lookup_by_gicon (icon, (int) size, lookup_flags);
		Gdk.Pixbuf? pixbuf = null;

		if (icon_info == null)
			return null;

		try {
			pixbuf = icon_info.load_icon ();
		}
		catch (Error e) {
			warning (@"Couldn’t load the icon: $(e.message)\n");
			return null;
		}

		if (pixbuf == null)
			return null;

		return Gdk.Texture.for_pixbuf (pixbuf);
	}

	private Gdk.Texture? get_scaled_cover (DrawingContext context) {
		if (previous_cover_width != context.width) {
			previous_cover_width = context.width;
			cover_cache = null;
			tried_loading_cover = false;
		}

		if (previous_cover_height != context.height) {
			previous_cover_height = context.height;
			cover_cache = null;
			tried_loading_cover = false;
		}

		if (cover_cache != null)
			return cover_cache;

		var size = int.min (context.width, context.height);

		load_cover_cache_from_disk (context, size);
		if (cover_cache != null)
			return cover_cache;

		var g_icon = cover.get_cover ();
		if (g_icon == null)
			return null;

		var theme = Gtk.IconTheme.get_default ();
		var lookup_flags = Gtk.IconLookupFlags.FORCE_SIZE | Gtk.IconLookupFlags.FORCE_REGULAR;
		var icon_info = theme.lookup_by_gicon (g_icon, (int) size, lookup_flags);
		Gdk.Pixbuf? pixbuf = null;

		try {
			pixbuf = icon_info.load_icon ();
			save_cover_cache_to_disk (size, pixbuf);
		}
		catch (Error e) {
			warning (@"Couldn’t load the icon: $(e.message)\n");
		}

		if (pixbuf == null)
			return null;

		cover_cache = Gdk.Texture.for_pixbuf (pixbuf);

		return cover_cache;
	}

	private void load_cover_cache_from_disk (DrawingContext context, int size) {
		if (tried_loading_cover)
			return;

		tried_loading_cover = true;

		string cover_cache_path;
		try {
			cover_cache_path = get_cover_cache_path (size);
		}
		catch (Error e) {
			critical (e.message);

			return;
		}

		try {
			var file = File.new_for_path (cover_cache_path);
			cover_cache = Gdk.Texture.from_file (file);
		}
		catch (Error e) {
			debug (e.message);
		}
	}

	private void save_cover_cache_to_disk (int size, Gdk.Pixbuf? pixbuf) {
		if (pixbuf == null)
			return;

		Application.try_make_dir (Application.get_covers_cache_dir (size));
		var now = new GLib.DateTime.now_local ();
		var creation_time = now.to_string ();

		try {
			var cover_cache_path = get_cover_cache_path (size);
			pixbuf.save (cover_cache_path, "png",
			             "tEXt::Software", "GNOME Games",
			             "tEXt::Creation Time", creation_time.to_string (),
			             null);
		}
		catch (Error e) {
			critical (e.message);
		}
	}

	private string get_cover_cache_path (int size) throws Error {
		var dir = Application.get_covers_cache_dir (size);

		assert (uid != null);

		var uid = uid.get_uid ();

		return @"$dir/$uid.png";
	}

	private void invalidate_cover () {
		cover_cache = null;
		tried_loading_cover = false;
		queue_draw ();
	}

	private Gsk.RoundedRect get_mask (DrawingContext context) {
		Graphene.Rect bounds = {};
		bounds.init (0, 0, context.width, context.height);

		var border_radius = (int) context.style.get_property (Gtk.STYLE_PROPERTY_BORDER_RADIUS);

		Gsk.RoundedRect rect = {};
		rect.init_from_rect (bounds, border_radius);

		return rect;
	}

	private void draw_texture (DrawingContext context, Gdk.Texture texture) {
		var x_offset = (context.width - texture.width) / 2;
		var y_offset = (context.height - texture.height) / 2;

		Graphene.Rect bounds = {};
		bounds.init (x_offset, y_offset, texture.width, texture.height);

		context.snapshot.append_texture (texture, bounds);
	}

	private void draw_background (DrawingContext context) {
		Graphene.Rect bounds = {};
		bounds.init (0, 0, context.width, context.height);

		Gdk.RGBA rgba = {0, 0, 0, 1};

		context.snapshot.append_color (rgba, bounds);
	}
}
