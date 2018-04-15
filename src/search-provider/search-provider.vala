// This file is part of GNOME Games. License: GPL-3.0+.

[DBus (name = "org.gnome.Shell.SearchProvider2")]
public class Games.SearchProvider : Object {
	private GameCollection game_collection;
	private HashTable<string, Game> games;

	[DBus (visible = false)]
	public signal void activate (uint32 timestamp, Game game);

	[DBus (visible = false)]
	public signal void run_search (uint32 timestamp, string[] terms);


	internal SearchProvider (GameCollection collection) {
		game_collection = collection;
		games = new HashTable<string, Game> (str_hash, str_equal);
	}

	private bool filter_by_game (string[] terms, Game game) {
		if (terms.length == 0)
			return true;

		foreach (var term in terms)
			if (!(term.casefold () in game.name.casefold ()))
				return false;

		return true;
	}

	public async string[] get_initial_result_set (string[] terms) throws GLib.Error {
		List<Game> collection_games = game_collection.get_games ();

		string[] results = {};
		foreach (var game in collection_games) {
			var uid = game.get_uid ().get_uid ();
			if (filter_by_game (terms, game)) {
				games[uid] = game;
				results += uid;
			}
		}

		return results;
	}

	public async string[] get_subsearch_result_set (string[] previous_results, string[] terms) throws GLib.Error {
		if (previous_results.length == 0)
			return yield get_initial_result_set (terms);

		string[] results = {};
		foreach (var uid in previous_results) {
			var game = games[uid];
			if (filter_by_game (terms, game))
				results += uid;
		}

		return results;
	}

	public async HashTable<string, Variant>[] get_result_metas (string[] results) throws GLib.Error {
		var result = new GenericArray<HashTable<string, Variant>> ();

		foreach (var uid in results) {
			var game = games[uid];
			var gicon = game.get_cover ().get_cover ();

			var metadata = new HashTable<string, Variant> (str_hash, str_equal);

			metadata.insert ("id", uid);
			metadata.insert ("name", game.name);
			if (gicon != null)
				metadata.insert ("icon", gicon.serialize ());
//			metadata.insert ("description", "TODO");

			result.add (metadata);
		}

		return result.data;
	}

	public void activate_result (string uid, string[] terms, uint32 timestamp) throws GLib.Error {
		var game = games[uid];

		activate (timestamp, game);
	}

	public void launch_search (string[] terms, uint32 timestamp) throws GLib.Error {
		run_search (timestamp, terms);
	}
}

