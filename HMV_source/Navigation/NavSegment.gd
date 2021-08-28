extends StaticBody


var keybind = KEY_1


func _unhandled_input(event):
	if event is InputEventKey:
		if event.pressed and event.scancode == keybind:
			visible = !visible


func _on_input_event(camera, event:InputEventMouseButton, click_position, click_normal, shape_idx):
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT:
			if event.pressed:
				_select_segment()
			else:
				_deselect_segment()


func _select_segment():
	print("SELECT")


func _deselect_segment():
	print("DESELECT")
