extends Node

func _ready():
	if get_tree().connect("files_dropped", self, "test_dragged_file") == OK:
		print("Ready to go!")


func test_dragged_file(files, _screen):
	print(files)
	var result = load_xml(files[0])
	yield(get_tree().create_timer(1),"timeout")
	print( JSON.print(result, "\t") )


func load_xml(file):
	var xml:XMLParser = XMLParser.new()
	if xml.open(file) == OK:
		return get_current_table(xml)
	else:
		push_error("Failed to open XML!")


# Potential values are table, number, vector3, string and boolean
var line = 0
var depth = 0
func get_current_table(xml:XMLParser):
	print("\n -- table open -- \n")
	depth += 1
	var final_table = {}
	while xml.read() == OK:
		line += 1
		if xml.get_node_type() == XMLParser.NODE_ELEMENT:
			
			var key = get_xml_key(xml)
			var values = get_xml_values(xml)
			prints(str(line).pad_zeros(3), str(depth).pad_zeros(3), key, values)
			
			if values.has("type") and values["type"] == "table":
				final_table[key] = get_current_table(xml)
			
			elif values.has("value"):
				# No xml.read() forward here or else it just stacks dictionaries
				final_table[key] = values["value"]
			print("didnt break")
		elif xml.get_node_type() == XMLParser.NODE_ELEMENT_END:
			break
		else:
			print("not element start/end")
	
	print("\n -- table ended -- \n")
	depth -= 1
	return final_table


func get_xml_values(xml:XMLParser):
	var dict = {}
	for i in xml.get_attribute_count():
		dict[xml.get_attribute_name(i)] = xml.get_attribute_value(i)
	return dict


func get_xml_key(xml:XMLParser):
	var values = get_xml_values(xml)
	if values.has("key"):
		return values["key"]
	elif values.has("index"):
		return values["index"]
	elif xml.get_node_type() == XMLParser.NODE_ELEMENT or xml.get_node_type() == XMLParser.NODE_ELEMENT_END:
		return xml.get_node_name()



