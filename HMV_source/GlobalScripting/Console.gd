extends Node

const frames = ["+---", "-+--", "--+-", "---+", "--+-", "-+--"]
var num = 0
var console_bg:ColorRect
var console_label:RichTextLabel

func _ready():
	build_console()


func _input(event):
	if event.is_action_pressed("toggle_console"):
		console_bg.visible = !console_bg.visible



func log(vars:Array, color = Color.white):
	num = wrapi(num+1, 0, 6)
	var log_text = frames[num] + ": "
	for v in vars:
		log_text += str(v) + " "
	var bbstring = "\n[color=#%s]%s[/color]" % [color.to_html(false), log_text]
	if console_label.append_bbcode(bbstring) != OK:
		push_warning("Console: BBCode was bad.")



func build_console():
	var canvas:CanvasLayer = CanvasLayer.new()
	canvas.layer = 100
	canvas.name = "Canvas"
	add_child(canvas)
	
	var bg:ColorRect = ColorRect.new()
	bg.anchor_left = 0
	bg.anchor_top = 0
	bg.anchor_right = 0.6
	bg.anchor_bottom = 1
	bg.color = Color(0.0, 0.0, 0.0, 0.5)
	bg.visible = false
	bg.name = "ColorRect"
	console_bg = bg
	canvas.add_child(bg)
	
	var vbox = VBoxContainer.new()
	vbox.anchor_right = 1
	vbox.anchor_bottom = 1
	vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	vbox.size_flags_vertical = Control.SIZE_EXPAND_FILL
	bg.add_child(vbox)
	
	var label = RichTextLabel.new()
	label.anchor_right = 1
	label.anchor_bottom = 1
	label.scroll_following = true
	label.bbcode_enabled = true
	label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	label.size_flags_vertical = Control.SIZE_EXPAND_FILL
	label.bbcode_text = "[center][rainbow sat=0.5]/// Console ///[/rainbow][/center]"
	label.name = "ConsoleLabel"
	console_label = label
	vbox.add_child(label)
	
	var inputlabel = TextEdit.new()
	inputlabel.rect_min_size.y = 28
	vbox.add_child(inputlabel)
