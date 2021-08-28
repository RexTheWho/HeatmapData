extends Node


#func _ready():
#	if get_tree().connect("files_dropped", self, "test_dragged_file") == OK:
#		print("Ready to go!")
#
#
#func test_dragged_file(files, _screen):
#	print(files)
#	var result = load_xml(files[0])
#	yield(get_tree().create_timer(1),"timeout")
#	print( JSON.print(result, "\t") )


func load_xml(file):
	var xml:XMLParser = XMLParser.new()
	if xml.open(file) == OK:
		return get_current_table(xml)
	else:
		push_error("Failed to open XML!")


# Potential values are table, number, vector3, string and boolean
#var line = 0
#var depth = 0
var stored_ref_ids = {}
func get_current_table(xml:XMLParser):
#	print("\n -- table open -- \n")
#	depth += 1
	var final_table = {}
	while xml.read() == OK:
#		line += 1
		if xml.get_node_type() == XMLParser.NODE_ELEMENT:
			
			var key = get_xml_key(xml)
			var values = get_xml_values(xml)
#			prints(str(line).pad_zeros(3), str(depth).pad_zeros(3), key, values)
			
			if not xml.is_empty():
				final_table[key] = get_current_table(xml)
			elif values.has("value"):
				final_table[key] = values["value"]
			
			if values.has("_id"):
				final_table["_id"] = values["_id"]
			elif values.has("_ref"):
				final_table["_ref"] = values["_ref"]
#			print("didnt break")
		elif xml.get_node_type() == XMLParser.NODE_ELEMENT_END:
			break
#		else:
#			print("not element start/end")
	
#	print("\n -- table ended -- \n")
#	depth -= 1
	return final_table


func get_xml_values(xml:XMLParser):
	var dict = {}
	var last_att = ""
	for i in xml.get_attribute_count():
		var att_name = xml.get_attribute_name(i)
		var att = xml.get_attribute_value(i)
		if att_name == "value":
			if last_att == "number":
				last_att = ""
				att = float(att)
			elif last_att == "vector3":
				last_att = ""
				att = str2var("Vector3("+att.replace(" ", ",")+")")
		dict[att_name] = att
		last_att = att
	return dict


func get_xml_key(xml:XMLParser):
	var values = get_xml_values(xml)
	if values.has("key"):
		return values["key"]
	elif values.has("index"):
		return values["index"]
	elif xml.get_node_type() == XMLParser.NODE_ELEMENT or xml.get_node_type() == XMLParser.NODE_ELEMENT_END:
		return xml.get_node_name()



