extends Node

func _ready():
	var load_scene
	var command_args = OS.get_cmdline_args()
	if command_args:
		for i in command_args:
			var file:String = i
			if file.get_extension() == "pdheat":
				load_scene = load("res://Heatmap.tscn")
	else:
		load_scene = load("res://Interface/CrimeNet/CrimeNetRoot.tscn")
	get_tree().change_scene_to(load_scene)
