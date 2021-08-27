extends Node2D

var path:PoolVector3Array = []

func _ready():
#	for i in range(10):
#		var x = rand_range(-20, 20)
#		var y = rand_range(-20, 20)
#		path.append( Vector3(x, 0, y) )
#		$Line2D.add_point( Vector2(x,y) * 20 )
	
	var point_idx = 0.0
	for i in $Line2D.points:
		var height = point_idx
		path.append( Vector3(i.x, height, i.y) / 100 )
		point_idx += 4

func get_path():
	return path
