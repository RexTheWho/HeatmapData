extends Spatial


var track_name = ""
var track_path = ""
var track_date = ""


func _ready():
	if get_tree().connect("files_dropped", self, "_files_dropped") == OK:
		print("Ready to go!")


func _files_dropped(files:PoolStringArray, _screen:int):
	for i in files:
		var file:String = i
		if file.get_extension() == "pdheat":
			$TrackerNodeHolder.generate_recording(file)
			#C:\Program Files (x86)\Steam\steamapps\common\PAYDAY 2\mods\HeatmapData\records\2021-08-28_16_08_13_arm_hcm.pdheat
			#C:\Program Files (x86)\Steam\steamapps\common\PAYDAY 2\mods\HeatmapData\nav_data\arm_hcm.nav_data
			var nav_file = file.left(file.find_last("\\")).replace("records", "nav_data\\") + $TrackerNodeHolder.get_header_level_id() + ".nav_data"
			$NavigationVisualiser.load_nav_data(nav_file)


func _read_header(heatmap_file):
	var header
	var file = File.new()
	if file.open(heatmap_file, File.READ) == OK:
		header = JSON.parse( file.get_as_text() ).result
	return header
