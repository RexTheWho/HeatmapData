extends Spatial


signal missing_unit(unit_id)


var frame_time = 1.0
var unit_id = 0
var unit_type = "lootbag"
var prep_for_removal = false


func _ready():
	self.visible = false


func play_frame(frame_data:Array, ignore_interp:bool):
	if !prep_for_removal:
		var my_data
		
		for unit in frame_data[1]:
			if unit[0] == unit_id:
				my_data = unit
				break
		
		if my_data:
			var pos = Vector3( my_data[1], my_data[3], -my_data[2] )/100
			if ignore_interp or !visible:
				visible = true
				translation = pos
			else:
				var tween = $Tween
				var delay = frame_time
				tween.interpolate_property( self, "translation", translation, pos, delay)
				tween.start()
		else:
			prints("Tracker: Unit ID", str(unit_id), "no longer exists in frame data, Freeing.")
			emit_signal("missing_unit", unit_id)
			disconnect("next_frame", self, "play_frame")
			prep_for_removal = true
			$AnimationPlayer.play("removing")


func set_frame_time(new_time):
	frame_time = new_time


func remove_tracker():
	queue_free()
	SignalManager.emit_signal("removed_unit_tracker", unit_id)


func set_unit_id(index:int):
	unit_id = index


func set_unit_type(type:String):
	unit_type = type
	var icon_path = "res://Textures/Equipment/Carry/{unit_type}.png".format({"unit_type":CharDB.chardb["misc_icons"][unit_type]})
	
	var loaded_icon = load(icon_path)
	if !loaded_icon:
		prints("Missing icon for tracker unit", icon_path)
		loaded_icon = load("res://Textures/Equipment/Carry/generic.png")
	$PickupSprite.texture = loaded_icon



