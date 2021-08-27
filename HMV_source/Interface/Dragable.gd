extends Control


var dragging = false
var drag_start = Vector2.ZERO


func _on_drag_gui_input(event):
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT:
			dragging = event.pressed
			drag_start = get_local_mouse_position()
			print("Drag")


func _process(delta):
	if dragging:
		rect_position = get_global_mouse_position() - drag_start
