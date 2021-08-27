extends Control

# Description: Unfinished interface for playback.
# Mechanics: timeline slider to control current frame.
# Bugs: Rewinding causes trackers to not respawn. (See TrackerNodeHolder.gd)

signal set_timeline_time(time)

export(NodePath) var tracker_holder

func _ready():
	if tracker_holder:
		var track = get_node(tracker_holder)
		if track.connect("play_recording", self, "_setup_timeline_values", []) == OK:
			print("INTERFACE: connected to track holder timeline...")
		
		if track.connect("current_frame", self, "_set_frame", []) == OK:
			print("INTERFACE: connected to track holder current_frame...")
		
		if track.connect("completely_loaded_recording", self, "_hide_loading_rect") == OK:
			print("INTERFACE: connected to track holder current_frame...")
		
		if self.connect("set_timeline_time", track, "set_frame_current", []) == OK:
			print("INTERFACE: connected to track holder set_frame_current...")


func _setup_timeline_values(max_value):
	$HSlider.max_value = max_value
	prints("...timeline slider set to", max_value)
	_show_loading_rect()


func _on_timeline_value_changed(value):
	emit_signal("set_timeline_time", value)


func _set_frame(frame):
	$HSlider.value = frame


func _show_loading_rect():
	var loading = $LoadingRect
	$LoadingRect/Tween.interpolate_property(loading, "modulate", loading.modulate, Color(1.0,1.0,1.0,1.0), 0.25)
	$LoadingRect/Tween.start()


func _hide_loading_rect():
	var loading = $LoadingRect
	$LoadingRect/Tween.interpolate_property(loading, "modulate", loading.modulate, Color(1.0,1.0,1.0,0.0), 0.25)
	$LoadingRect/Tween.start()
