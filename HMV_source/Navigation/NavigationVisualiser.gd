extends Spatial


# Description: Generate and visualise navigation from a level.
# Mechanics: load nav data from drag and drop.
# Bugs: TBA.

const GenericXML = preload("res://ToolScripts/GenericScriptDataXML.gd")
const room_quad_keys = [
	# Room data array is in this order:
	"room_borders_x_neg",
	"room_borders_x_pos",
	"room_borders_y_neg",
	"room_borders_y_pos",
	"room_heights_xn_yn",
	"room_heights_xn_yp",
	"room_heights_xp_yn",
	"room_heights_xp_yp",
]

var path = ""
var nav_data = {
#	door_high_pos
#	door_high_rooms
#	door_low_pos
#	door_low_rooms
#	helper_blockers
#	nav_segments
#	room_borders_x_neg
#	room_borders_x_pos
#	room_borders_y_neg
#	room_borders_y_pos
#	room_heights_xn_yn
#	room_heights_xn_yp
#	room_heights_xp_yn
#	room_heights_xp_yp
#	room_vis_groups
#	version
#	vis_groups
}


func _ready():
	if get_tree().connect("files_dropped", self, "_begin_navgen") == OK:
		print("Ready to go!")


func _begin_navgen(files:PoolStringArray, _screen:int):
	for i in files:
		var string:String = i
		if string.get_extension() in ["generic_xml", "nav_data"]:
			path = string
	if path != "":
		print("BEGIN NAVGEN")
		_load_nav_data()


func _load_nav_data():
	nav_data = GenericXML.new().load_xml(path)
#	print( JSON.print(nav_data, "\t") )
	var quads = get_quads()
	var segments = get_segments()
	$RoomHolder.build_map( quads, segments )


func get_xml_contents(file):
	var dict = {}
	for i in file.get_attribute_count():
		dict[file.get_attribute_name(i)] = file.get_attribute_value(i)
	return dict


func save_dict(dict:Dictionary):
	var file = File.new()
	if file.open(path + "_CONV", File.WRITE) == OK:
		file.store_string( JSON.print(dict, "\t") )
		file.close()


# room_borders_x_neg
func get_quads():
	var quads = {}
	for key in room_quad_keys:
		var index = 0
		var room = nav_data["generic_scriptdata"][key]
		for value in room.values():
			if !quads.has(index):
				quads[index] = []
			quads[index].append(value)
			index += 1
	return quads


func get_segments():
	var segments = {}
	var nav_segments = nav_data["generic_scriptdata"]["nav_segments"]
	for index in nav_segments:
		segments[index] = nav_segments[index]["pos"]
	return segments


