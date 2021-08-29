extends Spatial


# Description: Build the mesh from nav data dict
# Mechanics: build map from nav data
# Bugs: Relatively slow.

const toggle_script = preload("res://Navigation/ToggleVisibleKeybind.gd")
const mat = preload("res://Materials/NavigationVisualiserMesh.tres")
const mat_cheap = preload("res://Materials/basic_nav_door_cheap.tres")
const nav_segment_node = preload("res://Navigation/NavSegment.tscn")
const nav_floating = 22.5
const nav_multi = 2.5
const room_quad_keys = [
	"room_borders_x_neg",
	"room_borders_x_pos",
	"room_borders_y_neg",
	"room_borders_y_pos",
	"room_heights_xn_yn",
	"room_heights_xn_yp",
	"room_heights_xp_yn",
	"room_heights_xp_yp",
]
#var nav_data = {
#	1: [
#		"-13",
#		"13",
#		"-25",
#		"6",
#		"25",
#		"45",
#		"80",
#		"100"
#	],
#}

func _ready():
	mat_cheap.set("shader_param/color", Color.darkgoldenrod)


func clear_children():
	for i in get_children():
		i.queue_free()


func build_navigation(nav_data:Dictionary):
	clear_children()
	var segments_data = nav_data["generic_scriptdata"]["nav_segments"]
	var segments_pos = get_segments_pos(nav_data)
	
	var quads = get_quads(nav_data)
	for quad in quads:
		_build_quads(quad)
	
	var doors = get_doors(nav_data)
	for door in doors:
		_build_door(door)
	
	for index in segments_data:
		_build_segment(segments_pos[index])


func _build_door(arr:Array):
	var pos_high = Vector3(arr[0].x/4, (arr[0].z-nav_floating)/100, -arr[0].y/4)
	var pos_low = Vector3(arr[1].x/4, (arr[1].z-nav_floating)/100, -arr[1].y/4)
	var pos_len = pos_low.distance_to(pos_high)
	
	var doorframe:CSGCylinder = CSGCylinder.new()
	doorframe.set_script(toggle_script)
	doorframe.set_vis_id("nav_doors")
	doorframe.visible = VisibilityManager.is_visible("nav_doors")
	doorframe.material = mat_cheap
	doorframe.translation = lerp(pos_high, pos_low, 0.5)
	doorframe.sides = 3
	doorframe.radius = 0.03
	doorframe.height = pos_len
	add_child(doorframe)
	
	doorframe.look_at(pos_low, Vector3.UP)
	doorframe.rotation_degrees += Vector3(90,0,0)


func _build_segment(segment_data):
	var pos = Vector3( segment_data.x, segment_data.z, -segment_data.y )/100
	var seg = nav_segment_node.instance()
	seg.set_vis_id("nav_segments")
	seg.visible = VisibilityManager.is_visible("nav_segments")
	seg.translation = pos
	add_child(seg)
#	return seg


