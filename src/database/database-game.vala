// This file is part of GNOME Games. License: GPL-3.0+.

private class Games.DatabaseGame : Object, Game {
	public string name {
		get { return game.name; }
	}

	private Database database;
	private Game game;
	private Uid uid;
	private Developer developer;
	private Description description;

	public DatabaseGame (Database database, Game game) {
		this.database = database;
		this.game = game;

		var metadata = database.get_metadata (game);

		uid = new DatabaseUid (metadata);
		developer = new DatabaseDeveloper (metadata);
		description = new DatabaseDescription (metadata);
	}

	public Uid get_uid () {
		return uid;
	}

	public Icon get_icon () {
		return game.get_icon ();
	}

	public Cover get_cover () {
		return game.get_cover ();
	}

	public ReleaseDate get_release_date () {
		return game.get_release_date ();
	}

	public Cooperative get_cooperative () {
		return game.get_cooperative ();
	}

	public Genre get_genre () {
		return game.get_genre ();
	}

	public Players get_players () {
		return game.get_players ();
	}

	public Developer get_developer () {
		return developer;
	}

	public Publisher get_publisher () {
		return game.get_publisher ();
	}

	public Description get_description () {
		return description;
	}

	public Rating get_rating () {
		return game.get_rating ();
	}

	public Platform get_platform () {
		return game.get_platform ();
	}

	public Runner get_runner () throws Error {
		return game.get_runner ();
	}
}
