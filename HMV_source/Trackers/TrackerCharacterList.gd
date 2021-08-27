extends Control


# Description: UI element that tracks the number of enemies.
# Mechanics: add // remove // update // create // hide.
# Bugs: For got knows what reason the TextureRect icons are sometimes going dark. This is not duplicate TextureRects.


var list = {
#	civ = amount,
}

const path = "ScrollContainer/List"

func _ready():
	print("TCList: I exist.")
	SignalManager.simple_connect(SignalManager, self, "added_character_tracker", "add_character", [])
	SignalManager.simple_connect(SignalManager, self, "removed_character_tracker", "remove_character", [])


func add_character(character_id:String):
	prints("TCList: Adding", character_id)
	if CharDB.is_heister(character_id):
		character_id = "heisters"
	if list.has(character_id):
		list[character_id] += 1
		update_panel(character_id)
		create_panel(character_id)
	else:
		create_panel(character_id)
		list[character_id] = 1


func remove_character(character_id:String):
	prints("TCList: Removing", character_id)
	if list.has(character_id) and list[character_id] > 0:
		list[character_id] -= 1
		prints("TCList: List", character_id, list[character_id])
		if list[character_id] > 0:
			update_panel(character_id)
		else:
			hide_panel(character_id)


func update_panel(character_id):
	prints("TCList: Updating panel for", character_id)
	var panel = get_node(path + "/Tracker_" + character_id)
	panel.get_node("Label").text = str(list[character_id])


func create_panel(character_id):
	var panel_node:HBoxContainer = get_node_or_null(path + "/Tracker_" + character_id)
	if panel_node:
		prints("TCList: Showing panel for", character_id)
		panel_node.visible = true
	else:
		prints("TCList: Making new panel for", character_id)
		var panel = HBoxContainer.new()
		panel.name = "Tracker_" + character_id
		get_node(path).add_child(panel)
		
		var texrect = TextureRect.new()
		texrect.name = "TextureRect"
		texrect.rect_min_size = Vector2(32,32)
		texrect.expand = true
		texrect.stretch_mode = TextureRect.STRETCH_SCALE
		texrect.texture = load("res://Textures/Characters/character_icon_{character_id}.png".format({"character_id":character_id}))
		panel.add_child(texrect)
		
		var label = Label.new()
		label.name = "Label"
		label.text = "1" # When the panel is created it can be assumed there's 1 enemy.
		panel.add_child(label)


func hide_panel(character_id):
	prints("TCList: Clearing panel from", character_id)
	var panel = get_node_or_null(path + "/Tracker_" + character_id)
	if panel:
		panel.visible = false
	else:
		push_warning("TCList: Does not contain a " + "Tracker_" + character_id)
	



