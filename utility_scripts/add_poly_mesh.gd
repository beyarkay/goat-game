extends CollisionPolygon2D

func _ready() -> void:
    var polygon2d = Polygon2D.new()
    polygon2d.polygon = self.polygon.duplicate()
    self.add_sibling.call_deferred(polygon2d)
