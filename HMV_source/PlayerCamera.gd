extends Spatial

const sense = 0.01
const move_speed = 16
var dragging = false
var camera_persp = Camera.PROJECTION_PERSPECTIVE

var tracking:Object
var tracking_zoom = 4.0
var zoomspeed = 0.75

var waiting_for_characters = true

func _ready():
	if SignalManager.connect("camera_track_object", self, "_track_object", []) != OK:
		push_warning("CAMERA: Failed to track")


func _unhandled_input(event):
	if Input.is_action_just_pressed("track") and tracking != null:
		tracking = null
	
	if Input.is_action_just_pressed("space"):
		if camera_persp == Camera.PROJECTION_PERSPECTIVE:
			camera_persp = Camera.PROJECTION_ORTHOGONAL
			$Camera.projection = camera_persp
		else:
			camera_persp = Camera.PROJECTION_PERSPECTIVE
			$Camera.projection = camera_persp
	
	if Input.is_action_just_pressed("drag"):
		dragging = true
		if event is InputEventMouseButton and event.doubleclick:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		else:
			Input.set_mouse_mode(Input.MOUSE_MODE_CONFINED)
	
	if Input.is_action_just_released("drag"):
		dragging = false
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	
	if dragging:
		if event is InputEventMouseMotion:
			var mouse = event.relative
			self.rotate_y( -mouse.x * sense )
			$Camera.rotate_x( -mouse.y * sense )
			$Camera.rotation_degrees.x = clamp($Camera.rotation_degrees.x, -90, 90)
	
	if Input.is_action_just_pressed("zoom_in"):
		tracking_zoom = clamp(tracking_zoom - 0.5, 2.0, 100.0)
	
	if Input.is_action_just_pressed("zoom_out"):
		tracking_zoom = clamp(tracking_zoom + 0.5, 2.0, 100.0)


func _process(delta):
	if Input.is_action_pressed("up"):
		if camera_persp == Camera.PROJECTION_PERSPECTIVE:
			translate( Vector3.UP * delta * move_speed )
		else:
			$Camera.size += 25 * delta
	
	if Input.is_action_pressed("down"):
		if camera_persp == Camera.PROJECTION_PERSPECTIVE:
			translate( Vector3.DOWN * delta * move_speed )
		else:
			$Camera.size -= 25 * delta
	
	if Input.is_action_pressed("forward"):
		translate( Vector3.FORWARD * delta * move_speed )
	if Input.is_action_pressed("backward"):
		translate( Vector3.BACK * delta * move_speed )
	if Input.is_action_pressed("left"):
		translate( Vector3.LEFT * delta * move_speed )
	if Input.is_action_pressed("right"):
		translate( Vector3.RIGHT * delta * move_speed )
	
	_tracking_movement(delta)
	
	if waiting_for_characters:
		var players = get_tree().get_nodes_in_group("player")
		if players and players.size() > 0:
			var group_position = players[0].get_parent().translation
			translation += group_position
			prints("Camera[][][][][][]: Started recording and locking onto spawning players!", group_position)
			waiting_for_characters = false


func _track_object(object = null):
	tracking = object


func _tracking_movement(delta):
	if tracking:
		var trnz_a = Vector2(translation.x, translation.z)
		var trnz_b = Vector2(tracking.translation.x, tracking.translation.z)
		var distance = trnz_a.distance_to(trnz_b)
		var speed = 0.0
		if distance > tracking_zoom + 0.5: # Too far
			speed = (distance / tracking_zoom * zoomspeed * delta)
		elif distance < tracking_zoom - 0.5: # Too close
			speed = (distance / tracking_zoom * -zoomspeed * delta)
		translation.x = lerp(translation.x, trnz_b.x, speed)
		translation.z = lerp(translation.z, trnz_b.y, speed)
#		translation.y = lerp(translation.y, tracking.translation.y + (tracking_zoom/2), zoomspeed * 3 * delta)
		
		look_at(tracking.translation, Vector3.UP)
		$Camera.rotation_degrees.x = rotation_degrees.x - (tracking_zoom*0.5)
		rotation_degrees.x = 0
		rotation_degrees.z = 0


