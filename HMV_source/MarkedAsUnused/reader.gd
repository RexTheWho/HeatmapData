extends Node

var timeline = [
	{
		time = 123.4,
		dallas = {
			pos = Vector3(1,2,3),
			rot = 240,
		},
		chains = {
			pos = Vector3(1,2,3),
			rot = 69,
		},
	},
]

var FILE:File
var FILE_LAST_OPENED = 0
var FILE_DATA

func _ready():
	FILE = File.new()

func _process(delta):
	var mod_time = FILE.get_modified_time("C:/Users/donts/Desktop/test_icle.txt")
	if FILE_LAST_OPENED != mod_time:
		print(">Odd Mod Time")
		if FILE.open("C:/Users/donts/Desktop/test_icle.txt", File.READ) != OK:
			push_warning("WRN")
		else:
			FILE_LAST_OPENED = mod_time
			FILE_DATA = FILE.get_as_text()
			FILE.close()
			print(FILE_DATA)
