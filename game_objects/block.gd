tool
extends KinematicBody2D
class_name Block

export var is_draggable = true setget set_is_draggable

var game
var pos_ids = []

func _on_Area2D_input_event(viewport, event, shape_idx):
	if not is_draggable:
		return
	if event is InputEventMouseButton:
		print(Triangle.get_id(event.global_position - Vector2(640, 480)))
		if game.dragging_block == null and event.pressed:
			game.dragging_block = self
		elif game.dragging_block == self and not event.pressed:
			game.dragging_block = null
	elif event is InputEventMouseMotion:
		pass


func _on_Area2D_mouse_entered():
	print("enter ", pos_ids)
	game.hovered_block = self


func _on_Area2D_mouse_exited():
	print("exit ", pos_ids)
	if game.hovered_block == self:
		game.hovered_block = null


# Also update the position
func set_is_draggable(value):
	is_draggable = value
	position = Triangle.get_nearest_point(position)
