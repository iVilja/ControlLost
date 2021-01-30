extends "res://game_objects/terrains/terrain.gd"
class_name Goal


func interact(block):
	yield(get_tree(), "idle_frame")
	print(" > ", block.name)
	if block.type_name == "player":
		print("Completed!")
		emit_signal("interacted", true)
		return
	emit_signal("interacted", false)
