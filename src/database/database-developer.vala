// This file is part of GNOME Games. License: GPL-3.0+.

private class Games.DatabaseDeveloper : Object, Developer {
	private DatabaseMetadata metadata;

	public DatabaseDeveloper (DatabaseMetadata metadata) {
		this.metadata = metadata;
		metadata.developer_changed.connect (() => changed ());
	}

	public string get_developer () {
		return metadata.get_developer ();
	}
}
