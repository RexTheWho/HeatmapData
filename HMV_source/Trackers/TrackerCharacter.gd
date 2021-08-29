extends Spatial

# Description: Main tracker node for Characters.
# Mechanics: set frametime // set character // set trail color // set index // remove tracker
# Bugs: (invert: "det == 0" is true) is driving me up the wall, not sure whats causing it.

signal missing_character(character_id)
signal status_update(status, duration)
signal stat_change(stat, value)

const toggle_script = preload("res://Navigation/ToggleVisibleKeybind.gd")

var characters = {}
var character_classes = {}

var tracker_index = 0
var character_id
var character_class = "none"
var character_group = "none"

var frame_time = 1.0
var prep_for_removal = false
var connected_trackers = []


func _init():
	characters = CharDB.chardb["characters"]
	character_classes = CharDB.chardb["character_classes"]


func _ready():
	self.visible = false
	$Height/Status.connect_status_tracker(self)
	SignalManager.simple_connect(SignalManager, self, "camera_perspective_mode", "_change_head_scale", [])


func _process(delta):
	_group_lines_process()


func play_frame(frame_data:Array, ignore_interp:bool):
	if !prep_for_removal:
		var my_data:Array
		for i in frame_data[tracker_index]:
			if str(i[0]) == str(character_id):
				my_data = i
				break
		
		if my_data:
			if my_data.size() > 1:
				var pos = Vector3( my_data[1], my_data[3], -my_data[2] )/100
				var rot = Vector3( 0, my_data[4], 0 ) # Rotations need to be lerped properly!
				var dir_node = $Direction
	#			if abs(rot.y - dir_node.rotation_degrees.y) > 180:
	#				var dif = rot.y - dir_node.rotation_degrees.y
	#				rot.y -= dif
				
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
	#					tween.interpolate_property( dir_node, "rotation_degrees", dir_node.rotation_degrees, rot, delay)
						dir_node.rotation_degrees = rot
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
	var tid = get_parent().get_header_stringdex(char_data[5]) # -1 was problematic after adding group id
	if characters.has(tid):
		character_class = characters[tid]
	else:
		character_class = tid
	
	if char_data.size() > 6:
		character_group = get_parent().get_header_stringdex(char_data[6])
	
	Console.log(["TrackerCharacter: set character", character_id, character_class])
	
	var character_icon = "res://Textures/Characters/character_icon_{character_id}.png".format({"character_id":character_class})
	
	if CharDB.is_heister(character_class):
		character_group = "payday_gang"
		$Hitbox.add_to_group("player")
		_add_player_hud()
		var player_index = get_parent().get_header_heister_index(character_class)
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
		var partners = get_parent().get_character_group_partners(character_group)
		_track_partners(partners)


func _track_partners(partners:Array):
	connected_trackers = []
	for unit in partners:
		if unit != self:
			connected_trackers.append(unit)
			var new_line:CSGCylinder = CSGCylinder.new()
			new_line.radius = 0.02
			new_line.set_script(toggle_script)
			new_line.set_vis_id("group_lines")
			new_line.visible = VisibilityManager.is_visible("group_lines")
			$TrackerLines.add_child(new_line)


func _stopped_tracking():
	connected_trackers = []
	for i in $TrackerLines.get_children():
		i.queue_free()


func set_status(status_id:String, status_duration = false):
	emit_signal("status_update", status_id, status_duration)


func _add_player_hud():
	Console.log(["TrackerCharacter: Applying player hud elements."])
	$TrackerBase.visible = false
	var hud = load("res://Trackers/TrackerCharacterPlayerHUD.tscn").instance()
	hud.name = "PlayerHud"
	add_child(hud)


func _change_head_scale(mode):
	if mode == "ortho" and is_using_player_ui():
		$Height.translation.y = 0.0
		$Height/HeadLine.visible = false
		$Height/HeadDot.visible = false
		$Height/HeadIcon.scale = Vector3(0.5, 0.5, 0.5)
	else:
		$Height.translation.y = 1.0
		$Height/HeadLine.visible = true
		$Height/HeadDot.visible = true
		$Height/HeadIcon.scale = Vector3(1, 1, 1)


func _group_lines_process():
	if VisibilityManager.is_visible("group_lines"):
		var idx = 0
		for tracker in connected_trackers:
			var line = $TrackerLines.get_child(idx)
			if is_instance_valid(tracker) and is_instance_valid(line):
				var length = translation.distance_to(tracker.translation) - 1.0
				if length > 0.0:
					line.visible = true
					line.translation = lerp(translation, tracker.translation, 0.5) - translation
					line.look_at(tracker.translation, Vector3.UP)
					line.rotation_degrees += Vector3(90,0,0)
					line.height = length
				else:
					line.visible = false
			elif is_instance_valid(line):
				line.queue_free()
			idx += 1


func is_using_player_ui():
	if get_node_or_null("PlayerHud"):
		return true
	else:
		return false
