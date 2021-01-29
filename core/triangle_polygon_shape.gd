tool
extends CollisionPolygon2D
class_name TrianglePolygonShape

export var enabled = true setget set_enabled



func set_enabled(value):
	enabled = value
	disabled = !value
	if value:
		update_vertices()


func update_vertices():
	for k in polygon.size():
		polygon[k] = Triangle.get_nearest_point(polygon[k])
