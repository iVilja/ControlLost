tool
extends Area2D
class_name Terrain

export var is_up = true setget set_is_up
var pos_id = []


func set_is_up(value):
	is_up = value
	if has_node("TrianglePolygonShape"):
		$TrianglePolygonShape.polygon[1] = Vector2(
			Triangle.TriangleSize.x / 2,
			Triangle.TriangleSize.y * (-1 if is_up else 1)
		)
	if has_node("Sprite"):
		var sprite = $Sprite
		sprite.position = Vector2(0, -Triangle.TriangleSize.y) if is_up else Vector2.ZERO
		sprite.flip_v = not is_up
