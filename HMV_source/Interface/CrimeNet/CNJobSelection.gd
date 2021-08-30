extends Button

export(NodePath) var CNSkulls
export(NodePath) var CNJobName
export(NodePath) var CNJobDate
export(NodePath) var CNLength
export(NodePath) var CNTimer

var filepath = ""

func _play_job():
	print("PLAY! " + filepath)
	SignalManager.selected_job = filepath
	get_tree().change_scene_to(load("res://Heatmap.tscn"))

func set_job_path(path:String):
	filepath = path

func set_job_name(contractor:String, job:String):
	get_node(CNJobName).text = contractor + ": " + job

func set_job_diff(diff:int):
	get_node(CNSkulls).set_difficulty(diff)

func set_job_date(date:String):
	get_node(CNJobDate).text = date

# Needs checking for if its accurate
func set_job_length(frame_total:int, update_delay:float):
	var elapsed:int = ceil(update_delay * frame_total)
	var minutes = elapsed / 60
	var seconds = elapsed % 60
	var str_elapsed = "%02d : %02d" % [minutes, seconds]
	get_node(CNTimer).text = str_elapsed

func set_job_mods(job:String):
	pass
