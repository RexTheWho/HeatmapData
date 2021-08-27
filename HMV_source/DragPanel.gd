extends Panel

var mouse_start = Vector2.ZERO
var dragging = false

func _on_gui_input(event):
	if event is InputEventMouseButton:
		if event.button_index == 1 or event.button_index == 2:
			mouse_start = get_local_mouse_position()
			dragging = event.pressed

func _process(delta):
	if dragging:
		rect_position = get_global_mouse_position() - mouse_start
