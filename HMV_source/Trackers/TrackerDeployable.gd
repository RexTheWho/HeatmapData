extends Spatial

signal update

var uinode:Object
var uid
var equipment_id = ""
var amount = false
var ignore_destroy_on_empty = false


func set_data(event):
	uid = event[1]
	if event.size() > 3:
		translation = Vector3( event[3], event[5], -event[4] )/100
	equipment_id = event[2]
	if event.size() > 6:
		amount = event[6]
	
	uinode = $Viewport/Deployable
	uinode.parent = self
	uinode.setup(equipment_id, amount)
	if connect("update", uinode, "_update_dots") != OK:
		push_warning("Failed to connect deployable.")


func _status_update(event, value):
	if event == "used":
		amount = value
		emit_signal("update")
	elif event == "empty":
		$AnimationPlayer.play("fade")


func _destroy_me():
	if !ignore_destroy_on_empty:
		queue_free()
		get_parent().clear_missing_unit(uid)


func get_amount():
	return float(amount)
