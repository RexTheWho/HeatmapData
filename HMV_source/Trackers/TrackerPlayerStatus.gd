extends Spatial

# If status type is false we instantly clear current status visuals
# If status type is string we use that type to get the icon and apply the status to the tracker character
# If status duration is a number we use a timer to fade out the icon

const icon_path_temp = "res://Textures/CharacterUI/status_{status}.png"
const status_type_durations = {
	standard = 0,
	carry = 0,
}
const status_type_overrides = {
	mask_off = false,
	custody = false,
	standard = false,
	bleed_out = "downed",
	arrested = "cuffed",
	jerry1 = false,
	jerry2 = "parachute",
}
const status_rank = [
	"downed",
	"swansong",
	"parachute",
	"cuffed",
	"tased",
	"blind",
	"calling", #non-player focused
	"alerted", #non-player focused
	"carry",
]
var current_status


func connect_status_tracker(target):
	if target.connect("status_update", self, "_status_update", []) != OK:
		push_warning("Failed to connect status update")


func _status_update(status, duration):
	if status_type_overrides.has(status):
		status = status_type_overrides[status]
	
	if status:
		if current_status == null or status_rank.find(status) < status_rank.find(current_status):
			Console.log(["TrackerPlayerStatus: set", status, "duration", duration], Color.lightblue)
			var icon_texture = load(icon_path_temp.format({"status":status}))
			if !icon_texture:
				icon_texture = load("res://Textures/CharacterUI/status_suspicious.png")
				prints("TrackerPlayerStatus: Missing texture for", status)
			$Spatial/StatusMain.texture = icon_texture
			$AnimationPlayer.play("status_update")
			current_status = status
			if duration:
				if status_type_durations.has(duration):
					duration = status_type_durations[duration]
				yield($AnimationPlayer, "animation_finished")
				$Timer.start(duration)
	else:
		_clear_status()


func _clear_status():
	$AnimationPlayer.play("status_fade")
	current_status = null
