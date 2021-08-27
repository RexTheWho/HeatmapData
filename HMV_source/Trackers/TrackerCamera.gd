extends Spatial

const camera_hacked_glow = Color(0.0, 0.6, 1.0, 0.08)
const camera_enemy_glow = Color(1.0, 0.0, 0.0, 0.08)
const camera_spotter_glow = Color()

onready var yaw = $Yaw
onready var pitch = $Yaw/Pitch
onready var cone = $Yaw/Pitch/Cone


func _ready():
	cone.material = cone.material.duplicate()


# Radius isnt used yet, requires a good FOV system
func set_camera_data(data):
	# Adding
	if data[1] is String and data[1] == "add" or data[1] is bool and data[1] == true:
		print("TrackerCam: Adding...")
		var cone_length = data[8]/100
		translation = Vector3(data[3], data[5], -data[4])/100
		yaw.rotation_degrees.y = data[6]
		pitch.rotation_degrees.x = data[7]
		cone.height = cone_length
		cone.translation.y = -cone_length/2
		cone.radius = cone_length*1.5
	
	# Cam Loop
	elif data[1] == "hack":
		print("TrackerCam: Camera loop started...")
		cone.material.set_shader_param("albedo", camera_hacked_glow)
	
	# Cam Loop End
	elif data[1] == "hack_end":
		print("TrackerCam: Camera loop ended...")
		cone.material.set_shader_param("albedo", camera_enemy_glow)
	
	# Removing
	else:
		print("TrackerCam: Removing...")
		# Add animation before freeing
		queue_free()
