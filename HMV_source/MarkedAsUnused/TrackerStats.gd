extends Sprite3D

func _ready():
	var viewport_tex:ViewportTexture = ViewportTexture.new()
	viewport_tex = $Viewport.get_texture()
	texture = viewport_tex

