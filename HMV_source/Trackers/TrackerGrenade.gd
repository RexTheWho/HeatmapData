extends Spatial


const icon_overrides = {
	molotov = "fire",
}

var radius = 150
var duration = 5
var icon = "res://Textures/Equipment/Thrown/{icon}.png"

func _ready():
	if radius > 0:
		$Viewport.size = Vector2(radius*2, radius*2)
		$Viewport.get_node("Scene").position = Vector2(radius, radius)
		$Viewport.get_node("Scene/Line2D").make_circle(radius)
	$Timer.start(duration)


func set_data(new_duration, new_radius, position, type):
	duration = new_duration
	radius = new_radius
	translation = position
	if icon_overrides.has(type):
		type = icon_overrides[type]
	icon = load(icon.format({"icon":type}))
	if icon:
		$Icon.texture = icon
	else:
		Console.log(["Grenade: Missing icon for", icon], Color.orangered)


func _on_timeout():
	$AnimationPlayer.play("fade_out")
