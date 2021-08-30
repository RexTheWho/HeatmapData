extends Camera2D

const camera_max = 32

func _input(event):
	if event is InputEventMouseMotion:
		var interpx = get_global_mouse_position().x / OS.window_size.x
		var interpy = get_global_mouse_position().y / OS.window_size.y
		position.x = lerp(0, camera_max, interpx)
		position.y = lerp(0, camera_max/2, interpy)
