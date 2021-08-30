extends Node

func _ready():
	var command_args = OS.get_cmdline_args()
	if command_args:
		for i in command_args:
			var file:String = i
			if file.get_extension() == "pdheat":
				get_tree().change_scene_to(load("res://Heatmap.tscn"))
	else:
		get_tree().change_scene_to(load("res://Interface/CrimeNet/CrimeNetRoot.tscn"))
