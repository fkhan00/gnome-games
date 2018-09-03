// This file is part of GNOME Games. License: GPL-3.0+.

private class Games.DatabaseMetadata : Object {
	private const string LOAD_QUERY = """
		SELECT developer FROM game_metadata WHERE uid=$UID;
	""";

	private const string ADD_GAME_QUERY = """
		INSERT OR IGNORE INTO game_metadata (uid) VALUES ($UID);
	""";

	private const string SAVE_DEVELOPER_QUERY = """
		UPDATE game_metadata SET developer=$DEVELOPER WHERE uid=$UID;
	""";

	public signal void developer_changed ();

	private Game game;
	private string uid;
	private string developer;
	private bool developer_loaded;

	private Sqlite.Statement add_game_statement;
	private Sqlite.Statement load_statement;
	private Sqlite.Statement save_developer_statement;

	public DatabaseMetadata (Sqlite.Database database, Game game) {
		this.game = game;

		try {
			add_game_statement = Database.prepare (database, ADD_GAME_QUERY);
			load_statement = Database.prepare (database, LOAD_QUERY);
			save_developer_statement = Database.prepare (database, SAVE_DEVELOPER_QUERY);

			uid = game.get_uid ().get_uid ();
			try_add_game ();

			load_metadata ();
		}
		catch (Error e) {
			warning (e.message);
		}
	}

	public string get_uid () {
		return uid;
	}

	public string get_developer () {
		if (!developer_loaded) {
			save_developer ();
			game.get_developer ().changed.connect (on_developer_changed);
		}

		return developer;
	}

	private void on_developer_changed () {
		save_developer ();

		developer_changed ();
	}

	private void save_developer () {
		try {
			developer = game.get_developer ().get_developer ();

			developer_loaded = true;

			if (developer == "")
				return;

			save_developer_statement.reset ();
			Database.bind_text (save_developer_statement, "$UID", uid);
			Database.bind_text (save_developer_statement, "$DEVELOPER", developer);

			if (save_developer_statement.step () != Sqlite.DONE)
				warning ("Execution failed.");
		}
		catch (Error e) {
			warning (e.message);
		}
	}

	private void try_add_game () throws Error {
		Database.bind_text (add_game_statement, "$UID", uid);

		if (add_game_statement.step () != Sqlite.DONE)
			warning ("Execution failed.");
	}

	private void load_metadata () throws Error {
		Database.bind_text (load_statement, "$UID", uid);

		if (load_statement.step () == Sqlite.ROW) {
			developer = load_statement.column_text (0);

			developer_loaded = developer != null;
		}
	}
}
