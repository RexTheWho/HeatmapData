extends Control


const job_rec = preload("res://Interface/CrimeNet/CNJobSelection.tscn")


export(NodePath) var job_selection_list


var job_headers = {}

func _ready():
	get_pdheat_files()
	$RecordsList/Label.text = "Crime.Net/Evidence_Locker: %03d Records" % [job_headers.size()]
	var list = get_node_or_null(job_selection_list)
	if list:
		list.get_node("NoJobs").visible = false
		for key in job_headers:
			add_job_listing(list, key)


func add_job_listing(add_to:Object, key:String):
	var job_head = job_headers[key]
	var job_rec_inst = job_rec.instance()
	job_rec_inst.set_job_path(job_headers[key]["path"])
	job_rec_inst.set_job_name(job_head["contractor_id"], job_head["level_id"])
	job_rec_inst.set_job_diff(job_head["difficulty"])
	job_rec_inst.set_job_date(job_head["start_date_time"])
	job_rec_inst.set_job_length(job_head["frame_total"], job_head["update_delay"])
	add_to.add_child(job_rec_inst)


func get_pdheat_files():
	var exe_path:String = OS.get_executable_path()
	exe_path = exe_path.left(exe_path.find_last("\\"))
	var dir:Directory = Directory.new()
	if !dir.dir_exists(exe_path + "\\records"):
		push_warning("CNJobList: If you are seeing this the EXE is not in the right place!")
		exe_path = "C:\\Program Files (x86)\\Steam\\steamapps\\common\\PAYDAY 2\\mods\\HeatmapData\\"
	
	if dir.open(exe_path + "records") == OK:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if !dir.current_is_dir():
				print("Found F: " + file_name)
				var head = get_jobs_header(exe_path + "records\\" + file_name)
				job_headers[file_name] = head
				job_headers[file_name]["path"] = exe_path + "records\\" + file_name
			file_name = dir.get_next()
	else:
		print("FAILED TO OPEN PATH")





func get_jobs_header(path:String):
	var file = File.new()
	if file.open(path, File.READ) == OK:
		var file_text = file.get_as_text()
		return JSON.parse( file_text ).result
	else:
		return FAILED
