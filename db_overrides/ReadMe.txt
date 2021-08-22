
		--------------------------------------------
		THIS IS NON-FUNCTIONAL AT THIS CURRENT TIME!
				AND IS SUBJECT TO CHANGE!
				-------------------------

Database Overrides are loaded on startup and are used to fix issues with overhauls or custom heists having unique characters.

	*init_rank*
		...Is used to order your loading incase one mod tweaks another, higher numbers are applied later.
		
	*heisters*
		...Is used to add new heisters if you have custom ones or want to edit them.
		...IDs are integers for the order they were added to CharacterTweakdata.

	*characters_enemies*
		...Is used to override icons for enemies.
		...Example; "cop_mexican":"cop", "cop":"party_cop")

	*misc_icons*
		...Is used to set icons for various non-specific trackers like Lootbags, Deployables or Vehicles.

	*unique_cases*
		...Is used to override icons on a level.
		...Example;
			"custom_level_id": {
				"characters_enemies": {
					"civ": "civ_with_hat",
					"cop": "cop_alien",
				},
			}