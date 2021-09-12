extends Control

signal hover_off_job(key)
signal hover_on_job(key)

const job_rec = preload("res://Interface/CrimeNet/CNJobSelection.tscn")


export(NodePath) var job_selection_list


var job_headers = {}

func _ready():
	$H/RecordsList/H/V/Side2/V/Reload.connect("reload_jobs", self, "update_job_recordings")
	update_job_recordings()

func update_job_recordings():
	get_pdheat_files()
	$H/RecordsList/Label.text = "Crime.Net/Evidence_Locker: %03d Records" % [job_headers.size()]
	var list = get_node_or_null(job_selection_list)
	if list:
		for i in list.get_children():
			i.queue_free()
		for key in job_headers:
			add_job_listing(list, key)


func add_job_listing(add_to:Object, key:String):
	var job_rec_inst = job_rec.instance()
	job_rec_inst.name = key
	var job_head = job_headers[key]
	var contractor_loc = "Contact Missing"
	if job_head.has("contractor_loc"):
		contractor_loc = job_head["contractor_loc"]
	elif job_head.has("contractor_id"):
		contractor_loc = job_head["contractor_id"]
	
	var level_loc = "Level Missing"
	if job_head.has("level_loc"):
		level_loc = job_head["level_loc"]
	elif job_head.has("level_id"):
		level_loc = job_head["level_id"]
	
	job_rec_inst.set_job_path(job_headers[key]["path"])
	job_rec_inst.set_job_name(contractor_loc, level_loc)
	job_rec_inst.set_job_diff(job_head["difficulty"])
	job_rec_inst.set_job_date(job_head["start_date_time"])
	job_rec_inst.set_job_length(job_head["frame_total"], job_head["update_delay"])
	job_rec_inst.set_job_reference_key(key)
	add_to.add_child(job_rec_inst)


func get_pdheat_files():
	var exe_path:String = OS.get_executable_path()
	exe_path = exe_path.left(exe_path.find_last("/"))
	var records_path = exe_path + "/records"
#	print(records_path)
	var dir:Directory = Directory.new()
	if dir.open(records_path) == OK:
		var no_items = get_node(job_selection_list).get_node_or_null("NoJobs")
		if no_items: no_items.visible = false
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if !dir.current_is_dir():
#				print("Found F: " + file_name)
				var file_path:String = records_path + "/" + file_name
#				print("Path F: " + file_path)
				var head = get_jobs_header(file_path)
				job_headers[file_name] = head
				job_headers[file_name]["path"] = file_path
			file_name = dir.get_next()
	else:
		print("FAILED TO OPEN PATH -- " + records_path)





func get_jobs_header(path:String):
	var file = File.new()
	if file.open(path, File.READ) == OK:
		var file_text = file.get_as_text()
		return JSON.parse( file_text ).result
	else:
		return FAILED
