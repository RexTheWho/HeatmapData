extends PanelContainer

signal popup
signal closed
signal closed_resetting

var transition = Tween.TRANS_CIRC
var easing = Tween.EASE_IN_OUT
var duration = 0.5
var open = false

func _ready():
	var tween = Tween.new()
	tween.name = "Tween"
	add_child(tween)


func popup(target_size:Vector2):
	var tween:Tween = get_node_or_null("Tween")
	if tween:
		if open:
			close()
			yield(self, "closed_resetting")
			print("Done resetting")
		open = true
		emit_signal("popup")
		tween.interpolate_property(self, "modulate:a", 0.0, 1.0, 0.1, transition, easing)
		tween.interpolate_property(self, "rect_position:x", rect_position.x, rect_position.x - target_size.x/2, duration/2, transition, easing)
		tween.interpolate_property(self, "rect_size:x", 0, target_size.x, duration/2, transition, easing)
		tween.interpolate_property(self, "rect_size:y", 0, target_size.y, duration/2, transition, easing, duration/4)
		tween.start()
		yield(tween,"tween_all_completed")
		for c in get_children():
			if c.is_class("Control"):
				tween.interpolate_property(c, "modulate:a", 0.0, 1.0, duration/8)
				tween.interpolate_property(c, "visible", false, true, duration/8)
		tween.start()


func close():
	if open:
		open = false
		var tween:Tween = get_node_or_null("Tween")
		if tween:
			emit_signal("closed")
			for c in get_children():
				if c.is_class("Control"):
					tween.interpolate_property(c, "modulate:a", 1.0, 0.0, duration/8)
					tween.interpolate_property(c, "visible", true, false, duration/8)
			tween.interpolate_property(self, "rect_size:x", rect_size.x, 0, duration/2, transition, easing, duration/4)
			tween.interpolate_property(self, "rect_position:x", rect_position.x, rect_position.x + rect_size.x/2, duration/2, transition, easing, duration/4)
			tween.interpolate_property(self, "rect_size:y", rect_size.y, 0, duration/2, transition, easing)
			tween.interpolate_property(self, "modulate:a", modulate.a, 0, 0.1, transition, easing, duration)
			tween.start()
			yield(tween, "tween_all_completed")
			emit_signal("closed_resetting")
