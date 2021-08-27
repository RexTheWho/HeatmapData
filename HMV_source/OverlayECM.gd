extends ColorRect


export(String) var event_show
export(String) var event_hide


func _ready():
	SignalManager.connect_listener(self, "_frame_event", [])


func _frame_event(event_id):
	if event_id == event_show:
		print("ECM JAMMER ON!!")
		$Tween.interpolate_property(self, "modulate", Color(1,1,1,0), Color(1,1,1,1), 0.5)
		$Tween.start()
		visible = true
	
	elif event_id == event_hide:
		print("ECM JAMMER OFF!!")
		$Tween.interpolate_property(self, "modulate", Color(1,1,1,1), Color(1,1,1,0), 0.5)
		$Tween.start()
		yield($Tween,"tween_all_completed")
		visible = false
