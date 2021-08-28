extends Spatial


var keybind = KEY_1


func _unhandled_input(event):
	if event is InputEventKey:
		if event.pressed and event.scancode == keybind:
			visible = !visible
