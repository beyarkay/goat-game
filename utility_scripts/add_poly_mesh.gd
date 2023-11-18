extends CollisionPolygon2D

func _ready() -> void:
	var polygon2d = Polygon2D.new()
	polygon2d.polygon = self.polygon.duplicate()
	var texture = CompressedTexture2D.new()
	texture.load_path = "res://.godot/imported/dirt.png-0a1ee02e0310eb6b032db25fe6920ea9.ctex"
	polygon2d.set_texture(texture)
	polygon2d.set_texture_scale(3.4 * Vector2.ONE)
	polygon2d.texture_repeat = CanvasItem.TEXTURE_REPEAT_ENABLED
	self.add_sibling.call_deferred(polygon2d)
