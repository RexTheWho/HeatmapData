extends Node


# Description: Database for character information and per-level tweaks.
# Mechanics: update character database to level id.
# Bugs: TBA.

const heister_ids = [
	"dallas", "chains", "wolf", "houston", "wick", "hoxton",
	"clover", "dragan", "jacker", "bonnie", "sokol", "jiro",
	"bodhi", "jimmy", "sydney", "rust", "scarface", "sangres",
	"joy", "duke", "ethan", "hila"
]

const characters = {
	# Start of heisters
	russian = "dallas",
	german = "wolf",
	spanish = "chains",
	american = "houston",
	old_hoxton = "hoxton",
	jowi = "wick",
	dragon = "jiro",
	chico = "scarface",
	max = "sangres",
	myh = "duke",
	wild = "rust",
	ecp_female = "hila",
	ecp_male = "ethan",
	female_1 = "clover",
	robbers_safehouse = "heister",
	old_hoxton_mission = "hoxton",
	# End of heisters
	# Start of civilians
	civilian_female = "civilian",
	civilian_mariachi = "civilian",
	bank_manager = "civilian",
	boris = "civilian",
	# End of civilians
	# Start of enemies
	heavy_swat_sniper = "sniper",
	gensec = "security",
	security_undominatable = "security",
	mute_security_undominatable = "security",
	security_mex = "security",
	security_mex_no_pager = "security",
	biker = "gangster",
	biker_escape = "gangster",
	mobster = "gangster",
	bolivian = "gangster",
	bolivian_indoors = "gangster",
	bolivian_indoors_mex = "gangster",
	triad = "gangster",
	cop_scared = "cop",
	cop_female = "cop",
	fbi = "cop",
	swat = "swat_light",
	fbi_swat = "swat_light",
	city_swat  = "swat_light",
	heavy_swat = "swat_heavy",
	fbi_heavy_swat = "swat_heavy",
	phalanx_minion = "captain_shield",
	phalanx_vip = "captain_winters",
}

const misc_icons = {
	none = "generic",
	special_person = "person",
}

const character_classes = {
	none = {
		trail = 5
	},
	civilian = {
		trail = 6
	},
	hostage_important = {
		trail = -1
	},
}

const peer_colors = [
	Color( 0.760784, 0.988235, 0.592157, 1.0 ), # Host Green
	Color( 0.470588, 0.717647, 0.8, 1.0 ), # Client 1
	Color( 0.698039, 0.407843, 0.34902, 1.0 ), # Client 2
	Color( 0.8, 0.631373, 0.4, 1.0 ), # Client 3
	Color( 0.2, 0.8, 1, 1.0 ), # Client Bot Blue
	Color( 1.0, 0.35, 0.45, 1.0 ), # Enemy
	Color( 0.9, 0.65, 0.30, 1.0 ), # Neutral
]


const unique_cases = {
	rvd1 = {
		characters = {
			old_hoxton_mission = "resdoge",
			escort_undercover = "resdoge",
		},
	},
	rvd2 = {
		characters = {
			old_hoxton_mission = "resdoge",
			civilian = "resdoge",
		},
	},
	cane = {
		characters = {
			civilian = "elf",
		},
	},
	berry = {
		characters = {
			old_hoxton_mission = "locke",
		},
	},
	bph = {
		characters = {
			drunk_pilot = "bain",
			old_hoxton_mission = "bain",
			robbers_safehouse = "kento",
		},
	},
	des = {
		characters = {
			robbers_safehouse = "kento",
			civilian = "meth_cook",
		},
	},
	rat = {
		characters = {
			civilian = "meth_cook",
		},
	},
	alex1 = {
		characters = {
			civilian = "meth_cook",
		},
	},
}


var custom_overrides = {}


const skirmishes = {
	characters = {
		civilian = "hostage_important",
	},
}


var chardb = {}


func _ready():
	load_db_overrides()
	update_char_db()


const overrides_path = "C:/Program Files (x86)/Steam/steamapps/common/PAYDAY 2/mods/HeatmapData/db_overrides"
var override_folders:PoolStringArray
func load_db_overrides():
	var file:File = File.new()
	override_folders = get_override_directories(overrides_path)


func get_override_directories(dir:String):
	var directory:Directory = Directory.new()
	var contents:PoolStringArray = []
	if directory.open(dir) == OK:
		directory.list_dir_begin()
		var file_name = directory.get_next()
		while file_name != "":
			if directory.current_is_dir() and not file_name in [".", ".."]:
				if directory.file_exists( dir + "/" + file_name + "/database.json" ):
					print("CharDB: Found valid database file (" + dir + "/" + file_name + ")")
					contents.append(dir + "/" + file_name)
			file_name = directory.get_next()
	return contents


func update_char_db(level_id = "", contractor_id = ""):
	chardb = {
		heisters = heister_ids,
		characters = characters,
		character_classes = character_classes,
		peer_colors = peer_colors,
		misc_icons = misc_icons,
	}
	_unique_cases_tweak(level_id)
	if contractor_id == "skirmish":
		_skirmish_tweak()
	if override_folders:
		_override_cases()


func _unique_cases_tweak(level_id):
	if unique_cases.has(level_id) and !unique_cases[level_id].empty():
		prints("CharBD:", level_id, "has unique cases! applying!")
		for group in unique_cases[level_id]:
			for mod in unique_cases[level_id][group]:
				if chardb[group].has(mod):
					prints("CharDB: replacing", chardb[group][mod], "with", unique_cases[level_id][group][mod])
				else:
					prints("CharDB: adding", mod, "=" , unique_cases[level_id][group][mod])
				chardb[group][mod] = unique_cases[level_id][group][mod]
	else:
		print("CharDB: No unique cases need to be applied or they were possibly missing!")


func _override_cases():
	for i in override_folders:
		var json_file:File = File.new()
		var path = i + "/database.json"
		print(path)
		if json_file.open(path, File.READ) == OK:
			var json = JSON.parse(json_file.get_as_text()).result
			print(json)


func _skirmish_tweak():
	prints("CharBD: has holdout tag! applying holdout data!")
	for group in skirmishes:
		for mod in skirmishes[group]:
			if chardb[group].has(mod):
				prints("CharDB: replacing", chardb[group][mod], "with", skirmishes[group][mod])
			else:
				prints("CharDB: adding", mod, "=" , skirmishes[group][mod])
			chardb[group][mod] = skirmishes[group][mod]


func is_heister(char_id):
	return chardb.heisters.has(char_id)


func is_civilian(char_id):
	return char_id == "civilian"
