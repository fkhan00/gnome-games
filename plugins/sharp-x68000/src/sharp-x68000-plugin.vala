// This file is part of GNOME Games. License: GPL-3.0+.

private class Games.SharpX68000Plugin : Object, Plugin {
	private const string MIME_TYPE_DIM = "application/x-x68k-rom";
	private const string MIME_TYPE_XDF = "application/x-x68k-xdf-rom";

	public string[] get_mime_types () {
		return { MIME_TYPE_DIM, MIME_TYPE_XDF };
	}

	public UriGameFactory[] get_uri_game_factories () {
		var factory = new SharpX68000GameFactory ();

		return { factory };
	}
}

[ModuleInit]
public Type register_games_plugin (TypeModule module) {
	return typeof(Games.SharpX68000Plugin);
}
