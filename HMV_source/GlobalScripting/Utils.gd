extends Node
class_name Utils

static func pad_comma(num):
	var string = str(num)
	var mod = string.length() % 3
	var res = ""
	
	for i in range(0, string.length()):
		if i != 0 and i % 3 == mod:
			res += ","
		res += string[i]
	
	return res
