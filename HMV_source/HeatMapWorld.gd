extends Spatial


var track_name = ""
var track_path = ""
var track_date = ""


func _ready():
	if get_tree().connect("files_dropped", self, "_files_dropped") == OK:
		print("Ready to go!")


func _files_dropped(files:PoolStringArray, _screen:int):
	for i in files:
		var string:String = i
		if string.get_extension() in ["generic_xml", "nav_data"]:
			track_path = string
		track_path = string
		print( _read_header(track_path) )
	if track_path != "":
		prints("HeatMapWorld:", track_path)


func _read_header(heatmap_file):
	var header
	var file = File.new()
	if file.open(heatmap_file, File.READ) == OK:
		header = JSON.parse( file.get_as_text() ).result
	return header
