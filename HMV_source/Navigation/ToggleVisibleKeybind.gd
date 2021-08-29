extends Spatial


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

