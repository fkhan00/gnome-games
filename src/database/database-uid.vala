// This file is part of GNOME Games. License: GPL-3.0+.

private class Games.DatabaseUid : Object, Uid {
	private DatabaseMetadata metadata;

	public DatabaseUid (DatabaseMetadata metadata) {
		this.metadata = metadata;
	}

	public string get_uid () {
		return metadata.get_uid ();
	}
}
