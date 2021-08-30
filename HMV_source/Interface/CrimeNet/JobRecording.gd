extends Node2D

const diff_on = Color(1, 1, 0.305882)
const diff_off = Color(0, 0, 0, 0.66)

onready var job_name = $H/V/Label
func _ready():
	var jobs = ["Art Gallery", "Bank Heist: Gold", "Bank Heist: Cash", "Bank Heist: Deposit", "Mallcrasher"]
	job_name.text = jobs[randi()%5]
	
	var difficulty = randi()%7
	for i in range(1,7):
		var skull = get_node_or_null("H/V/H/cn_skulls" + str(i))
		if skull:
			if i <= difficulty:
				skull.material = load("res://Materials/CanvasAdd.tres")
				skull.self_modulate = diff_on
			else:
				skull.material = null
				skull.self_modulate = diff_off
	
	if randi()%2 > 0:
		$H/Mods/cn_minighost.visible = false
	
	if randi()%2 > 0:
		$H/Mods/cn_onedown.visible = false
