extends TextureRect

onready var tween = $Tween
var parent:Object
var uitype

# Dot percent based equipment
const dot_tex = preload("res://Textures/Equipment/deployable_dot.png")
var dots = []


func setup(type, number):
	uitype = type
	var tex = load("res://Textures/Equipment/{type}.png".format({"type":type}))
	if tex:
		texture = tex


func _ready():
	var amount = false
	if parent:
		amount = parent.get_amount()
	
	if amount is float and amount > 1:
		if uitype == "ecm_jammer":
			_use_ring_duration(amount)
		else:
			for i in ceil(amount):
				_add_dot()
	elif amount is bool:
		if uitype in ["sentry_gun", "sentry_gun_silent"]:
			pass # Snetty gun stuff


func _add_dot():
	var dot:TextureRect = TextureRect.new()
	dot.expand = true
	dot.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	dot.rect_min_size = Vector2(8,8)
	dot.texture = dot_tex
	dots.append(dot)
	$UseDots.add_child(dot)


# Disabled tweening, too jank
func _update_dots():
	var amount = false
	if parent:
		amount = parent.get_amount()
	if amount is float:
		var i = 0
		for dot in dots:
			var new_mod:Color
			if floor(amount) > i:
				new_mod = Color.white
			else:
				new_mod = Color(1.0, 1.0, 1.0, lerp(0.25, 1.0, clamp(amount-i, 0, 1)))
			dot.self_modulate = new_mod
#			var delay = 0.2
#			var interp_delay = abs((i-dots.size()-1)*delay)
#			tween.interpolate_property(dot, "self_modulate",
#				dot.self_modulate, new_mod, delay,
#				Tween.TRANS_LINEAR, Tween.EASE_IN_OUT, interp_delay)
			i += 1
#		tween.start()


func _use_ring_duration(amount):
	var ring = $RingDuration
	ring.visible = true
	ring.max_value = amount
	tween.interpolate_property(ring, "value", amount, 0, amount)
	tween.interpolate_property(ring, "self_modulate", self_modulate, Color(1.0, 1.0, 1.0, 0.0), 0.5, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT, amount)
	tween.interpolate_property(self, "self_modulate", self_modulate, Color(1.0, 1.0, 1.0, 0.5), 0.5, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT, amount) #ECM run dry
	tween.start()
