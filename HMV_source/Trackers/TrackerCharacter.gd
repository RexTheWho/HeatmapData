extends Spatial

# Description: Main tracker node for Characters.
# Mechanics: set frametime // set character // set trail color // set index // remove tracker
# Bugs: (invert: "det == 0" is true) is driving me up the wall, not sure whats causing it.

signal missing_character(character_id)
signal status_update(status, duration)
signal stat_change(stat, value)

var characters = {}
var character_classes = {}

var tracker_index = 0
var character_id
var character_class = "none"

var frame_time = 1.0
var prep_for_removal = false


func _init():
	characters = CharDB.chardb["characters"]
	character_classes = CharDB.chardb["character_classes"]


func _ready():
	self.visible = false
	$Height/Status.connect_status_tracker(self)


func play_frame(frame_data:Array, ignore_interp:bool):
	if !prep_for_removal:
		var my_data
		for i in frame_data[tracker_index]:
			if str(i[0]) == str(character_id):
				my_data = i
				break
		
		if my_data:
			var pos = Vector3( my_data[1], my_data[3], -my_data[2] )/100
			var rot = Vector3( 0, my_data[4], 0 ) # Rotations need to be lerped properly!
			var dir_node = $Direction
			if abs(rot.y - dir_node.rotation_degrees.y) > 180:
				var dif = rot.y - dir_node.rotation_degrees.y
				rot.y -= dif
			
			if ignore_interp or !visible:
				visible = true
				translation = pos
				dir_node.rotation_degrees = rot
			else:
				var tween = $Tween
				var delay = frame_time
				if translation != pos:
					tween.interpolate_property( self, "translation", translation, pos, delay)
				if dir_node.rotation_degrees != rot:
					tween.interpolate_property( dir_node, "rotation_degrees", dir_node.rotation_degrees, rot, delay)
				tween.start()
		else:
			print("TrackerCharacter: Character ID " + str(character_id) + " no longer exists in frame data, Freeing.")
			emit_signal("missing_character", character_id)
			if get_parent().is_connected("next_frame", self, "play_frame"):
				get_parent().disconnect("next_frame", self, "play_frame")
			prep_for_removal = true
			$AnimationPlayer.play("removing")


func set_character(char_data):
	character_id = char_data[0]
	var tid = get_parent().get_header_character(char_data[-1])
	if characters.has(tid):
		character_class = characters[tid]
	else:
		character_class = tid
	
	Console.log(["TrackerCharacter: set character", character_id, character_class])
	
	var character_icon = "res://Textures/Characters/character_icon_{character_id}.png".format({"character_id":character_class})
	
	if CharDB.is_heister(character_class):
		$Hitbox.add_to_group("player")
		_add_player_hud()
		var player_index = get_parent().get_header_heister_index(character_class)
		Console.log(["????????????????????? PLAYER INDEX", player_index])
		set_trail_color(CharDB.chardb.peer_colors[clamp(player_index, 0, 4)])
	elif CharDB.is_civilian(character_class):
		$Hitbox.add_to_group("civilian")
		set_trail_color(CharDB.chardb.peer_colors[6])
	else:
		$Hitbox.add_to_group("enemy")
		set_trail_color(CharDB.chardb.peer_colors[5])
	
	var loaded_icon = load(character_icon)
	if !loaded_icon:
		push_warning("TrackerCharacter: " + character_icon + " does not exist!")
		var file = File.new()
		if file.open("res://LOGS/missing_icons_list.txt", File.WRITE) == OK:
			file.store_string("Missing icon for " + character_icon + "\n")
			file.close()
		loaded_icon = load("res://Textures/Characters/character_icon_swat_light.png")
	
	$Height/HeadIcon.texture = loaded_icon
	SignalManager.emit_signal("added_character_tracker", character_class)


func set_frame_time(new_time):
	frame_time = new_time


func set_trail_color(trail_color):
	if trail_color is Color:
		Console.log(["Tracker: set", self, "trail color", trail_color])
		var mat = $Particles.material_override.duplicate()
		mat.set("albedo_color", trail_color)
		$Particles.material_override = mat
		$Particles.emitting = true
	else:
		Console.log(["TrackerCharacter: disabled", character_class, "trail color"])


func remove_tracker():
	queue_free()
	SignalManager.emit_signal("removed_character_tracker", character_class)


func set_tracker_index(index:int):
	tracker_index = index


func _on_hitbox_input_event(_camera, _event, _click_position, _click_normal, _shape_idx):
	if Input.is_action_just_pressed("track"):
		Console.log(["TRACK!", self])
		SignalManager.track_object(self)


func set_status(status_id:String, status_duration = false):
	emit_signal("status_update", status_id, status_duration)


func _add_player_hud():
	Console.log(["TrackerCharacter: Applying player hud elements."])
	$TrackerBase.visible = false
	var hud = load("res://Trackers/TrackerCharacterPlayerHUD.tscn").instance()
	add_child(hud)
