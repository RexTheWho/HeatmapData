extends Control


signal updated_progress

var yield_frames = 0
var cur_frames = 0
var max_frames = 10


func update_progress():
	cur_frames += 1
	yield_frames += 1
	$ProgressBar.value = cur_frames
	if yield_frames > max_frames/10:
		yield_frames = 0
		yield(VisualServer, "frame_post_draw")
	call_deferred("emit_signal", "updated_progress")


func _on_update_timeline_length(timeline_length):
	max_frames = timeline_length
	$ProgressBar.max_value = max_frames
	$ProgressBar/Label.text = "LOADING!"


func _on_done():
	$Tween.interpolate_property(self, "modulate", modulate, Color(1.0, 1.0, 1.0, 0.0), 0.5, Tween.TRANS_CUBIC, Tween.EASE_IN, 0.5)
	$Tween.start()


func _on_play_recording(_timeline_length):
	_on_done()
