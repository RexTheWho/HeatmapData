extends Spatial


# Description: Manage the tracker nodes of the recording. Should support headerless recordings.
# Mechanics: play/load recording // spawn characters and unit trackers // clear trackers // control playback time.
# Bugs: Rewinding causes trackers to not respawn.


signal play_recording(timeline_length)
signal next_frame(frame_data, ignore_interp)
signal current_frame(index)
signal end_recording
signal completely_loaded_recording

const minimum_safe_frames = 50

var thread_frameload:Thread
var playing_heatmap = false
var frame_current = 0
var frame_max = 0


var recording_header = {
#	level_id = "four_stores",
#	update_delay = 0.3,
#	difficulty = 0,
#	contractor_id = "bain",
}
var recording_timeline = []
var current_characters = {
	#1: Object
}
var current_units = {}
var waypoints = {}
var cameras = {}

#func _ready():
#	if get_tree().connect("files_dropped", self, "_generate_recording") == OK:
#		print("Ready to go!")


func _input(event):
	if event.is_action_pressed("skip"):
		Engine.time_scale = 4.0
	elif event.is_action_released("skip"):
		Engine.time_scale = 1.0
	
	if event.is_action_pressed("skip_back"):
		Engine.time_scale = 0.25
	elif event.is_action_released("skip_back"):
		Engine.time_scale = 1.0
	
	if event.is_action_pressed("pause_timer"):
		if $Timer.paused:
			$Timer.set_paused(false)
		else:
			$Timer.set_paused(true)


func _generate_recording(files:PoolStringArray, _i:int):
	generate_recording(files[0])


func generate_recording(file:String):
	if file.get_extension() == "pdheat":
		_load_recording(file)


func _load_recording(heatmap_file):
	_reset_data()
	var file = File.new()
	if file.open(heatmap_file, File.READ) == OK:
		var file_text = file.get_as_text()
		recording_header = JSON.parse( file_text ).result
		if not recording_header is Dictionary:
			recording_header = {}
		
		# frame max is required before the thread is started to decide if its safe to go.
		if recording_header.has("frame_total"):
			frame_max = recording_header.frame_total
		
		Console.log(["TrackNodeHolder: About to spawn loading thread"])
		
		thread_frameload = Thread.new()
		thread_frameload.start(self, "_load_recording_frames", file)


func _load_recording_frames(file:File):
	var txt = file.get_as_text() + "\n"
	var every_25_frames = 0
	while true:
		txt = txt.right( txt.find("\n")+1 )
		if txt == "":
			file.close()
			Console.log(["TrackerNodeHolder [THREAD]: collected all results!"], Color.green)
			emit_signal("completely_loaded_recording")
			break
		if every_25_frames == 25:
			every_25_frames = 0
			Console.log(["TrackerNodeHolder [THREAD]: continue to collect results..."], Color.darkgray)
		else:
			every_25_frames += 1
		recording_timeline.append( JSON.parse( txt ).result )
		frame_max = recording_timeline.size()-1
		_play_when_safe()
		yield(VisualServer, "frame_pre_draw")


func _exit_tree():
	if thread_frameload:
		thread_frameload.wait_to_finish()


func _play_when_safe():
	if !playing_heatmap:
		if recording_timeline.size() > minimum_safe_frames or recording_timeline.size() == frame_max:
			_play_recording()


func _reset_data():
	playing_heatmap = false
	frame_current = 0
	frame_max = 0
	recording_header = {}
	recording_timeline = []
	current_characters = {}
	current_units = {}
	waypoints = {}
	cameras = {}


func _play_recording():
	playing_heatmap = true
	emit_signal("play_recording", frame_max)
	
	if recording_header.has("update_delay"):
		Console.log(["Playing:", recording_header])
	else:
		Console.log(["Failed to play: Missing 'update_delay' in header! Playing at 0.5s"], Color.red)
		recording_header["update_delay"] = 0.5
	
	if recording_header.has("level_id"):
		if !recording_header.has("contractor_id"):
			recording_header["contractor_id"] = ""
		CharDB.update_char_db(recording_header["level_id"], recording_header["contractor_id"])
	else:
		Console.log(["Missing level_id in header! -- This is not too important but in future its best to have one."], Color.red)
	
	Console.log(["TrackerNodeHolder: Begin playing heatmap recording!"], Color.green)
	$Timer.start( recording_header["update_delay"] )


func _on_frame_wait_timeout():
	if frame_max > frame_current:
		_use_frame()
		emit_signal("next_frame", recording_timeline[frame_current], false)
		emit_signal("current_frame", frame_current)
		frame_current += 1
	else:
		$Timer.stop()
		Console.log(["TrackerNodeHolder: Recording playback stopped!"], Color.orangered)
		emit_signal("end_recording")


