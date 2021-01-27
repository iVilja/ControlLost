extends Node2D
class_name Block

func _ready():
	print(123)


func _on_Area2D_input_event(viewport, event, shape_idx):
	print(event)


func _on_Area2D_mouse_entered():
	print(GameController.current_selected)


func _on_Area2D_mouse_exited():
	pass # Replace with function body.
