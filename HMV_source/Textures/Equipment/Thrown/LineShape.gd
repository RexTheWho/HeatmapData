extends Line2D

const resolution = 64
onready var bgpoly = $Polygon2D

func make_circle(radius = 150.0):
	_make_points()
	for i in range(resolution):
		var point_pos = _distorted_circle_position(i,radius)
		points[i] = point_pos
	
	#Connect the first and last points
	points[-1] = points[0]
	
	# Polygon
	bgpoly.polygon = points
	var uv = points
	for i in uv.size():
		uv[i] = uv[i] * 0.667
	bgpoly.uv = uv

func _make_points():
	clear_points()
	bgpoly.polygon = []
	for i in range(resolution + 1):
		add_point(Vector2.ZERO, i)

func _distorted_circle_position(i = 0, radius = 100.0):
	return Vector2(0, radius - 24).rotated(rotation + (PI * 2 / resolution * i))