func _use_frame():
	if !recording_timeline.empty() and recording_timeline[frame_current] != null:
		_character_group(recording_timeline[frame_current][0])
		if recording_timeline[frame_current].size() >= 2:
			_misc_group_units(recording_timeline[frame_current][1])
		if recording_timeline[frame_current].size() >= 3:
			_event_group(recording_timeline[frame_current][2])
	else:
		Console.log(["Failed to play, Recording timeline was completely empty!"], Color.red)


# [uID, X, Y, Z, R, tID, gID]
func _character_group(data:Array):
	if !data.empty():
		for char_data in data:
			if !current_characters.has(char_data[0]):
				Console.log(["Adding missing character:", char_data[0]], Color.green)
				add_tracker_character(char_data)


func _misc_group_units(data:Array):
	if !data.empty():
		for unit in data:
			if !current_units.has(unit[0]):
				var tracker
				
				if unit.size() >= 5:
					tracker = add_tracker_unit(unit[0], unit[4])
				else:
					tracker = add_tracker_unit(unit[0])
				
				if tracker:
					current_units[unit[0]] = tracker
					Console.log(["Adding missing unit:", unit[0]], Color.green)


func _event_group(data:Array):
	if !data.empty():
		for event in data:
			# Objectives
			if event[0] == "obj":
				print("OBJECTIVE")
			
			# GLobal EVents
			elif event[0] == "glev":
				SignalManager.emit_frame_event(event[1])
			
			# Cameras
			elif event[0] == "cam":
				if event[1] == "add":
					_add_camera(event)
				elif event[1] == "rmv":
					_rmv_camera(event)
				else:
					if cameras.has(event[2]):
						 cameras[event[2]].set_camera_data(event)
			
			# Waypoints
			elif event[0] == "wp":
				if event[1] == "add":
					_add_waypoint(event)
				elif event[1] == "edt":
					_edit_waypoint(event)
				else:
					_rmv_waypoint(event)
			
			# Grenades
			elif event[0] == "grenade":
				_spawn_grenade(event)
			
			# From Cop Flashbangs
			# ["flashbang",-1150,2225,23,1000]
			elif event[0] == "flashbang":
				var diff = 0
				if recording_header.has("difficulty"):
					diff = recording_header["difficulty"]
				_spawn_flashbang(event, diff)
			
			# Player states
			elif event[0] == "state":
				if current_characters.has(event[1]):
					current_characters[event[1]].set_status(event[2])
			
			# Player states
			elif event[0] == "deploy":
				_event_deploy(event)
			
			# Player states
			elif event[0] == "ammo":
				_event_ammo_clip(event)
			
			# Waypoints
			elif event[0] == "gage":
				_event_gage_pack(event)
			
			else:
				Console.log(["TrackerHolder: Could not find a relavent function for event", event[0]], Color.orange)


func add_tracker_character(char_data):
	var tracker = $Resources.get_resource("Character").instance()
	if connect("next_frame", tracker, "play_frame", []) == OK and tracker.connect("missing_character", self, "clear_missing_character", []) == OK:
		add_child(tracker)
		tracker.set_character(char_data)
		tracker.set_frame_time(recording_header["update_delay"])
		
		var uid = char_data[0]
		var tid = recording_header["stringdex"][char_data[5]] # -1 was problematic after adding group id
	
		current_characters[uid] = tracker
		Console.log(["TrackerNodeHolder: Added", tid, "of ID", uid], Color.green)
	else:
		push_warning("TrackerNodeHolder: Could not add tracker character!")


func add_tracker_unit(unit_id, unit_class = "none"):
	var tracker = $Resources.get_resource("Unit").instance()
	if connect("next_frame", tracker, "play_frame", []) == OK and tracker.connect("missing_unit", self, "clear_missing_unit", []) == OK:
		tracker.set_unit_id(unit_id)
		tracker.set_unit_type(unit_class)
		tracker.set_frame_time(recording_header["update_delay"])
		current_units[unit_id] = tracker
		add_child(tracker)
		Console.log(["Added lootbag of ID", unit_id], Color.green)
	return tracker


func set_frame_current(value):
	frame_current = clamp(value, 0, frame_max)
	emit_signal("next_frame", recording_timeline[frame_current], true)


func clear_missing_character(character_id):
	if current_characters.has(character_id):
		current_characters.erase(character_id)
		Console.log(["TrackerHolder: Erased current_characters", character_id], Color.yellow)


func clear_missing_unit(unit_id):
	if current_units.has(unit_id):
		current_units.erase(unit_id)
		Console.log(["TrackerHolder: Erased current_units", unit_id], Color.yellow)


func _add_waypoint(event):
	Console.log(["TrackerHolder: Adding WP", event[2], "Icon:", event[3]], Color.green)
	var wp_node = Sprite3D.new()
	wp_node.set_script($Resources.get_resource("WaypointScript"))
	add_child(wp_node)
	wp_node.set_waypoint_data(event)
	waypoints[event[2]] = wp_node


