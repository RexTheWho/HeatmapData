extends Node


signal toggle_vis(type)


var keybinds = {
	nav_quads = {state = true, bind = KEY_1},
	nav_segments = {state = false, bind = KEY_2},
	nav_doors = {state = false, bind = KEY_3},
	group_lines = {state = true, bind = KEY_4},
}


func _unhandled_input(event):
	if event is InputEventKey and event.pressed:
		for key in keybinds:
			if keybinds[key]["bind"] == event.scancode:
				keybinds[key]["state"] = !keybinds[key]["state"]
				var state = keybinds[key]["state"]
				emit_signal("toggle_vis", key, state)
				Console.log(["VisManager:", OS.get_scancode_string(event.scancode), key, state], Console.SETTING)


func is_visible(bind):
	if keybinds.has(bind):
		return keybinds[bind]["state"]
	else:
		Console.log(["VisManager: Missing bind for", bind], Console.WARN)
		return false
