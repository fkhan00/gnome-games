// This file is part of GNOME Games. License: GPLv3

private class Games.Atari7800 : Object, Plugin {
	private const string FINGERPRINT_PREFIX = "atari-7800";
	private const string MIME_TYPE = "application/x-atari-7800-rom";
	private const string MODULE_BASENAME = "libretro-atari-7800.so";
	private const bool SUPPORTS_SNAPSHOTTING = false;

	public GameSource get_game_source () throws Error {
		var query = new MimeTypeTrackerQuery (MIME_TYPE, game_for_uri);
		var connection = Tracker.Sparql.Connection.@get ();
		var source = new TrackerGameSource (connection);
		source.add_query (query);

		return source;
	}

	private static Game game_for_uri (string uri) throws Error {
		var uid = new FingerprintUid (uri, FINGERPRINT_PREFIX);
		var title = new FilenameTitle (uri);
		var icon = new DummyIcon ();
		var media = new GriloMedia (title, MIME_TYPE);
		var cover = new GriloCover (media, uid);
		var runner =  new RetroRunner (MODULE_BASENAME, uri, uid, SUPPORTS_SNAPSHOTTING);

		return new GenericGame (title, icon, cover, runner);
	}
}

[ModuleInit]
public Type register_games_plugin (TypeModule module) {
	return typeof(Games.Atari7800);
}
