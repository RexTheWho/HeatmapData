extends Node

# warning-ignore:unused_signal
signal added_character_tracker(character_id)
# warning-ignore:unused_signal
signal removed_character_tracker(character_id)

signal frame_event(event_id)

signal camera_track_object(object)

signal camera_perspective_mode(mode)

var selected_job = ""


func get_selected_job():
	var j = selected_job
	selected_job = ""
	return j

# Fast signal connect
func simple_connect(from:Object, to:Object, signal_id:String, method:String, items:Array):
	if from.connect(signal_id, to, method, items) != OK:
		push_warning("SignalManager: Failed to simple connect " + signal_id + " from " + str(from))


# For frame events only!
func connect_listener(to:Object, method:String, items = []):
	if self.connect("frame_event", to, method, items) != OK:
		push_warning("SignalManager: Failed to simple connect " + method)


func emit_frame_event(event_id):
	emit_signal("frame_event", event_id)


func track_object(object):
	emit_signal("camera_track_object", object)
