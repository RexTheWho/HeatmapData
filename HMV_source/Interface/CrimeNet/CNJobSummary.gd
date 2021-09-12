extends MarginContainer

onready var text = $Text

func _ready():
	set_info()

func set_info(pay_contract = 0, bag_num = 0, pay_bags = 0, pay_offshore = 0, pay_spending = 0):
	text.bbcode_text = text.bbcode_text.format({
		"pay_contract":		Utils.pad_comma(pay_contract),
		"bag_num":			bag_num,
		"pay_bags":			Utils.pad_comma(pay_bags),
		"pay_offshore":		Utils.pad_comma(pay_offshore),
		"pay_spending":		Utils.pad_comma(pay_spending)
	})


