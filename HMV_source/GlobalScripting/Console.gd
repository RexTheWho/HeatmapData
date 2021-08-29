extends Node


#######################################################
############### CONSOLE LOG CHEAT SHEET ###############
const INFO = Color.darkgray
const SETTING = Color.fuchsia
const WARN = Color.orangered
const ERROR = Color.red
#######################################################
#######################################################


const frames = ["+---", "-+--", "--+-", "---+", "--+-", "-+--"]
const valid_commands = ["help", "bind", "unbind_all"]

var num = 0
var console_base:HSplitContainer
var console_bg:ColorRect
var console_label:RichTextLabel
var console_input:LineEdit

func _ready():
	build_console()


func _input(event):
	if event.is_action_pressed("toggle_console"):
		console_base.visible = !console_base.visible



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
	
	var resizer:HSplitContainer = HSplitContainer.new()
	resizer.anchor_left = 0
	resizer.anchor_top = 0
	resizer.anchor_right = 1
	resizer.anchor_bottom = 1
	resizer.visible = false
	resizer.name = "Dragger"
	console_base = resizer
	canvas.add_child(resizer)
	
	var bg:ColorRect = ColorRect.new()
	bg.anchor_left = 0
	bg.anchor_top = 0
	bg.anchor_right = 1
	bg.anchor_bottom = 1
	bg.color = Color(0.0, 0.0, 0.0, 0.5)
	bg.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	bg.rect_min_size.x = 200
	bg.name = "ColorRect"
	console_bg = bg
	resizer.add_child(bg)
	
	var invis:Control = Control.new()
	invis.anchor_left = 0
	invis.anchor_top = 0
	invis.anchor_right = 1
	invis.anchor_bottom = 1
	invis.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	resizer.add_child(invis)
	invis.set_mouse_filter(Control.MOUSE_FILTER_IGNORE)
	
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
	label.bbcode_text = "[center][rainbow freq=1.0 sat=0.5]/// Console ///[/rainbow][/center]"
	label.name = "ConsoleLabel"
	console_label = label
	vbox.add_child(label)
	
	var inputlabel = LineEdit.new()
	if inputlabel.connect("gui_input", self, "_input_label_event", []) == OK:
		inputlabel.rect_min_size.y = 28
		console_input = inputlabel
		vbox.add_child(inputlabel)


func _input_label_event(event:InputEvent):
	if event is InputEventKey and event.is_pressed() and event.scancode == KEY_ENTER:
		var first_split = console_input.text.find(" ")
		var command = console_input.text
		if first_split != -1:
			command = command.left(first_split)
		var arguments = console_input.text.right(console_input.text.find(" ")+1)
		if command in valid_commands:
			_input_command(command, arguments)
			console_input.text = ""
			self.log(["Note: commands currently are non-functional!"], Color.orangered)
		else:
			self.log(["Invalid command",command,"!"], Color.red)

func _input_command(command:String, arguments:String):
	if command:
		var args = ["test1", "test2"]
		call("_run_command_" + command, args)


func _run_command_help(args:Array):
	var coms = ""
	for command_id in valid_commands:
		coms +=  "\n" + "\t" + command_id
	self.log(["Valid commands:",coms], Color.lightskyblue)


func _run_command_bind(args:Array):
	self.log(["Rebinding",args[0],"to",args[1]], Color.lightskyblue)


func _run_command_unbind_all(args:Array):
	self.log(["Unbound all keys... why tho?"], Color.lightskyblue)


