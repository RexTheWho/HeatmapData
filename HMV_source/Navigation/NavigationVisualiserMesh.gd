extends Spatial


# Description: Build the mesh from nav data dict
# Mechanics: build map from nav data
# Bugs: Relatively slow.

const mat = preload("res://Navigation/NavigationVisualiserMesh.tres")
const nav_segment_node = preload("res://Navigation/NavSegment.tscn")
const nav_floating = 22.5
const nav_multi = 2.5
var room_data = {
	1: [
		"-13",
		"13",
		"-25",
		"6",
		"25",
		"45",
		"80",
		"100"
	],
}


func build_map(quads:Dictionary, segments:Dictionary):
	for i in get_children():i.queue_free()
	
	randomize()
	var _start_time = OS.get_ticks_msec()
	
	print("NAVMesh: Building Map Segments...")
	for pos in segments.values():
		pos = Vector3( pos.x, pos.z, -pos.y )/100
		var seg = nav_segment_node.instance()
		seg.translation = pos
		add_child(seg)
	
	print("NAVMesh: Building Map Mesh...")
	for room_id in quads.keys():
		var arr_mesh = ArrayMesh.new()
		var arr = quads[room_id]
		var cg_mesh:CSGMesh = CSGMesh.new()
		cg_mesh.material = mat.duplicate()
		cg_mesh.material.set_shader_param("albedo", Color(rand_range(0.25, 0.75), rand_range(0.25, 0.75), rand_range(0.25, 0.75), 0.2))
		add_child(cg_mesh)
		
		# Dont touch!
		for i in arr.size():
			if i <= 3:
				arr[i] = (float(arr[i]) / 10) * nav_multi
			else:
				arr[i] = (float(arr[i]) - nav_floating) / 100
		
		# Dont touch!
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

	var _end_time = OS.get_ticks_msec()
	prints("Building took",_end_time - _start_time, "ms")