func _build_quads(arr:Array):
	if arr.empty():
		push_warning("NavVisMesh: build quads array was empty.")
		return
	var arr_mesh = ArrayMesh.new()
	var cg_mesh:CSGMesh = CSGMesh.new()
	cg_mesh.set_script(toggle_script)
	cg_mesh.set_vis_id("nav_quads")
	cg_mesh.visible = VisibilityManager.is_visible("nav_quads")
	cg_mesh.material = mat.duplicate()
	cg_mesh.material.set_shader_param("albedo", rand_quad_color(0.4))
	add_child(cg_mesh)
	
	# Dont touch!
	for i in arr.size():
		if i <= 3:
			arr[i] = (float(arr[i]) / 10) * nav_multi
		else:
			arr[i] = (float(arr[i]) - nav_floating) / 100
	
	# Dont touch! Ok maybe a little, could be more optimised in future.
	for i in range(2):
		var tri = PoolVector3Array()
		var xn_zn = Vector3(arr[0], arr[4], -arr[2])
		var xn_zp = Vector3(arr[0], arr[5], -arr[3])
		var xp_zn = Vector3(arr[1], arr[6], -arr[2])
		var xp_zp = Vector3(arr[1], arr[7], -arr[3])
		if i == 0:
			tri.push_back(xn_zn) # x- z-
			tri.push_back(xn_zp) # x- z+
			tri.push_back(xp_zn) # x+ z-
		if i == 1:
			tri.push_back(xp_zp) # x+ z+
			tri.push_back(xp_zn) # x+ z-
			tri.push_back(xn_zp) # x- z+
		
		var uv1 = PoolVector2Array()
		var un_vn = Vector2(arr[0], -arr[2])
		var un_vp = Vector2(arr[0], -arr[3])
		var up_vn = Vector2(arr[1], -arr[2])
		var up_vp = Vector2(arr[1], -arr[3])
		if i == 0:
			uv1.push_back(un_vn) # x- z-
			uv1.push_back(un_vp) # x- z+
			uv1.push_back(up_vn) # x+ z-
		if i == 1:
			uv1.push_back(up_vp) # x+ z+
			uv1.push_back(up_vn) # x+ z-
			uv1.push_back(un_vp) # x- z+
		
		var arrays = []
		arrays.resize(ArrayMesh.ARRAY_MAX)
		arrays[ArrayMesh.ARRAY_VERTEX] = tri
		arrays[ArrayMesh.ARRAY_TEX_UV] = uv1
		arr_mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays)
	cg_mesh.mesh = arr_mesh
	return cg_mesh


# TOOL STUFF
# TOOL STUFF
# TOOL STUFF

func rand_color(alpha = 1.0, saturation_multi = 1.0):
	return Color(rand_range(0.6, 0.75)*saturation_multi, rand_range(0.6, 0.75)*saturation_multi, rand_range(0.6, 0.75)*saturation_multi, alpha)

func rand_quad_color(alpha = 1.0, saturation_multi = 1.0):
	return Color(rand_range(0.4, 0.6)*saturation_multi, rand_range(0.4, 0.6)*saturation_multi, rand_range(0.8, 0.9)*saturation_multi, alpha)

# GET STUFF
# GET STUFF
# GET STUFF

func get_quads(nav_data:Dictionary):
	var quads = []
	var quads_indexes = nav_data["generic_scriptdata"]["room_borders_x_neg"]
	for index in quads_indexes:
		var quad_arr = []
		for key in room_quad_keys:
			if nav_data["generic_scriptdata"][key].has(index):
				quad_arr.append(nav_data["generic_scriptdata"][key][index])
		quads.append(quad_arr)
	return quads


func get_quads_from_segment(nav_data:Dictionary, segment_index):
	var quads = []
	var nav_segments = nav_data["generic_scriptdata"]["nav_segments"]
	var nav_segments_neighbours = segment_index["neighbours"]
	prints("NAV SEGS", segment_index)
	for index in nav_segments:
		var quad_arr = []
		for key in room_quad_keys:
			quad_arr.append(nav_data["generic_scriptdata"][key][index])
		quads.append(quad_arr)
	return quads


func get_segments_pos(nav_data:Dictionary):
	var segments = {}
	var nav_segments = nav_data["generic_scriptdata"]["nav_segments"]
	for index in nav_segments:
		segments[index] = nav_segments[index]["pos"]
	return segments


func get_doors(nav_data:Dictionary):
	var doors = []
	var door_high_pos = nav_data["generic_scriptdata"]["door_high_pos"]
	var door_high_idx = nav_data["generic_scriptdata"]["door_high_rooms"]
	var door_low_pos = nav_data["generic_scriptdata"]["door_low_pos"]
	var door_low_idx = nav_data["generic_scriptdata"]["door_low_rooms"]
	for i in door_high_pos.keys():
		var high = door_high_pos[i]
		var high_door = door_high_idx[i]
		var low = door_low_pos[i]
		var low_door = door_low_idx[i]
		doors.append([high,low])
	return doors
