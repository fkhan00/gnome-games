// This file is part of GNOME Games. License: GPL-3.0+.

public class Games.GenericRating : Object, Rating {
	private float rating;

	public GenericRating (float rating) {
		this.rating = rating;
	}

	public float get_rating () {
		return rating;
	}
}
