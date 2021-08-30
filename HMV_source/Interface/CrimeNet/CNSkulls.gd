extends HBoxContainer

const diff_on = Color(1, 1, 0.305882)
const diff_off = Color(0, 0, 0, 0.66)

func set_difficulty(difficulty:int):
	for i in difficulty:
		var skull = get_node_or_null("cn_skulls" + str(i))
		if skull:
			if i <= difficulty:
				skull.material = load("res://Materials/CanvasAdd.tres")
				skull.self_modulate = diff_on
			else:
				skull.material = null
				skull.self_modulate = diff_off
