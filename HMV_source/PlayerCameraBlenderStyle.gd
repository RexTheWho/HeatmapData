extends Spatial

const camera_zoom_slower_limit = 4.0

onready var rot_ref = $RotRef
onready var cam_y = $RotY
onready var cam_x = $RotY/RotX
onready var cam_z = $RotY/RotX/RotZ
onready var cam_persp = $RotY/RotX/RotZ/CameraPersp
onready var cam_ortho = $CameraOrtho

var last_mouse_position = Vector2.ZERO
var move_sensitivity = 0.25
var tracking = null

func _ready():
	if SignalManager.connect("camera_track_object", self, "_track_object", []) != OK:
		push_warning("CAMERA: Failed to track")


func _track_object(object = null):
	if is_instance_valid(tracking):
		prints("PCBS: Stopped Tracking", tracking)
		tracking._stopped_tracking()
	prints("PCBS: Started Tracking", object)
	tracking = object


func _process(_delta):
	if is_instance_valid(tracking):
		translation = tracking.translation


func _unhandled_input(event):
	if Input.is_action_just_pressed("track") and tracking != null:
		if is_instance_valid(tracking):
			prints("PCBS: Stopped Tracking", tracking)
			tracking._stopped_tracking()
		tracking = null
	
	if Input.is_action_just_pressed("zoom_in"):
		set_camera_zoom(-1.0)
	
	if Input.is_action_just_pressed("zoom_out"):
		set_camera_zoom(1.0)
	
	if event is InputEventMouseMotion and Input.is_action_pressed("dragging"):
		$OriginMarker.visible = true
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		var mouse_motion = event.get_relative() * move_sensitivity
		if event.get_shift():
			var movx = rot_ref.transform.basis.xform(Vector3(mouse_motion.x, -mouse_motion.y, 0.0)/2)
			translate(movx)
		
		elif event.get_control():
			set_camera_zoom(mouse_motion.y)
		
		elif event.get_alt():
			print("ALT MODE")
			#Poorly functioning ortho mode
#			var direct_mouse = event.get_relative()
#			var flick_resistance = 50
#			if direct_mouse.y > flick_resistance:
#				print(">>>>>>> FLICK Y")
#				if is_perspective():
#					set_ortho_direction(Vector3.DOWN)
#				else:
#					set_ortho_direction(false)
		
		else:
			cam_y.rotation_degrees.y -= mouse_motion.x
			cam_x.rotation_degrees.x = clamp(cam_x.rotation_degrees.x - mouse_motion.y, -90,90)
			rot_ref.rotation_degrees = Vector3(cam_x.rotation_degrees.x, cam_y.rotation_degrees.y, cam_z.rotation_degrees.z)
	
	if event.is_action_released("dragging"):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		$OriginMarker.visible = false


func set_camera_zoom(zoom):
	var start = cam_persp.translation.z
	if start == 0:
		start += zoom * 0.01
	elif start < camera_zoom_slower_limit:
		start += zoom * (start/camera_zoom_slower_limit)
	else:
		start += zoom
	cam_persp.translation.z = clamp(start, 0, 100)


func set_ortho_direction(direction):
	if direction:
		cam_ortho.current = true
		cam_persp.current = false
		cam_ortho.look_at(direction, Vector3.UP)
	else:
		cam_ortho.current = false
		cam_persp.current = true

func is_ortho():
	return cam_ortho.current

func is_perspective():
	return cam_persp.current
