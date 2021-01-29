tool
extends "res://game_objects/game_area.gd"
class_name Block


func _ready():
	print(original_pos)


func _on_Area2D_input_event(viewport, event, shape_idx):
	if game.hovered_block != self:
		return
	if event is InputEventMouseButton:
		if game.dragging_block == null and event.is_action_pressed("select"):
			game.dragging_block = self
		elif game.dragging_block == self and event.is_action_released("select"):
			game.dragging_block = null
	elif event is InputEventMouseMotion:
		pass


func _on_Area2D_mouse_entered():
	if game.hovered_block == null:
		game.hovered_block = self
		print("enter ", pos)


func _on_Area2D_mouse_exited():
	if game.hovered_block == self:
		game.hovered_block = null
		print("exit ", pos)
