extends Node2D

const camera_max = 32



func _input(event):
	if event is InputEventMouseMotion:
		var interpx = get_global_mouse_position().x / OS.window_size.x
		var interpy = get_global_mouse_position().y / OS.window_size.y
		$CrimeNetCamera.position.x = lerp(0, camera_max, interpx)
		$CrimeNetCamera.position.y = lerp(0, camera_max/2, interpy)
	
	if event.is_action_pressed("ui_down"):
		_pick_random_zoom_point()
	
	if event.is_action_pressed("ui_up"):
		_zoom_out()


func _pick_random_zoom_point():
	var zoom_to:Vector2
	zoom_to.x = rand_range(-400, 400)
	zoom_to.y = rand_range(-300, 300)
	$Tween.interpolate_property(self, "position", position, zoom_to, 0.5, Tween.TRANS_CUBIC, Tween.EASE_OUT)
	$Tween.interpolate_property($CrimeNetCamera, "zoom", $CrimeNetCamera.zoom, Vector2(0.6,0.6), 0.5, Tween.TRANS_CUBIC, Tween.EASE_OUT)
	$Tween.start()


func _zoom_out():
	$Tween.interpolate_property(self, "position", position, Vector2.ZERO, 0.5, Tween.TRANS_CUBIC, Tween.EASE_OUT)
	$Tween.interpolate_property($CrimeNetCamera, "zoom", $CrimeNetCamera.zoom, Vector2(1,1), 0.5, Tween.TRANS_CUBIC, Tween.EASE_OUT)
	$Tween.start()
