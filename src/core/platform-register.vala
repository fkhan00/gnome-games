// This file is part of GNOME Games. License: GPL-3.0+.

private class Games.PlatformRegister : Object {
	private static PlatformRegister instance;
	private HashTable<string, Platform> platforms;

	private PlatformRegister () {
		platforms = new HashTable<string, Platform> (str_hash, str_equal);
	}

	public static PlatformRegister get_register () {
		if (instance == null)
			instance = new PlatformRegister ();

		return instance;
	}

	public void add_platform (Platform platform) {
		var platform_id = platform.get_id ();

		assert (!platforms.contains (platform_id));

		platforms[platform_id] = platform;
	}

	public Platform get_platform (string platform_id) {
		return platforms[platform_id];
	}

	public List<Platform> get_all_platforms () {
		var values = platforms.get_values ();
		var result = values.copy ();
		result.sort (Platform.compare);

		return result;
	}
}
