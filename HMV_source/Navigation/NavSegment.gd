extends StaticBody


var vis_type = ""


func _ready():
	visible = VisibilityManager.is_visible(vis_type)


func set_vis_id(key):
	vis_type = key
	if VisibilityManager.connect("toggle_vis", self, "_toggle_vis", []) != OK:
		push_warning("ERR")


func _toggle_vis(id, vis):
	if id == vis_type:
		visible = vis

###

func _on_input_event(camera, event:InputEventMouseButton, click_position, click_normal, shape_idx):
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT:
			if event.pressed:
				_select_segment()
			else:
				_deselect_segment()


func _select_segment():
	print("SELECT")


func _deselect_segment():
	print("DESELECT")