func _edit_waypoint(event):
	if waypoints.has(event[2]):
		Console.log(["TrackerHolder: Editing WP", event[2], "Icon:", event[3]], Color.lightblue)
		var wp_node = waypoints[event[2]]
		wp_node.edit_waypoint_data(event)
	else:
		Console.log(["TrackerHolder: Could not edit non existant WP", event[2]], Color.orangered)


func _rmv_waypoint(event):
	if waypoints.has(event[2]):
		Console.log(["TrackerHolder: Removing WP", event[2]])
		waypoints[event[2]].remove_waypoint()
		waypoints.erase(event[2])
	else:
		Console.log(["TrackerHolder: Could not remove non existant WP", event[2]], Color.orangered)


func _add_camera(event):
	if !cameras.has(event[2]):
		Console.log(["TrackerHolder: Adding Camera", event[2]], Color.green)
		var camera = $Resources.get_resource("Camera").instance()
		cameras[event[2]] = camera
		add_child(camera)
		cameras[event[2]].set_camera_data(event)


func _rmv_camera(event):
	if cameras.has(event[2]):
		Console.log(["TrackerHolder: Removing Camera", event[2]], Color.yellow)
		cameras[event[2]].set_camera_data(event)
		cameras.erase(event[2])


# Spawn self destroying grenade.
func _spawn_grenade(event):
	var grenade = $Resources.get_resource("Grenade").instance()
	var type = event[1]
	var pos = Vector3(event[2], event[4], -event[3])/100
	var effect_range = 400
	if event.size() >= 7:
		effect_range = event[6]
	
	if type == "flash":
		var duration = 1
		grenade.set_data(duration, 0, pos, type)
	else:
		var duration = event[5]
		grenade.set_data(duration, effect_range, pos, type)
	add_child(grenade)


const flashbang_diff_duration = [1.0, 1.5, 1.5, 1.75, 2.0, 2.0, 2.0]
func _spawn_flashbang(event, diff):
	var flashbang = $Resources.get_resource("StunEffect").instance()
	flashbang.set_data(event, flashbang_diff_duration[diff])
	add_child(flashbang)


func _event_deploy(event):
	if current_units.has(event[1]):
		print("Act on DEPLOYABLE")
		var update_event = event[2]
		var update_amount = null
		if event.size() > 3:
			update_amount = event[3]
		current_units[event[1]].call("_status_update", update_event, update_amount)
	else:
		print("SPAWN DEPLOYABLE")
		var deployable = $Resources.get_resource("Deploy").instance()
		deployable.set_data(event)
		current_units[event[1]] = deployable
		add_child(deployable)


func _event_ammo_clip(event):
	# Lets see how this goes...
	if !current_units.has("ammoclips"):
		current_units.ammoclips = {}
	
	if current_units.ammoclips.has(event[1]):
		current_units.ammoclips[event[1]].queue_free()
		current_units.ammoclips.erase(event[1])
	else:
		var ammoclip = $Resources.get_resource("AmmoClip").instance()
		if event.size() > 2:
			ammoclip.translation = Vector3( event[2], event[4], -event[3] )/100
		else:
			_event_ammo_clip_remove(event[1])
		ammoclip.rotation_degrees.y = rand_range(0, 360)
		current_units.ammoclips[event[1]] = ammoclip
		add_child(ammoclip)
		if current_units.ammoclips.size() > 20:
			var lowest_pickup = INF
			for id in current_units.ammoclips.keys():
				if id < lowest_pickup:
					lowest_pickup = id
			_event_ammo_clip_remove(lowest_pickup)

func _event_ammo_clip_remove(id):
	if current_units["ammoclips"].has(id):
		current_units["ammoclips"][id].queue_free()
		current_units.ammoclips.erase(id)


func _event_gage_pack(event):
	if current_units.has(event[1]):
		current_units[event[1]].queue_free()
		current_units.erase(event[1])
	else:
		var gage:Sprite3D = Sprite3D.new()
		gage.texture = load("res://Textures/GagePacks/{gageid}.png".format({"gageid":event[5]}))
		gage.billboard = SpatialMaterial.BILLBOARD_ENABLED
		gage.translation = Vector3( event[2], event[4], -event[3] )/100
		current_units[event[1]] = gage
		add_child(gage)


func get_header_stringdex(i:int):
	return recording_header["stringdex"][i]


func get_header_stringdex_index(id):
	var key_idx = 0
	for key in CharDB.chardb.characters.keys():
		if CharDB.chardb.characters[key] == id:
			return key_idx
		else:
			key_idx += 1
	return -1


# Does not work properly, todo make it get the 0123 heister index
var temp_team_index = 0
func get_header_heister_index(id):
	temp_team_index = clamp(temp_team_index + 1, 0, 5)
	return temp_team_index - 1


func get_header_level_id():
	if recording_header.has("level_id"):
		return recording_header["level_id"]
	else:
		return null


func get_character_group_partners(group_id:String):
	var partners = []
	for unit in current_characters.values():
		if unit.character_group != "none" and unit.character_group == group_id:
			partners.append(unit)
	return partners



