extends Control


func _ready():
	for i in $CNMods.get_children():
		i.visible = false
