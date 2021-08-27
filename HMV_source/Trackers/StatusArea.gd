extends Spatial


var duration = 1.0
var radius = 10.0
var status = "none"

func set_data(event, diff_duration):
	status = event[0]
	translation = Vector3(event[1], event[3], -event[2])/100
	radius = event[4]/100
	if status == "flashbang":
		duration = diff_duration


func _on_area_entered(area):
	if area.is_in_group("player"):
		var target = area.get_parent()
		var status_duration = get_duration(target)
		target.set_status("blind", status_duration)
		prints("StunEffect: Player has been stunned!", status_duration)


func get_duration(target):
	return duration * (radius / translation.distance_to(target.translation))
