// This file is part of GNOME Games. License: GPL-3.0+.

public class Games.GriloCooperative : Object, Cooperative {
	private GriloMedia media;
	private bool cooperative;
	private bool resolving;

	public GriloCooperative (GriloMedia media) {
		this.media = media;
		media.resolved.connect (on_media_resolved);
		resolving = false;
	}

	public bool get_cooperative () {
		if (resolving)
			return cooperative;

		resolving = true;
		media.try_resolve_media ();

		return cooperative;
	}

	private void on_media_resolved () {
		var grl_media = media.get_media ();

		if (grl_media == null)
			return;

		var registry = Grl.Registry.get_default ();
		var metadata_key = registry.lookup_metadata_key ("coop");

		if (grl_media.length (metadata_key) == 0)
			return;

		var coop = grl_media.get_boolean (metadata_key);
		load_media_cooperative (coop);
	}

	private void load_media_cooperative (bool coop) {
		cooperative = coop;

		changed ();
	}
}
