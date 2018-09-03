// This file is part of GNOME Games. License: GPL-3.0+.

private class Games.DatabaseDescription : Object, Description {
	private DatabaseMetadata metadata;

	public DatabaseDescription (DatabaseMetadata metadata) {
		this.metadata = metadata;
		metadata.description_changed.connect (() => changed ());
	}

	public string get_description () {
		return metadata.get_description ();
	}
}
