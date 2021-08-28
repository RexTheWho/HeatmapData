extends Spatial


# Description: Generate and visualise navigation from a level.
# Mechanics: load nav data from drag and drop.
# Bugs: TBA.

const GenericXML = preload("res://ToolScripts/GenericScriptDataXML.gd")


#func _ready():
#	if get_tree().connect("files_dropped", self, "_begin_navgen") == OK:
#		print("Ready to go!")


#func _begin_navgen(files:PoolStringArray, _screen:int):
#	for i in files:
#		var path:String = i
#		if path.get_extension() in ["generic_xml", "nav_data"]:
#			print("BEGIN NAVGEN")
#			load_nav_data(path)


func load_nav_data(path):
	$RoomHolder.clear_children()
	var nav_data = GenericXML.new().load_xml(path)
	if nav_data:
		$RoomHolder.build_navigation(nav_data)


func get_xml_contents(file):
	var dict = {}
	for i in file.get_attribute_count():
		dict[file.get_attribute_name(i)] = file.get_attribute_value(i)
	return dict


# Find out what this even is now
func save_dict(dict:Dictionary):
	var file = File.new()
	var pathidk = ""
	if file.open(pathidk + "_CONV", File.WRITE) == OK:
		file.store_string( JSON.print(dict, "\t") )
		file.close()


