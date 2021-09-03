extends TextureRect

const fbi_weapons_url = "https://fbi.overkillsoftware.com/img/weapons/ranged/thumbs/{weapon_id}.png"
const fbi_legend_url = "https://www.overkillsoftware.com/ovk-media/economy42gF2Y/weapon_skins_{weapon_id}.png"
const random_wep = ["sbl","wa2000","frankish","contraband","vhs","b682","g36","saiga","fal"]
const random_wep2 = ["vityaz","arbiter","m1928","chinchilla","c96","slap","new_mp5","colt_1911","deagle"]
const random_leg = ["saw_nin","ak74_rodina","par_wolf","x_chinchilla_mxs","x_1911_ginger","new_m14_lones","scar_ait","m16_cola","boot_buck"]

onready var default_icon = texture
var http:HTTPRequest


func _temp():
	texture = default_icon
	var wep
	var legend = false
	if self.name.begins_with("Primary"):
		if rand_range(0,1) > 0.3:
			wep = random_leg.duplicate()
			legend = true
		else:
			wep = random_wep.duplicate()
	else:
		wep = random_wep2.duplicate()
	wep.shuffle()
	_load_thumb(wep[0], legend)

func _input(event):
	if event.is_action_pressed("space"):
		_temp()


func _load_thumb(weapon_id:String, legendary = false):
	var weapon_url:String
	if legendary:
		weapon_url = fbi_legend_url.format({"weapon_id":weapon_id})
	else:
		weapon_url = fbi_weapons_url.format({"weapon_id":weapon_id})
	if !http:
		http = HTTPRequest.new()
		http.use_threads = true
		add_child(http)
		if http.connect("request_completed", self, "_set_thumb") == OK:
			print("Requesting thumbnail...")
	http.request(weapon_url)


func _set_thumb(result, response_code, headers, body):
	if headers[1] == "Content-Type: image/png":
		var thumb_image:Image = Image.new()
		var thumb_texture:ImageTexture = ImageTexture.new()
		if thumb_image.load_png_from_buffer(body) == OK:
			thumb_texture.create_from_image(thumb_image)
			texture = thumb_texture
