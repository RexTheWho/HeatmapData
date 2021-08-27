extends Sprite3D


const overrides = {
	wp_calling_in = "wp_calling",
	wp_calling_in_hazard = "wp_calling",
}
var wp_icon = "wp_standard"
var tween:Tween


func _init():
	billboard = SpatialMaterial.BILLBOARD_ENABLED
	tween = Tween.new()
	add_child(tween)


func set_waypoint_data(data):
	wp_icon = data[3]
	_update_position(Vector3(data[4], data[6], -data[5])/100)
	_update_texture()


func edit_waypoint_data(data):
	prints("WPTracker: Edit", data)
	wp_icon = data[3]
	_update_texture()


func _update_position(pos:Vector3):
	var start_pos = pos + Vector3(0, -1, 0)
# warning-ignore:return_value_discarded
	tween.interpolate_property(self, "translation", start_pos, pos, 0.5)
# warning-ignore:return_value_discarded
	tween.interpolate_property(self, "scale", Vector3(0,0,0), Vector3(1,1,1), 0.5)
# warning-ignore:return_value_discarded
	tween.start()


func _update_texture():
	if overrides.has(wp_icon):
		wp_icon = overrides[wp_icon]
	var waypoint_icon_path = "res://Textures/Waypoints/{wp_icon}.png".format({"wp_icon":wp_icon})
	var loaded_icon = load(waypoint_icon_path)
	if !loaded_icon:
		push_warning("WPTracker: " + waypoint_icon_path + " does not exist!")
		var file = File.new()
		if file.open("res://LOGS/missing_icons_list.txt", File.WRITE) == OK:
			file.store_string("Missing icon for " + waypoint_icon_path + "\n")
			file.close()
		loaded_icon = load("res://Textures/Waypoints/wp_standard.png")
	texture = loaded_icon


func remove_waypoint():
	print("TrackerWP: Removing...")
	# Add animation before freeing
	queue_free()
